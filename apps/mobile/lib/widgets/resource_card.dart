import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/resource.dart';
import '../providers/app_provider.dart';
import '../screens/resource_detail_screen.dart';
import '../utils/download_helper.dart';

class ResourceCard extends StatefulWidget {
  final Resource resource;

  const ResourceCard({super.key, required this.resource});

  @override
  State<ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<ResourceCard>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.red.withOpacity(_glowAnimation.value * 0.5),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => _showDetail(context),
            onLongPress: () => _showOptions(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(context),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.resource.name,
                        style: GoogleFonts.orbitron(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildCategoryChip(context),
                          const Spacer(),
                          _buildFavoriteIcon(context),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.folder_open,
                              size: 12, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text(
                            _getFormattedSize(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Spacer(),
                          _buildDownloadButton(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFormattedSize() {
    final size = widget.resource.fileSize;
    if (size == null) return 'N/A';
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Widget _buildThumbnail(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.withOpacity(0.2),
            Colors.red.withOpacity(0.05),
            Colors.black,
          ],
        ),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          if (widget.resource.thumbnailUrl != null)
            Positioned.fill(
              child: Image.network(
                widget.resource.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildIcon(context),
              ),
            )
          else
            _buildIcon(context),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                widget.resource.fileType.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileTypeIcon(),
            size: 40,
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          Text(
            widget.resource.fileType.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.red,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon() {
    switch (widget.resource.fileType.toLowerCase()) {
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

  Widget _buildCategoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getCategoryIcon(),
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            widget.resource.category,
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.red,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon() {
    switch (widget.resource.category.toLowerCase()) {
      case 'mapas':
        return '🗺️';
      case 'tccc':
        return '🏥';
      case 'transmisiones':
        return '📻';
      case 'manuales':
        return '📖';
      default:
        return '📄';
    }
  }

  Widget _buildFavoriteIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .read<AppProvider>()
          .toggleFavorite(widget.resource.id, !widget.resource.isFavorite),
      child: Icon(
        widget.resource.isFavorite ? Icons.star : Icons.star_outline,
        size: 16,
        color: widget.resource.isFavorite ? Colors.red : Colors.grey[700],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return GestureDetector(
      onTap: _isDownloading ? null : () => _downloadResource(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _isDownloading
              ? Colors.grey[900]
              : Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: _isDownloading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
            : Icon(
                Icons.download_rounded,
                size: 16,
                color: Colors.red,
              ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            ResourceDetailScreen(resource: widget.resource),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.visibility, color: Colors.red),
              title: Text('Vista previa',
                  style: GoogleFonts.orbitron(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showPreview(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.red),
              title:
                  Text('Descargar', style: GoogleFonts.orbitron(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _downloadResource(context);
              },
            ),
            ListTile(
              leading: Icon(
                widget.resource.isFavorite ? Icons.star : Icons.star_outline,
                color: Colors.red,
              ),
              title: Text(
                widget.resource.isFavorite
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
                style: GoogleFonts.orbitron(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<AppProvider>()
                    .toggleFavorite(widget.resource.id, !widget.resource.isFavorite);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPreview(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isDesktop = MediaQuery.of(context).size.shortestSide > 900;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 500 : (isTablet ? 400 : 350),
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.2),
                      Colors.black,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file,
                        size: isTablet ? 40 : 32, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.resource.name,
                            style: GoogleFonts.orbitron(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.resource.category,
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: isTablet ? 14 : 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      _getFileTypeIcon(),
                      size: isTablet ? 100 : 80,
                      color: Colors.red.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Archivo ${widget.resource.fileType.toUpperCase()}',
                      style: GoogleFonts.orbitron(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[500],
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getFormattedSize(),
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isTablet ? 14 : 12,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadResource(context),
                        icon: const Icon(Icons.download),
                        label: const Text('Descargar'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, isTablet ? 50 : 44),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openUrl(context),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Abrir'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0, isTablet ? 50 : 44),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadResource(BuildContext context) async {
    setState(() => _isDownloading = true);

    final result =
        await context.read<AppProvider>().downloadResource(widget.resource.id);

    if (context.mounted) {
      setState(() => _isDownloading = false);

      if (result != null && result['download_url'] != null) {
        // Abrir la descarga en el navegador
        await DownloadHelper.openUrl(result['download_url']!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.red),
                const SizedBox(width: 8),
                Text('Descarga iniciada: ${result['file_name']}'),
              ],
            ),
            backgroundColor: const Color(0xFF0A0A0A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Error al descargar'),
              ],
            ),
            backgroundColor: const Color(0xFF0A0A0A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _openUrl(BuildContext context) async {
    final url = widget.resource.downloadUrl;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
