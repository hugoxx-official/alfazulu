import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/app_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _stats;
  List<String> _categories = [];

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${AppProvider.apiUrl}/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _isAuthenticated = true);
        _loadStats();
      } else {
        setState(() => _error = 'Credenciales inválidas');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final response = await http.get(Uri.parse('${AppProvider.apiUrl}/admin/stats'));
      if (response.statusCode == 200) {
        setState(() => _stats = jsonDecode(response.body)['stats']);
      }
    } catch (e) {
      // Error loading stats
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse('${AppProvider.apiUrl}/admin/categories'));
      if (response.statusCode == 200) {
        setState(() => _categories = List<String>.from(jsonDecode(response.body)['categories']));
      }
    } catch (e) {
      // Error loading categories
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Admin', style: GoogleFonts.orbitron(letterSpacing: 2, color: Colors.red)),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            color: const Color(0xFF0A0A0A),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.admin_panel_settings, size: 64, color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  Text('ACCESO ADMIN', style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 2)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: const Icon(Icons.person, color: Colors.red),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock, color: Colors.red),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ACCEDER'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('PANEL ADMIN', style: GoogleFonts.orbitron(letterSpacing: 2, color: Colors.red)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => setState(() => _isAuthenticated = false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_stats != null)
              Column(
                children: [
                  Text('ESTADISTICAS', style: GoogleFonts.orbitron(fontSize: 18, color: Colors.red, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCard('RECURSOS', _stats!['total_resources']?.toString() ?? '0'),
                      _statCard('MAPAS', _stats!['total_maps']?.toString() ?? '0'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCard('USUARIOS', _stats!['total_users']?.toString() ?? '0'),
                      _statCard('DESCARGAS', _stats!['total_downloads']?.toString() ?? '0'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCard('PREMIUM', _stats!['premium_users']?.toString() ?? '0', Colors.amber),
                      _statCard('FREE', _stats!['free_users']?.toString() ?? '0', Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            Text('GESTION DE DATOS', style: GoogleFonts.orbitron(fontSize: 18, color: Colors.red, letterSpacing: 2)),
            const SizedBox(height: 12),
            _AdminGridItem(
              icon: Icons.folder,
              title: 'RECURSOS',
              subtitle: 'Gestionar archivos y documentos',
              onTap: () => _navigateToDataManager(context, DataManagerType.resources),
            ),
            _AdminGridItem(
              icon: Icons.map,
              title: 'MAPAS',
              subtitle: 'Gestionar mapas y overlays',
              onTap: () => _navigateToDataManager(context, DataManagerType.maps),
            ),
            const SizedBox(height: 24),
            Text('CONFIGURACION', style: GoogleFonts.orbitron(fontSize: 18, color: Colors.red, letterSpacing: 2)),
            const SizedBox(height: 12),
            _AdminGridItem(
              icon: Icons.category,
              title: 'CATEGORIAS',
              subtitle: 'Editar categorías disponibles',
              onTap: () => _showCategoriesEditor(context),
            ),
            _AdminGridItem(
              icon: Icons.insert_drive_file,
              title: 'TIPOS DE ARCHIVO',
              subtitle: 'Formatos soportados (ATAK)',
              onTap: () => _showFileTypesInfo(context),
            ),
            _AdminGridItem(
              icon: Icons.workspace_premium,
              title: 'USUARIOS PREMIUM',
              subtitle: 'Gestionar planes premium',
              onTap: () => _showPremiumManager(context),
            ),
            const SizedBox(height: 24),
            Card(
              color: const Color(0xFF0A0A0A),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text('CERRAR SESIÓN ADMIN', style: GoogleFonts.orbitron(color: Colors.red, letterSpacing: 1)),
                onTap: () => setState(() => _isAuthenticated = false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, [Color? color]) {
    return Expanded(
      child: Card(
        color: const Color(0xFF0A0A0A),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value, style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: color ?? Colors.red, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.orbitron(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDataManager(BuildContext context, DataManagerType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DataManagerScreen(type: type)),
    ).then((_) => _loadStats());
  }

  void _showCategoriesEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CategoriesEditorDialog(categories: _categories, onCategoriesChanged: (newCategories) {
        setState(() => _categories = newCategories);
      }),
    );
  }

  void _showFileTypesInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text('FORMATOS ATAK', style: GoogleFonts.orbitron(color: Colors.red)),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• KML/KMZ - Google Earth overlays', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              Text('• GPX - GPS Exchange Format', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              Text('• GeoTIFF - Mapas georreferenciados', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              Text('• MBTiles - Tiles en SQLite', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              Text('• Shapefile - ESRI vectores', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              Text('• GeoJSON - Datos geográficos', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              Text('• GeoPackage - Contenedor OGC', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              Text('• DTED - Elevación digital', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              Text('• CADRG/CIB - Mapas militares', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CERRAR')),
        ],
      ),
    );
  }

  Future<void> _showPremiumManager(BuildContext context) async {
    await showDialog(context: context, builder: (_) => const _PremiumManagerDialog());
  }
}

enum DataManagerType { resources, maps }

class DataManagerScreen extends StatefulWidget {
  final DataManagerType type;

  const DataManagerScreen({super.key, required this.type});

  @override
  State<DataManagerScreen> createState() => _DataManagerScreenState();
}

class _DataManagerScreenState extends State<DataManagerScreen> {
  List<dynamic> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final endpoint = widget.type == DataManagerType.resources ? 'resources' : 'maps';
      final response = await http.get(Uri.parse('${AppProvider.apiUrl}/admin/$endpoint'));
      if (response.statusCode == 200) {
        setState(() => _items = jsonDecode(response.body)[endpoint]);
      }
    } catch (e) {
      // Error loading items
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      final endpoint = widget.type == DataManagerType.resources ? 'resources' : 'maps';
      await http.delete(Uri.parse('${AppProvider.apiUrl}/admin/$endpoint/$id'));
      if (mounted) _loadItems();
    } catch (e) {
      // Error deleting
    }
  }

  void _showForm([dynamic item]) {
    showDialog(
      context: context,
      builder: (_) => widget.type == DataManagerType.resources
          ? _ResourceFormDialog(resource: item, onSave: _loadItems)
          : _MapFormDialog(map: item, onSave: _loadItems),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == DataManagerType.resources ? 'RECURSOS' : 'MAPAS', style: GoogleFonts.orbitron(letterSpacing: 2, color: Colors.red)),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.red.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text('SIN DATOS', style: GoogleFonts.orbitron(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return Card(
                      color: const Color(0xFF0A0A0A),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(item['name'] ?? 'Sin nombre', style: GoogleFonts.orbitron(color: Colors.white)),
                        subtitle: Text(
                          widget.type == DataManagerType.resources
                              ? item['category'] ?? 'Sin categoría'
                              : '${item['region'] ?? ''} - ${item['scale'] ?? ''}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.red),
                              onPressed: () => _showForm(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(item['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showForm,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ResourceFormDialog extends StatefulWidget {
  final dynamic resource;
  final VoidCallback onSave;

  const _ResourceFormDialog({this.resource, required this.onSave});

  @override
  State<_ResourceFormDialog> createState() => _ResourceFormDialogState();
}

class _ResourceFormDialogState extends State<_ResourceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _urlController = TextEditingController();
  String _category = 'DOCUMENTATION';
  String _fileType = 'PDF';
  int _fileSize = 0;
  dynamic _pickedFile; // Usar dynamic para evitar import de PlatformFile en web
  bool _isUploading = false;
  List<String> _categories = ['MAPS', 'TCCC', 'TRANSMISSIONS', 'MANUALS', 'DOCUMENTATION'];
  final List<String> _fileTypes = ['PDF', 'JPG', 'PNG', 'KML', 'GPX', 'KMZ', 'TIFF', 'GEOTIFF', 'SHP', 'GEOJSON', 'MBTILES', 'GPKG', 'DTED', 'CADRG'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.resource != null) {
      _nameController.text = widget.resource['name'] ?? '';
      _descController.text = widget.resource['description'] ?? '';
      _urlController.text = widget.resource['download_url'] ?? '';
      _category = widget.resource['category'] ?? 'DOCUMENTATION';
      _fileType = widget.resource['file_type'] ?? 'PDF';
      _fileSize = widget.resource['file_size'] ?? 0;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse('${AppProvider.apiUrl}/admin/categories'));
      if (response.statusCode == 200) {
        final loadedCategories = List<String>.from(jsonDecode(response.body)['categories']);
        setState(() => _categories = loadedCategories.toSet().toList());
      }
    } catch (e) {
      // Error loading categories
    }
  }

  Future<void> _pickFile() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En web, usa la URL de descarga directa'), backgroundColor: Colors.orange),
      );
      return;
    }
    // Mobile only - file_picker import conditional
    throw UnimplementedError('File picker solo en mobile');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // Web: solo URL, mobile puede usar file picker
      if (kIsWeb || _pickedFile == null) {
        final body = {
          'name': _nameController.text,
          'description': _descController.text,
          'category': _category,
          'file_type': _fileType,
          'file_size': _fileSize,
          'download_url': _urlController.text,
          'thumbnail_url': '',
        };

        if (widget.resource != null) {
          await http.put(
            Uri.parse('${AppProvider.apiUrl}/admin/resources/${widget.resource['id']}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
        } else {
          await http.post(
            Uri.parse('${AppProvider.apiUrl}/admin/resources'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
        }

        widget.onSave();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      // Error saving resource
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A0A0A),
      title: Text(widget.resource != null ? 'EDITAR RECURSO' : 'NUEVO RECURSO', style: GoogleFonts.orbitron(color: Colors.red)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categories.contains(_category) ? _category : _categories.first,
                dropdownColor: const Color(0xFF0A0A0A),
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(color: Colors.white),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _fileTypes.contains(_fileType) ? _fileType : _fileTypes.first,
                dropdownColor: const Color(0xFF0A0A0A),
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(color: Colors.white),
                items: _fileTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _fileType = v!),
              ),
              const SizedBox(height: 12),
              // File picker button
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: _pickedFile != null ? const Icon(Icons.check, color: Colors.black) : const Icon(Icons.upload_file, color: Colors.white),
                label: Text(_pickedFile != null ? 'ARCHIVO SELECCIONADO' : 'SELECCIONAR ARCHIVO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pickedFile != null ? Colors.green : Colors.red,
                  foregroundColor: _pickedFile != null ? Colors.black : Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              if (_pickedFile != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Tamaño: ${_formatSize(_fileSize)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'URL de descarga (opcional)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        ElevatedButton(
          onPressed: _isUploading ? null : _save,
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('GUARDAR'),
        ),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _MapFormDialog extends StatefulWidget {
  final dynamic map;
  final VoidCallback onSave;

  const _MapFormDialog({this.map, required this.onSave});

  @override
  State<_MapFormDialog> createState() => _MapFormDialogState();
}

class _MapFormDialogState extends State<_MapFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _urlController = TextEditingController();
  final _scaleController = TextEditingController();
  final _regionController = TextEditingController();
  String _fileType = 'PDF';
  int _fileSize = 0;
  final _fileTypes = ['PDF', 'JPG', 'PNG', 'KML', 'GPX', 'KMZ', 'TIFF', 'GEOTIFF', 'SHP', 'GEOJSON', 'MBTILES', 'GPKG', 'DTED', 'CADRG'];

  @override
  void initState() {
    super.initState();
    if (widget.map != null) {
      _nameController.text = widget.map['name'] ?? '';
      _descController.text = widget.map['description'] ?? '';
      _urlController.text = widget.map['download_url'] ?? '';
      _scaleController.text = widget.map['scale'] ?? '';
      _regionController.text = widget.map['region'] ?? '';
      _fileSize = widget.map['file_size'] ?? 0;
      _fileType = widget.map['file_type'] ?? 'PDF';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final body = {
        'name': _nameController.text,
        'description': _descController.text,
        'scale': _scaleController.text,
        'region': _regionController.text,
        'file_type': _fileType,
        'file_size': _fileSize,
        'download_url': _urlController.text,
        'thumbnail_url': '',
        'coordinates': null,
      };

      if (widget.map != null) {
        await http.put(
          Uri.parse('${AppProvider.apiUrl}/admin/maps/${widget.map['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      } else {
        await http.post(
          Uri.parse('${AppProvider.apiUrl}/admin/maps'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      }

      widget.onSave();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Error saving map
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A0A0A),
      title: Text(widget.map != null ? 'EDITAR MAPA' : 'NUEVO MAPA', style: GoogleFonts.orbitron(color: Colors.red)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _scaleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Escala',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _regionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Región',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _fileType,
                dropdownColor: const Color(0xFF0A0A0A),
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(color: Colors.white),
                items: _fileTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _fileType = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'URL de descarga',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        ElevatedButton(onPressed: _save, child: const Text('GUARDAR')),
      ],
    );
  }
}

class _AdminGridItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminGridItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0A0A0A),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: GoogleFonts.orbitron(color: Colors.white, letterSpacing: 1)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.red),
        onTap: onTap,
      ),
    );
  }
}

class _PremiumManagerDialog extends StatefulWidget {
  const _PremiumManagerDialog();

  @override
  State<_PremiumManagerDialog> createState() => _PremiumManagerDialogState();
}

class _PremiumManagerDialogState extends State<_PremiumManagerDialog> with SingleTickerProviderStateMixin {
  List<dynamic> _users = [];
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  late TabController _tabController;

  final List<String> _planTypes = ['MENSUAL', 'ANUAL', 'VITALICIO'];
  final List<String> _durations = ['1 mes', '6 meses', '1 año', 'Vitalicio'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    _loadPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    try {
      final response = await http.get(Uri.parse('${AppProvider.apiUrl}/admin/plans'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _plans = (data['plans'] as List).map((p) => Map<String, dynamic>.from(p)).toList());
      }
    } catch (e) {
      print('Error loading plans: $e');
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${AppProvider.apiUrl}/users'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _users = data['users'] ?? []);
      }
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setPremium(String userId, String plan, String duration) async {
    try {
      DateTime? endDate;
      final now = DateTime.now();
      switch (duration) {
        case '1 mes': endDate = DateTime(now.year, now.month + 1, now.day); break;
        case '6 meses': endDate = DateTime(now.year, now.month + 6, now.day); break;
        case '1 año': endDate = DateTime(now.year + 1, now.month, now.day); break;
        case 'Vitalicio': endDate = DateTime(2099, 12, 31); break;
      }

      // Mapear nombre del plan al ID correcto
      String planId = 'premium';
      if (plan == 'MENSUAL') planId = 'premium';
      if (plan == 'ANUAL') planId = 'premium_plus';
      if (plan == 'VITALICIO') planId = 'premium_plus';

      final response = await http.patch(
        Uri.parse('${AppProvider.apiUrl}/users/$userId/premium'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'is_premium': true,
          'premium_plan': planId,
          'subscription_end': endDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plan $plan activado por $duration'), backgroundColor: Colors.green),
          );
          _loadUsers();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removePremium(String userId) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppProvider.apiUrl}/users/$userId/premium'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'is_premium': false, 'premium_plan': null, 'subscription_end': null}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Premium removido'), backgroundColor: Colors.orange),
          );
          _loadUsers();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A0A0A),
      title: Row(
        children: [
          Text('GESTIONAR PREMIUM', style: GoogleFonts.orbitron(color: Colors.red)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: _addNewPlan,
            tooltip: 'Añadir plan',
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              tabs: const [
                Tab(icon: Icon(Icons.people), text: 'USUARIOS'),
                Tab(icon: Icon(Icons.workspace_premium), text: 'PLANES'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pestaña Usuarios
                  _buildUsersTab(),
                  // Pestaña Planes
                  _buildPlansTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CERRAR')),
      ],
    );
  }

  Widget _buildUsersTab() {
    if (_users.isEmpty) {
      return const Center(child: Text('No hay usuarios', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (_, i) {
        final user = _users[i];
        final isPremium = user['is_premium'] ?? false;
        final plan = user['premium_plan'];
        final subEnd = user['subscription_end'];

        return Card(
          color: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPremium ? Colors.amber : Colors.grey,
              child: Icon(isPremium ? Icons.star : Icons.person, color: Colors.black),
            ),
            title: Text(user['username'] ?? 'Sin nombre', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
            subtitle: Text(
              isPremium ? '$plan - Hasta: ${subEnd != null ? DateTime.parse(subEnd).toString().split(' ')[0] : 'N/A'}' : 'Sin premium',
              style: TextStyle(color: isPremium ? Colors.amber : Colors.grey[600], fontSize: 11),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.red),
              onSelected: (value) {
                if (value == 'remove') {
                  _removePremium(user['id']);
                } else {
                  final parts = value.split('|');
                  if (parts.length == 2) _setPremium(user['id'], parts[0], parts[1]);
                }
              },
              itemBuilder: (context) => [
                if (isPremium)
                  const PopupMenuItem(value: 'remove', child: Text('Remover Premium', style: TextStyle(color: Colors.orange)))
                else ...[
                  const PopupMenuItem(enabled: false, child: Text('Asignar plan', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  ..._planTypes.expand((plan) => _durations.map((duration) => PopupMenuItem(value: '$plan|$duration', child: Text('$plan - $duration')))),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlansTab() {
    if (_plans.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }
    return ListView.builder(
      itemCount: _plans.length,
      itemBuilder: (_, i) {
        final plan = _plans[i];
        final planId = plan['id'] ?? '';
        final planName = plan['plan_name'] ?? '';
        final displayName = plan['display_name'] ?? '';
        final priceMonthly = plan['price_monthly'] ?? '0';
        final priceLifetime = plan['price_lifetime'] ?? '0';
        final color = plan['color'] ?? '#666666';
        final features = (plan['features'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final limitations = (plan['limitations'] as List?)?.map((e) => e.toString()).toList() ?? [];

        return Card(
          color: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Color(int.parse(color.replaceFirst('#', '0xFF')))),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            priceMonthly == '0' ? 'Gratis' : '\$${priceMonthly}/mes',
                            style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white),
                          ),
                          if (priceLifetime != '0')
                            Text(
                              '\$${priceLifetime} vitalicio',
                              style: GoogleFonts.orbitron(fontSize: 10, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.red, size: 20),
                      onPressed: () => _editPlan(plan),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deletePlan(planId),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildEditableList('VENTAJAS', features, Colors.green, (newList) => _updatePlan(planId, {'features': newList})),
                const SizedBox(height: 12),
                _buildEditableList('LIMITACIONES', limitations, Colors.orange, (newList) => _updatePlan(planId, {'limitations': newList})),
              ],
            ),
          ),
        );
      },
      padding: const EdgeInsets.only(bottom: 60),
    );
  }

  Widget _buildEditableList(String title, List<String> items, Color color, Function(List<String>) onSave) {
    final controller = TextEditingController(text: items.join(', '));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.orbitron(fontSize: 11, color: color, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Separar por comas',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            final newList = controller.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
            onSave(newList);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title actualizadas'), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 36),
          ),
          child: Text('GUARDAR $title', style: GoogleFonts.orbitron(fontSize: 11)),
        ),
      ],
    );
  }

  Future<void> _updatePlan(String planId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${AppProvider.apiUrl}/admin/plans/$planId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        _loadPlans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Plan actualizado'), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
          );
        }
      }
    } catch (e) {
      print('Error updating plan: $e');
    }
  }

  Future<void> _editPlan(Map<String, dynamic> plan) async {
    final planId = plan['id'] ?? '';
    final displayNameController = TextEditingController(text: plan['display_name'] ?? '');
    final priceMonthlyController = TextEditingController(text: plan['price_monthly'] ?? '0');
    final priceLifetimeController = TextEditingController(text: plan['price_lifetime'] ?? '0');
    final colorController = TextEditingController(text: plan['color'] ?? '#666666');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text('EDITAR PLAN', style: GoogleFonts.orbitron(color: Colors.red)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: displayNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Nombre visible'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceMonthlyController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Precio mensual (ej: 4.99)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceLifetimeController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Precio vitalicio (ej: 49.99)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: colorController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Color (HEX)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updatePlan(planId, {
                'display_name': displayNameController.text,
                'price_monthly': priceMonthlyController.text,
                'price_lifetime': priceLifetimeController.text,
                'color': colorController.text,
              });
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlan(String planId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text('ELIMINAR PLAN', style: GoogleFonts.orbitron(color: Colors.red)),
        content: const Text('¿Seguro que deseas eliminar este plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await http.delete(
          Uri.parse('${AppProvider.apiUrl}/admin/plans/$planId'),
        );
        if (response.statusCode == 200) {
          _loadPlans();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Plan eliminado'), backgroundColor: Colors.green),
            );
          }
        }
      } catch (e) {
        print('Error deleting plan: $e');
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Future<void> _addNewPlan() async {
    final displayNameController = TextEditingController();
    final priceMonthlyController = TextEditingController();
    final priceLifetimeController = TextEditingController();
    final colorController = TextEditingController(text: '#666666');
    final planNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text('NUEVO PLAN', style: GoogleFonts.orbitron(color: Colors.green)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: planNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('ID (ej: premium_plus)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: displayNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Nombre visible'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceMonthlyController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Precio mensual (ej: 4.99)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceLifetimeController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Precio vitalicio (ej: 49.99)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: colorController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Color (HEX)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await http.post(
                  Uri.parse('${AppProvider.apiUrl}/admin/plans'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'plan_name': planNameController.text.toLowerCase(),
                    'display_name': displayNameController.text,
                    'price_monthly': priceMonthlyController.text,
                    'price_lifetime': priceLifetimeController.text,
                    'color': colorController.text,
                    'features': [],
                    'limitations': [],
                  }),
                );
                if (response.statusCode == 200) {
                  _loadPlans();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Plan creado'), backgroundColor: Colors.green),
                    );
                  }
                }
              } catch (e) {
                print('Error creating plan: $e');
              }
            },
            child: const Text('CREAR'),
          ),
        ],
      ),
    );
  }
}

