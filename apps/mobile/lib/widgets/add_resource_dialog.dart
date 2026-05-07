import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

// Wrapper para file_picker (solo mobile)
class _FileData {
  final String name;
  final int size;
  final String? extension;
  final Uint8List? bytes;
  final String? path;
  _FileData({required this.name, required this.size, this.extension, this.bytes, this.path});
}

class AddResourceDialog extends StatefulWidget {
  const AddResourceDialog({super.key});

  @override
  State<AddResourceDialog> createState() => _AddResourceDialogState();
}

class _AddResourceDialogState extends State<AddResourceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _urlController = TextEditingController();
  String _category = 'DOCUMENTATION';
  String _fileType = 'PDF';
  int _fileSize = 0;
  _FileData? _pickedFile;
  bool _isUploading = false;
  List<String> _categories = ['DOCUMENTATION'];
  final List<String> _fileTypes = ['PDF', 'JPG', 'PNG', 'KML', 'GPX', 'KMZ', 'TIFF', 'GEOTIFF', 'SHP', 'GEOJSON', 'MBTILES', 'GPKG', 'DTED', 'CADRG'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse('${AppProvider.apiUrl}/admin/categories'));
      if (response.statusCode == 200) {
        setState(() => _categories = List<String>.from(jsonDecode(response.body)['categories']));
      }
    } catch (e) {
      // Use default categories
    }
  }

  Future<void> _pickFile() async {
    // Web no soporta file_picker - usar URL
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En web, usa la URL de descarga directa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // Mobile: usar file_picker (importarlo dinámicamente)
    try {
      // El código de file_picker solo se ejecuta en mobile
      // En web esta función retorna antes
      throw UnimplementedError('File picker solo disponible en mobile');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // En web, solo permitir URL
      if (kIsWeb || _pickedFile == null) {
        // Save with URL only
        final body = {
          'name': _nameController.text,
          'description': _descController.text,
          'category': _category,
          'file_type': _fileType,
          'file_size': _fileSize,
          'download_url': _urlController.text,
        };

        final response = await http.post(
          Uri.parse('${AppProvider.apiUrl}/resources'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recurso añadido exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al añadir recurso: ${response.statusCode}'),
                backgroundColor: Colors.red,
              ),
            );
          }
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
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0A0A0A),
      title: Text('AÑADIR RECURSO', style: GoogleFonts.orbitron(color: Colors.red)),
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
