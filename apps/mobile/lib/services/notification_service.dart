import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Servicio de notificaciones del sistema
///
/// Muestra notificaciones REALES del sistema Android/iOS incluso con la app abierta.
/// Usa Firebase Cloud Messaging (FCM) para notificaciones push.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StreamController<int> _unreadController = StreamController<int>.broadcast();

  bool _isInitialized = false;
  int _unreadCount = 0;
  Timer? _pollingTimer;

  // Canales de notificación
  static const String _channelId = 'alfazulu_notifications';
  static const String _instantChannelId = 'alfazulu_instant';

  // API
  static const String _apiUrl = 'https://backend.alfazulu.pro/api';

  /// Registrar token FCM en el backend
  Future<void> registerFCMToken(String? userId) async {
    if (userId == null) return;

    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('fcm_token');

      // Solo registrar si el token es nuevo
      if (storedToken == token) {
        debugPrint('[NotificationService] Token FCM ya registrado');
        return;
      }

      final response = await http.post(
        Uri.parse('$_apiUrl/users/register-device'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'device_token': token,
          'platform': 'android',
        }),
      );

      if (response.statusCode == 200) {
        await prefs.setString('fcm_token', token);
        debugPrint('[NotificationService] Token FCM registrado en backend');
      }
    } catch (e) {
      debugPrint('[NotificationService] Error registrando token FCM: $e');
    }
  }

  /// Escuchar cambios en el token FCM
  void setupTokenRefresh(String? userId) {
    if (userId == null) return;

    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[NotificationService] Token FCM refresh: ${newToken.substring(0, 20)}...');
      registerFCMToken(userId);
    });
  }

  /// Stream para escuchar cambios en el contador de no leídas
  Stream<int>? get unreadStream => _unreadController.stream;
  int get unreadCount => _unreadCount;

  /// Inicializar el servicio de notificaciones
  Future<void> init() async {
    if (_isInitialized) {
      debugPrint('[NotificationService] Ya inicializado');
      return;
    }

    debugPrint('[NotificationService] Iniciando servicio...');

    // 1. Solicitar permisos (Android 13+)
    await _requestPermissions();

    // 2. Crear canales de notificación (Android)
    await _createNotificationChannels();

    // 3. Inicializar plugin con configuración para mostrar notificaciones del sistema
    await _initializePlugin();

    // 4. Configurar FCM
    await _setupFCM();

    // 5. Cargar contador inicial
    await _loadUnreadCount();

    // 6. Iniciar polling en foreground (cada 30 segundos)
    _startForegroundPolling();

    _isInitialized = true;
    debugPrint('[NotificationService] Servicio inicializado correctamente');
  }

  /// Configurar Firebase Cloud Messaging
  Future<void> _setupFCM() async {
    try {
      // Request permission
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      final token = await _messaging.getToken();
      debugPrint('[NotificationService] FCM Token: ${token?.substring(0, 20)}...');

      // Register token when user loads
      _loadUnreadCount().then((_) {
        // Get user_id from prefs
        SharedPreferences.getInstance().then((prefs) {
          final userId = prefs.getString('user_id');
          if (userId != null) {
            registerFCMToken(userId);
            setupTokenRefresh(userId);
          }
        });
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[NotificationService] FCM message received: ${message.messageId}');
        _handleFCMMessage(message);
      });

      // Handle notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[NotificationService] Notification tapped: ${message.messageId}');
      });
    } catch (e) {
      debugPrint('[NotificationService] Error configurando FCM: $e');
    }
  }

  /// Manejar mensaje FCM en foreground
  void _handleFCMMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'AlfaZulu';
    final body = message.notification?.body ?? '';
    final type = message.data['type'] ?? 'info';

    showSystemNotification(
      title: title,
      body: body,
      type: type,
      payload: json.encode(message.data),
    );
  }

  /// Solicitar permisos de notificación
  Future<void> _requestPermissions() async {
    try {
      // Android 13+ requiere solicitar permiso explícitamente
      if (await Permission.notification.isDenied) {
        debugPrint('[NotificationService] Solicitando permiso de notificación...');
        final status = await Permission.notification.request();
        debugPrint('[NotificationService] Permiso: $status');
      }

      // Verificar si tenemos permiso
      final hasPermission = await Permission.notification.isGranted;
      debugPrint('[NotificationService] Permiso habilitado: $hasPermission');
    } catch (e) {
      debugPrint('[NotificationService] Error solicitando permisos: $e');
    }
  }

  /// Crear canales de notificación para Android
  Future<void> _createNotificationChannels() async {
    try {
      // Canal principal - Notificaciones normales
      const channelMain = AndroidNotificationChannel(
        _channelId,
        'Notificaciones AlfaZulu',
        description: 'Notificaciones de nuevos recursos y actualizaciones',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.red,
      );

      // Canal de alta prioridad - Notificaciones instantáneas (premium, admin)
      const channelInstant = AndroidNotificationChannel(
        _instantChannelId,
        'Notificaciones Instantáneas',
        description: 'Notificaciones de alta prioridad (Premium, Admin)',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.amber,
      );

      // Registrar canales en Android
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channelMain);

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channelInstant);

      debugPrint('[NotificationService] Canales de notificación creados');
    } catch (e) {
      debugPrint('[NotificationService] Error creando canales: $e');
    }
  }

  /// Inicializar el plugin de notificaciones locales
  Future<void> _initializePlugin() async {
    try {
      // Configuración para Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false,
      );

      // Configuración combinada
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Inicializar con callback cuando el usuario toca una notificación
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
      );

      debugPrint('[NotificationService] Plugin inicializado');
    } catch (e) {
      debugPrint('[NotificationService] Error inicializando plugin: $e');
    }
  }

  /// Callback cuando se toca una notificación (app en foreground)
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] Notificación tocada: ${response.payload}');
    // Aquí podrías navegar a una pantalla específica
  }

  /// Callback cuando se toca una notificación (app en background)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] Notificación tocada (background): ${response.payload}');
  }

  /// Cargar el contador de notificaciones no leídas
  Future<void> _loadUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        _unreadCount = 0;
        _unreadController.add(0);
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

      _unreadController.add(_unreadCount);
    } catch (e) {
      debugPrint('[NotificationService] Error cargando contador: $e');
    }
  }

  /// Iniciar polling en foreground (cada 30 segundos)
  void _startForegroundPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkAndShowNotifications();
    });
    debugPrint('[NotificationService] Polling iniciado (30s)');
  }

  /// Verificar y mostrar notificaciones del sistema
  Future<void> _checkAndShowNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        return;
      }

      // Obtener última notificación no leída
      final response = await http.get(
        Uri.parse('$_apiUrl/notifications?user_id=$userId&unread_only=true&limit=1'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notifications = (data['notifications'] as List?) ?? [];

        if (notifications.isNotEmpty) {
          final notification = notifications.first;
          final type = notification['type'] ?? 'info';
          final title = notification['title'] ?? 'Nueva notificación';
          final message = notification['message'] ?? '';

          debugPrint('[NotificationService] Nueva notificación: $type - $title');

          // Mostrar notificación REAL del sistema
          await showSystemNotification(
            title: title,
            body: message,
            type: type,
            payload: json.encode(notification),
          );

          // Actualizar contador
          _unreadCount = notifications.length;
          _unreadController.add(_unreadCount);

          // Guardar en prefs
          await prefs.setInt('unread_notifications', _unreadCount);
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] Error verificando notificaciones: $e');
    }
  }

  /// Mostrar notificación REAL del sistema
  ///
  /// Esta es la función clave que muestra notificaciones del sistema
  /// incluso cuando la app está abierta (foreground).
  Future<void> showSystemNotification({
    required String title,
    required String body,
    String type = 'info',
    String? payload,
  }) async {
    try {
      // Determinar si es notificación de alta prioridad
      final isInstant = type == 'premium' || type == 'admin';

      // Configuración específica para Android
      final androidDetails = AndroidNotificationDetails(
        isInstant ? _instantChannelId : _channelId,
        isInstant ? 'Notificaciones Instantáneas' : 'Notificaciones AlfaZulu',
        channelDescription: isInstant
            ? 'Notificaciones de alta prioridad'
            : 'Notificaciones de nuevos recursos y actualizaciones',
        // CRÍTICO: Importancia máxima para que aparezca como banner
        importance: isInstant ? Importance.max : Importance.high,
        priority: isInstant ? Priority.max : Priority.high,
        // Icono de la notificación
        icon: '@mipmap/ic_launcher',
        // Sonido y vibración
        playSound: true,
        enableVibration: true,
        // Categoría para Android 11+
        category: AndroidNotificationCategory.message,
        // Visibilidad en lock screen
        visibility: NotificationVisibility.public,
        // No agrupar notificaciones
        groupKey: 'alfazulu_group',
        // Auto-cancelar al tocar
        autoCancel: true,
        // When indica cuándo se creó la notificación
        when: DateTime.now().millisecondsSinceEpoch,
        // Mostrar timestamp
        showWhen: true,
        // Color del borde (Android 5.0+)
        color: Colors.red,
        // Usar color en el icono
        colorized: true,
      );

      // Configuración específica para iOS
      final iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      // Detalles combinados
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // ID único basado en timestamp
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // MOSTRAR NOTIFICACIÓN DEL SISTEMA
      await _notifications.show(
        notificationId,
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('[NotificationService] Notificación del sistema mostrada: $title');
    } catch (e) {
      debugPrint('[NotificationService] Error mostrando notificación: $e');
    }
  }

  /// Alias para showSystemNotification (compatibilidad)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    bool instant = false,
  }) async {
    await showSystemNotification(
      title: title,
      body: body,
      type: instant ? 'premium' : 'info',
      payload: payload,
    );
  }

  /// Marcar todas las notificaciones como leídas
  Future<void> markAsRead() async {
    _unreadCount = 0;
    _unreadController.add(0);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_notifications', 0);

    debugPrint('[NotificationService] Notificaciones marcadas como leídas');
  }

  /// Verificar nuevas notificaciones (puede ser llamado externamente)
  Future<void> checkNewNotifications() async {
    await _checkAndShowNotifications();
  }

  /// Limpiar recursos
  void dispose() {
    _pollingTimer?.cancel();
    _unreadController.close();
    _isInitialized = false;
    debugPrint('[NotificationService] Servicio dispose');
  }
}

// ============================================================================
// NOTAS DE IMPLEMENTACIÓN:
// ============================================================================
// 1. Las notificaciones usan flutter_local_notifications (NO Firebase/FCM)
// 2. Importancia HIGH/MAX asegura que aparezca banner incluso en foreground
// 3. Polling cada 30s verifica nuevas notificaciones
// 4. Canales separados para notificaciones normales e instantáneas
// 5. Permisos solicitados para Android 13+
// 6. Icono usa @mipmap/ic_launcher (debe existir en todos los mipmap-*)
// ============================================================================
