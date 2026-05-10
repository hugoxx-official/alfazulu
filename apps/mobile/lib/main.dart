import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/maps_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tgcf_screen.dart';
import 'screens/premium_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
  await NotificationService().showNotification(
    title: message.notification?.title ?? 'AlfaZulu',
    body: message.notification?.body ?? 'Nueva notificación',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize notification service
  await NotificationService().init();

  // Setup FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const AlfaZuluApp());
}

class AlfaZuluApp extends StatelessWidget {
  const AlfaZuluApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'AlfaZulu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _shimmerAnimation;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeInOut)),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );

    _controller.forward();
    _rotateController.repeat();

    // Cargar sesión con timeout para evitar freeze
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final provider = context.read<AppProvider>();
        // Timeout de 5 segundos para loadUser
        final loaded = await provider.loadUser().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('Timeout en loadUser, continuando sin sesión');
            return false;
          },
        );
        if (mounted) setState(() => _hasSession = loaded);
      } catch (e) {
        print('Error loading user: $e');
        if (mounted) setState(() => _hasSession = false);
      }

      // Navegar después de la animación (sin password dialog - acceso abierto)
      await Future.delayed(const Duration(milliseconds: 3000));
      if (mounted) {
        try {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => MainNavigation(hasSession: _hasSession),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        } catch (e) {
          print('Error navegando: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glow effect with pulsing
                FadeTransition(
                  opacity: _glowAnimation,
                  child: AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, _) {
                      return Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.red.withOpacity(0.4 * _glowAnimation.value * (0.5 + 0.5 * _shimmerAnimation.value)),
                              Colors.red.withOpacity(0.15 * _glowAnimation.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Logo with rotation and shimmer
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _rotateAnimation,
                      builder: (context, _) {
                        return Transform.rotate(
                          angle: _rotateAnimation.value * 0.05, // Slight rotation
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.6 * _glowAnimation.value),
                                  blurRadius: 40 * _glowAnimation.value,
                                  spreadRadius: 8 * _glowAnimation.value,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Colors.red.withOpacity(0.3 + 0.4 * _shimmerAnimation.value),
                                  BlendMode.srcATop,
                                ),
                                child: Image.asset(
                                  'logo2.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.red.withOpacity(0.3),
                                    child: const Icon(
                                      Icons.shield_outlined,
                                      size: 80,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Title with shimmer effect
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, _) {
                          return Text(
                            'ALFAZULU',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              letterSpacing: 8,
                              shadows: [
                                Shadow(
                                  color: Colors.red.withOpacity(0.5 + 0.3 * _shimmerAnimation.value),
                                  blurRadius: 20 + 10 * _shimmerAnimation.value,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GESTIÓN DE RECURSOS',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Loading indicator with pulse
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, _) {
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 2.5,
                          value: 0.3 + 0.4 * _shimmerAnimation.value,
                          backgroundColor: Colors.red.withOpacity(0.2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final bool hasSession;

  const MainNavigation({super.key, required this.hasSession});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Cargar datos iniciales cuando el usuario esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AppProvider>();
      if (provider.currentUser != null) {
        provider.loadResources();
        provider.loadMaps();
        provider.loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0: return const HomeScreen();
      case 1: return const MapsScreen();
      case 2: return const TGCFScreen();
      case 3: return const PremiumScreen();
      case 4: return const SettingsScreen();
      default: return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(_selectedIndex),
      bottomNavigationBar: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            backgroundColor: const Color(0xFF0A0A0A),
            indicatorColor: Colors.red.withOpacity(_pulseAnimation.value),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            height: 70,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                label: 'Mapas',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center),
                label: 'TGCF',
              ),
              NavigationDestination(
                icon: Icon(Icons.workspace_premium_outlined),
                label: 'Premium',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'Ajustes',
              ),
            ],
          );
        },
      ),
    );
  }
}
