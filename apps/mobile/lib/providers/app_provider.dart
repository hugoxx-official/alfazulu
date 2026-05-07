import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/resource.dart';
import '../models/map.dart';
import '../models/user.dart';

class AppProvider extends ChangeNotifier {
  // URL del backend - Backend desplegado en Railway
  static String get apiUrl {
    return 'https://backend-api-production-0cd8.up.railway.app/api';
  }

  User? _currentUser;
  List<Resource> _resources = [];
  List<MapResource> _maps = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoadedInitialSession = false;

  // Getters
  User? get currentUser => _currentUser;
  List<Resource> get resources => _resources;
  List<MapResource> get maps => _maps;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoadedSession => _hasLoadedInitialSession;

  // Cargar usuario desde SharedPreferences (sesión permanente)
  Future<bool> loadUser() async {
    if (_hasLoadedInitialSession) return _currentUser != null;

    try {
      // Timeout para evitar freeze si SharedPreferences falla
      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance().timeout(
          const Duration(seconds: 5),
        );
      } on TimeoutException {
        print('Timeout cargando SharedPreferences');
        _hasLoadedInitialSession = true;
        notifyListeners();
        return false;
      }

      final userId = prefs.getString('user_id');
      final username = prefs.getString('username');

      print('Cargando sesión: userId=$userId, username=$username');

      if (userId != null && userId.isNotEmpty && username != null && username.isNotEmpty) {
        _currentUser = User(
          id: userId,
          username: username,
          favorites: prefs.getStringList('favorites') ?? [],
        );
        print('Sesión cargada exitosamente: ${_currentUser!.username}');
      } else {
        print('No hay sesión guardada');
      }

      _hasLoadedInitialSession = true;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _error = 'Error al cargar usuario: $e';
      print('Error cargando sesión: $e');
      _hasLoadedInitialSession = true;
      notifyListeners();
      return false;
    }
  }

  // Verificar si existe sesión (sin cargar)
  Future<bool> hasExistingSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final username = prefs.getString('username');
      return userId != null && username != null;
    } catch (e) {
      return false;
    }
  }

  // Crear/actualizar usuario (persiste la sesión)
  Future<void> setUser(String username) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Enviando usuario: $username a $apiUrl/users');

      final response = await http.post(
        Uri.parse('$apiUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      print('Respuesta status: ${response.statusCode}');
      print('Respuesta body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Datos decodificados: $data');

        final userId = data['user']?['id']?.toString();
        final username = data['user']?['username'];

        if (userId == null || username == null) {
          _error = 'Respuesta inválida del servidor';
          print('Error: userId=$userId, username=$username');
          _isLoading = false;
          notifyListeners();
          return;
        }

        _currentUser = User(
          id: userId,
          username: username,
          favorites: [],
        );

        print('Usuario creado: ${_currentUser!.id} - ${_currentUser!.username}');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', _currentUser!.id);
        await prefs.setString('username', _currentUser!.username);
        await prefs.setStringList('favorites', []);
        await prefs.setBool('app_initialized', true);

        print('SharedPreferences guardados');

        _hasLoadedInitialSession = true;
        notifyListeners();
      } else {
        _error = 'Error al crear usuario: ${response.statusCode}';
        print('Error: ${response.statusCode}');
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      print('Excepción: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cerrar sesión (solo borra si el usuario lo pide explícitamente)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    _hasLoadedInitialSession = true;
    notifyListeners();
  }

  // Cargar recursos
  Future<void> loadResources({String? category}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final url = category != null && category.isNotEmpty && category != 'Todos'
          ? '$apiUrl/resources?category=$category'
          : '$apiUrl/resources';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _resources = (data['resources'] as List)
            .map((r) => Resource.fromJson(r))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al cargar recursos: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar mapas
  Future<void> loadMaps() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse('$apiUrl/maps'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _maps = (data['maps'] as List)
            .map((m) => MapResource.fromJson(m))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al cargar mapas: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar categorías
  Future<void> loadCategories() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/admin/categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _categories = List<String>.from(data['categories']);
        notifyListeners();
      }
    } catch (e) {
      // Error loading categories
    }
  }

  // Toggle favorito
  Future<void> toggleFavorite(String resourceId, bool isFavorite) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/resources/$resourceId/favorite'),
      );

      if (response.statusCode == 200) {
        await loadResources();
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
    }
  }

  // Descargar recurso (registra y devuelve URL para descarga real)
  Future<Map<String, String>?> downloadResource(String resourceId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/downloads'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _currentUser?.id ?? 'anonymous',
          'resource_id': resourceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String downloadUrl = data['download_url'] ?? '';

        // Si la URL es relativa (archivo subido localmente), convertir a absoluta
        if (downloadUrl.startsWith('/uploads/')) {
          // Reemplazar /api con /uploads en la URL base
          final baseUrl = apiUrl.replaceAll('/api', '');
          downloadUrl = '$baseUrl$downloadUrl';
        }

        return {
          'download_url': downloadUrl,
          'file_name': data['file_name'] ?? 'download',
        };
      }
    } catch (e) {
      _error = 'Error al registrar descarga: $e';
      notifyListeners();
    }
    return null;
  }

  // Buscar recursos
  Future<void> searchResources(String query) async {
    if (query.isEmpty) {
      loadResources();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/resources?search=$query'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _resources = (data['resources'] as List)
            .map((r) => Resource.fromJson(r))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error en búsqueda: $e';
      notifyListeners();
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