class CategoriesEditorDialog extends StatefulWidget {
  final List<String> categories;
  final Function(List<String>) onCategoriesChanged;

  const CategoriesEditorDialog({super.key, required this.categories, required this.onCategoriesChanged});

  @override
  State<CategoriesEditorDialog> createState() => _CategoriesEditorDialogState();
}

class _CategoriesEditorDialogState extends State<CategoriesEditorDialog> {
  late List<String> _categories;
  final _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  Future<void> _addCategory() async {
    final name = _newCategoryController.text.trim().toUpperCase();
    if (name.isEmpty || _categories.contains(name)) return;

    try {
      // Guardar en backend (DB) - se sincroniza para todos los usuarios
      final response = await http.post(
        Uri.parse('${AppProvider.apiUrl}/admin/categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'categories': [..._categories, name]}),
      );

      if (response.statusCode == 200) {
        setState(() => _categories.add(name));
        _newCategoryController.clear();
        widget.onCategoriesChanged(_categories);
      } else {
        // Mostrar error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al añadir categoría: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeCategory(String category) async {
    try {
      final newCategories = _categories.where((c) => c != category).toList();

      // Actualizar en backend (DB) - se sincroniza para todos los usuarios
      final response = await http.post(
        Uri.parse('${AppProvider.apiUrl}/admin/categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'categories': newCategories}),
      );

      if (response.statusCode == 200) {
        setState(() => _categories.remove(category));
        widget.onCategoriesChanged(_categories);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar categoría'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A0A0A),
      title: Text('CATEGORIAS', style: GoogleFonts.orbitron(color: Colors.red)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCategoryController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nueva categoría',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.red),
                onPressed: _addCategory,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('CATEGORIAS DISPONIBLES:', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          ..._categories.map((c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.folder, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Text(c, style: const TextStyle(fontSize: 16, color: Colors.white)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeCategory(c),
                ),
              ],
            ),
          )),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CERRAR')),
      ],
    );
  }
}
