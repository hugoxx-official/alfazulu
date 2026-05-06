import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// Helper para abrir URLs de descarga
/// En web abre en el navegador, en móvil usa aplicación externa
class DownloadHelper {
  static Future<void> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (kIsWeb) {
        // En web, abrir en el navegador (default ya abre en nueva pestaña)
        await launchUrl(uri);
      } else {
        // En móvil, usar aplicación externa
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error al abrir URL de descarga: $e');
    }
  }
}
