import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../providers/app_provider.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<Map<String, dynamic>> _downloads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    setState(() => _isLoading = true);
    try {
      // Obtener historial de descargas del usuario
      final provider = context.read<AppProvider>();
      final userId = provider.currentUser?.id;

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${AppProvider.apiUrl}/downloads/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _downloads = (data['downloads'] as List)
              .map((d) => Map<String, dynamic>.from(d))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading downloads: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DESCARGAS', style: GoogleFonts.orbitron(letterSpacing: 2, color: Colors.red)),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _downloads.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_off, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 24),
          Text(
            'NO HAY DESCARGAS',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              color: Colors.grey[600],
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus descargas aparecerán aquí',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _downloads.length,
      itemBuilder: (context, index) {
        final download = _downloads[index];
        final resource = download['resource'] ?? {};
        final downloadDate = download['downloaded_at'] != null
            ? DateTime.tryParse(download['downloaded_at'].toString())
            : null;

        return Card(
          color: const Color(0xFF0A0A0A),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(resource['file_type']),
                color: Colors.red,
                size: 24,
              ),
            ),
            title: Text(
              resource['name'] ?? 'Recurso desconocido',
              style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  resource['category'] ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
                if (downloadDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Descargado: ${_formatDate(downloadDate)}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 10),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download, color: Colors.red, size: 20),
              onPressed: () => _downloadAgain(resource),
            ),
          ),
        );
      },
    );
  }

  IconData _getFileIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'png':
      case 'jpeg':
        return Icons.image;
      case 'kml':
      case 'kmz':
      case 'gpx':
        return Icons.map;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadAgain(Map<String, dynamic> resource) async {
    final resourceId = resource['id'];
    if (resourceId == null) return;

    final provider = context.read<AppProvider>();
    final result = await provider.downloadResource(resourceId);

    if (result != null && mounted) {
      final url = result['download_url'];
      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.download);
        }
      }
    }
  }
}
