import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import 'admin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AJUSTES', style: GoogleFonts.orbitron(letterSpacing: 2, color: Colors.red)),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Perfil de usuario
          Card(
            color: const Color(0xFF0A0A0A),
            child: Consumer<AppProvider>(
              builder: (context, provider, _) {
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    provider.currentUser?.username ?? 'NO IDENTIFICADO',
                    style: GoogleFonts.orbitron(color: Colors.white, letterSpacing: 1),
                  ),
                  subtitle: Text('Toca para cambiar nombre', style: TextStyle(color: Colors.grey[600])),
                  onTap: () => _showChangeNameDialog(context),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Opciones
          Card(
            color: const Color(0xFF0A0A0A),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.red),
                  title: Text('DESCARGAS', style: GoogleFonts.orbitron(color: Colors.white, letterSpacing: 1)),
                  subtitle: const Text('Ver archivos descargados'),
                  onTap: () {
                    // Navegar a descargas - TODO: implementar pantalla de descargas
                  },
                ),
                const Divider(color: Color(0xFF222222)),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                  title: Text('PANEL ADMIN', style: GoogleFonts.orbitron(color: Colors.white, letterSpacing: 1)),
                  subtitle: const Text('Gestión de recursos y mapas'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    );
                  },
                ),
                const Divider(color: Color(0xFF222222)),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.red),
                  title: Text('ACERCA DE', style: GoogleFonts.orbitron(color: Colors.white, letterSpacing: 1)),
                  subtitle: const Text('Versión 1.0.0'),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Cerrar sesión
          Card(
            color: const Color(0xFF0A0A0A),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text('CERRAR SESIÓN', style: GoogleFonts.orbitron(color: Colors.red, letterSpacing: 1)),
              onTap: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeNameDialog(BuildContext context) {
    final controller = TextEditingController(
      text: context.read<AppProvider>().currentUser?.username ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text('CAMBIAR NOMBRE', style: GoogleFonts.orbitron(color: Colors.red)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nombre de usuario',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await context.read<AppProvider>().setUser(name);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text('CERRAR SESIÓN', style: GoogleFonts.orbitron(color: Colors.red)),
        content: const Text('¿Seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AppProvider>().logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sesión cerrada'),
            backgroundColor: const Color(0xFF0A0A0A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        // Navegar al home para refrescar la UI
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text('ALFAZULU', style: GoogleFonts.orbitron(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gestión de recursos militares', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            Text('Versión: 1.0.0', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Admin: admin / 1936', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://github.com');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.code),
              label: const Text('GitHub'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }
}
