import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  StreamController<int>? _unreadController;
  bool _isInitialized = false;

  Stream<int>? get unreadStream => _unreadController?.stream;
  int _unreadCount = 0;

  Future<void> init() async {
    if (_isInitialized) return;

    // Request permission
    await requestPermission();

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel
    await _createChannel();

    // Start background polling
    await _startBackgroundPolling();

    // Load initial unread count
    await _loadUnreadCount();

    _isInitialized = true;
  }

  Future<void> requestPermission() async {
    // Android 13+ requires notification permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      'alfazulu_notifications',
      'Notificaciones AlfaZulu',
      description: 'Notificaciones de nuevos recursos y actualizaciones',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _startBackgroundPolling() async {
    await Workmanager().initialize(
      _backgroundCallback,
      isInDebugMode: false,
    );

    // Poll every 15 minutes
    await Workmanager().registerPeriodicTask(
      'notification-poll',
      'notification-poll',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  Future<void> _loadUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        _unreadCount = 0;
        return;
      }

      final response = await http.get(
        Uri.parse('https://backend-api-production-0cd8.up.railway.app/api/notifications?unread_only=true'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _unreadCount = (data['notifications'] as List?)?.length ?? 0;
      }
    } catch (e) {
      print('Error loading unread count: $e');
    }

    _unreadController ??= StreamController<int>.broadcast();
    _unreadController!.add(_unreadCount);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Can be used to navigate to specific screen
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'alfazulu_notifications',
      'Notificaciones AlfaZulu',
      channelDescription: 'Notificaciones de nuevos recursos y actualizaciones',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );

    // Update unread count
    _unreadCount++;
    _unreadController?.add(_unreadCount);

    // Save to prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_notifications', _unreadCount);
  }

  Future<void> markAsRead() async {
    _unreadCount = 0;
    _unreadController?.add(_unreadCount);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_notifications', 0);
  }

  int get unreadCount => _unreadCount;

  Future<void> checkNewNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) return;

      final response = await http.get(
        Uri.parse('https://backend-api-production-0cd8.up.railway.app/api/notifications?unread_only=true'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notifications = (data['notifications'] as List?) ?? [];
        final newCount = notifications.length;

        if (newCount > _unreadCount) {
          // Show system notification
          final latestNotification = notifications.first;
          await showNotification(
            title: latestNotification['title'] ?? 'Nueva notificación',
            body: latestNotification['message'] ?? '',
            payload: json.encode(latestNotification),
          );
        }
      }
    } catch (e) {
      print('Error checking notifications: $e');
    }
  }
}

// Background callback for Workmanager
@pragma('vm:entry-point')
void _backgroundCallback() async {
  await NotificationService().checkNewNotifications();
}
