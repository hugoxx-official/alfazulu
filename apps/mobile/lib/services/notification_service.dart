import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  StreamController<int>? _unreadController;
  bool _isInitialized = false;
  Timer? _foregroundTimer;

  Stream<int>? get unreadStream => _unreadController?.stream;
  int _unreadCount = 0;
  static const String _apiUrl = 'https://backend-api-production-0cd8.up.railway.app/api';

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

    // Start background polling with Workmanager
    await _startBackgroundPolling();

    // Start foreground polling when app is in use (every 30 seconds)
    await _startForegroundPolling();

    // Load initial unread count
    await _loadUnreadCount();

    _isInitialized = true;
  }

  Future<void> requestPermission() async {
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
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Create high priority channel for immediate notifications
    const instantChannel = AndroidNotificationChannel(
      'alfazulu_instant',
      'Notificaciones Instantáneas',
      description: 'Notificaciones de alta prioridad',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(instantChannel);
  }

  Future<void> _startBackgroundPolling() async {
    await Workmanager().initialize(
      _backgroundCallback,
      isInDebugMode: false,
    );

    // Register periodic task - minimum 15 minutes on Android
    await Workmanager().registerPeriodicTask(
      'notification-poll',
      'notification-poll',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
      ),
    );
  }

  Future<void> _startForegroundPolling() async {
    // Cancel existing timer
    _foregroundTimer?.cancel();

    // Poll every 30 seconds when app is active
    _foregroundTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await checkNewNotifications();
    });
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
        Uri.parse('$_apiUrl/notifications?user_id=$userId&unread_only=true'),
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
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    bool instant = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      instant ? 'alfazulu_instant' : 'alfazulu_notifications',
      instant ? 'Notificaciones Instantáneas' : 'Notificaciones AlfaZulu',
      channelDescription: instant
        ? 'Notificaciones de alta prioridad'
        : 'Notificaciones de nuevos recursos y actualizaciones',
      importance: instant ? Importance.max : Importance.high,
      priority: instant ? Priority.max : Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

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
        Uri.parse('$_apiUrl/notifications?user_id=$userId&unread_only=true&limit=1'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notifications = (data['notifications'] as List?) ?? [];
        final newCount = notifications.length;

        // If there are new unread notifications, show system notification
        if (newCount > 0) {
          final latestNotification = notifications.first;
          final type = latestNotification['type'] ?? 'info';

          // Get icon and title based on type
          String icon = '📢';
          String notificationTitle = latestNotification['title'] ?? 'Nueva notificación';

          switch (type) {
            case 'premium':
              icon = '💎';
              break;
            case 'upload':
              icon = '📁';
              break;
            case 'admin':
              icon = '⚙️';
              break;
            case 'resource':
              icon = '📄';
              break;
          }

          await showNotification(
            title: '$icon $notificationTitle',
            body: latestNotification['message'] ?? '',
            payload: json.encode(latestNotification),
            instant: type == 'premium' || type == 'admin',
          );
        }
      }
    } catch (e) {
      print('Error checking notifications: $e');
    }
  }

  void dispose() {
    _foregroundTimer?.cancel();
    _unreadController?.close();
  }
}

// Background callback for Workmanager - MUST be top-level function
@pragma('vm:entry-point')
void _backgroundCallback() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final userId = prefs.getString('user_id');

  if (token == null || userId == null) return;

  try {
    final response = await http.get(
      Uri.parse('${NotificationService._apiUrl}/notifications?user_id=$userId&unread_only=true&limit=1'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final notifications = (data['notifications'] as List?) ?? [];

      if (notifications.isNotEmpty) {
        final notification = notifications.first;
        final type = notification['type'] ?? 'info';

        String icon = '📢';
        switch (type) {
          case 'premium': icon = '💎'; break;
          case 'upload': icon = '📁'; break;
          case 'admin': icon = '⚙️'; break;
          case 'resource': icon = '📄'; break;
        }

        // Show notification using FlutterLocalNotificationsPlugin directly
        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        final flutterNotifications = FlutterLocalNotificationsPlugin();
        await flutterNotifications.initialize(
          const InitializationSettings(android: androidSettings),
        );

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

        await flutterNotifications.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          '$icon ${notification['title'] ?? 'Nueva notificación'}',
          notification['message'] ?? '',
          const NotificationDetails(android: androidDetails),
          payload: json.encode(notification),
        );

        // Update unread count in prefs
        final currentUnread = prefs.getInt('unread_notifications') ?? 0;
        await prefs.setInt('unread_notifications', currentUnread + 1);
      }
    }
  } catch (e) {
    print('Background notification check error: $e');
  }
}
