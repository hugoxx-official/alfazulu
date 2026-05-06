import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/resource.dart';
import '../providers/app_provider.dart';

class ResourceDetailScreen extends StatelessWidget {
  final Resource resource;

  const ResourceDetailScreen({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          _buildAppBar(context),
          // Contenido
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info principal
                _buildHeader(context),
                const SizedBox(height: 20),
                // Acciones
                _buildActions(context),
                const SizedBox(height: 24),
                // Descripción
                _buildDescription(context),
                const SizedBox(height: 24),
                // Metadatos
                _buildMetadata(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      foregroundColor: Theme.of(context).primaryColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.3),
                const Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getFileTypeIcon(),
                  size: 64,
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                ),
                const SizedBox(height: 12),
                Text(
                  resource.fileType.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resource.name,
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                context,
                icon: Icons.folder,
                label: resource.category,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                context,
                icon: Icons.storage,
                label: resource.formattedSize,
              ),
              const SizedBox(width: 8),
              if (resource.isFavorite)
                _buildInfoChip(
                  context,
                  icon: Icons.star,
                  label: 'Favorito',
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).primaryColor).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? Theme.of(context).primaryColor).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Theme.of(context).primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _downloadResource(context),
              icon: const Icon(Icons.download),
              label: const Text('Descargar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openUrl(context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.read<AppProvider>().toggleFavorite(resource.id, !resource.isFavorite),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: resource.isFavorite
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: resource.isFavorite
                      ? Theme.of(context).primaryColor
                      : const Color(0xFF1A1A1A),
                ),
              ),
              child: Icon(
                resource.isFavorite ? Icons.star : Icons.star_outline,
                color: resource.isFavorite
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Descripción',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: Text(
              resource.description?.isNotEmpty == true
                  ? resource.description!
                  : 'Sin descripción disponible.',
              style: GoogleFonts.rubik(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Metadatos',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: Column(
              children: [
                _buildMetadataRow(
                  context,
                  icon: Icons.file_present,
                  label: 'Tipo de archivo',
                  value: resource.fileType.toUpperCase(),
                ),
                const Divider(height: 1, color: Color(0xFF1A1A1A)),
                _buildMetadataRow(
                  context,
                  icon: Icons.category,
                  label: 'Categoría',
                  value: resource.category,
                ),
                const Divider(height: 1, color: Color(0xFF1A1A1A)),
                _buildMetadataRow(
                  context,
                  icon: Icons.storage,
                  label: 'Tamaño',
                  value: resource.formattedSize,
                ),
                const Divider(height: 1, color: Color(0xFF1A1A1A)),
                _buildMetadataRow(
                  context,
                  icon: Icons.download,
                  label: 'Descargas',
                  value: '${resource.downloadCount}',
                ),
                const Divider(height: 1, color: Color(0xFF1A1A1A)),
                _buildMetadataRow(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Agregado',
                  value: _formatDate(resource.createdAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getFileTypeIcon() {
    switch (resource.fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'png':
        return Icons.image;
      case 'kml':
      case 'kmz':
        return Icons.map;
      case 'gpx':
        return Icons.gps_fixed;
      case 'tiff':
      case 'geotiff':
        return Icons.terrain;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _downloadResource(BuildContext context) async {
    await context.read<AppProvider>().downloadResource(resource.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Descarga iniciada'),
            ],
          ),
          backgroundColor: const Color(0xFF121212),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _openUrl(BuildContext context) async {
    final url = resource.downloadUrl;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
