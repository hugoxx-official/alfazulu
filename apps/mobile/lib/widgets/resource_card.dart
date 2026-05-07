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
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered ? 8 : 2,
          shadowColor: Colors.red.withOpacity(_isHovered ? 0.4 : 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isHovered
                  ? Colors.red.withOpacity(0.8)
                  : Colors.red.withOpacity(0.3),
              width: _isHovered ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => _showDetail(context),
            onLongPress: () => _showOptions(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(context, isDesktop),
                _buildContent(context, isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, bool isDesktop) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          height: isDesktop ? 160 : 140,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.withOpacity(0.3 * _pulseAnimation.value),
                Colors.red.withOpacity(0.1),
                Colors.black,
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
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
              // Overlay gradiente
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Badge tipo de archivo
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red, Colors.red.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.resource.fileType.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              // Badge categoría
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCategoryEmoji(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.resource.category.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(_pulseAnimation.value),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(_pulseAnimation.value * 0.5),
                      blurRadius: 20 * _pulseAnimation.value,
                      spreadRadius: 2 * _pulseAnimation.value,
                    ),
                  ],
                ),
                child: Icon(
                  _getFileTypeIcon(),
                  size: 40,
                  color: Colors.red,
                ),
              );
            },
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

  Widget _buildContent(BuildContext context, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del recurso
          Text(
            widget.resource.name,
            style: GoogleFonts.orbitron(
              fontSize: isDesktop ? 14 : 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Info: tamaño y favoritos
          Row(
            children: [
              // Tamaño del archivo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _getFormattedSize(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Botón descarga
              GestureDetector(
                onTap: _isDownloading ? null : () => _downloadResource(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isDownloading
                        ? Colors.grey[900]
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isDownloading
                          ? Colors.grey[700]!
                          : Colors.red.withOpacity(0.5),
                      width: 1,
                    ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFormattedSize() {
    final size = widget.resource.fileSize;
    if (size == null) return 'N/A';
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
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
      case 'shp':
      case 'geojson':
        return Icons.layers;
      case 'mbtiles':
      case 'gpkg':
        return Icons.folder;
      case 'dted':
      case 'cadrg':
        return Icons.public;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getCategoryEmoji() {
    switch (widget.resource.category.toLowerCase()) {
      case 'mapas':
      case 'maps':
        return '🗺️';
      case 'tccc':
        return '🏥';
      case 'transmisiones':
      case 'transmissions':
        return '📻';
      case 'manuales':
      case 'manuals':
        return '📖';
      case 'documentation':
        return '📄';
      default:
        return '📦';
    }
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
