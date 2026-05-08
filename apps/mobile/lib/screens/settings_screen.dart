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
                final isPremium = provider.currentUser?.isPremium ?? false;
                final premiumPlan = provider.currentUser?.premiumPlan;
                final subscriptionEnd = provider.currentUser?.subscriptionEnd;
                final daysRemaining = subscriptionEnd != null
                    ? subscriptionEnd.difference(DateTime.now()).inDays
                    : null;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        provider.currentUser?.username ?? 'NO IDENTIFICADO',
                                        style: GoogleFonts.orbitron(color: Colors.white, letterSpacing: 1, fontSize: 16),
                                      ),
                                    ),
                                    if (isPremium)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.amber, Colors.orange],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(0.4),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star, color: Colors.black, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getPlanDisplayName(premiumPlan),
                                              style: GoogleFonts.orbitron(
                                                color: Colors.black,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (isPremium && subscriptionEnd != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: daysRemaining! > 7
                                          ? Colors.green.withOpacity(0.2)
                                          : daysRemaining > 0
                                              ? Colors.orange.withOpacity(0.2)
                                              : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          daysRemaining > 7
                                              ? Icons.check_circle
                                              : daysRemaining > 0
                                                  ? Icons.warning
                                                  : Icons.error,
                                          color: daysRemaining > 7
                                              ? Colors.green
                                              : daysRemaining > 0
                                                  ? Colors.orange
                                                  : Colors.red,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          daysRemaining > 0
                                              ? '$daysRemaining días restantes'
                                              : 'Expirado',
                                          style: TextStyle(
                                            color: daysRemaining > 7
                                                ? Colors.green
                                                : daysRemaining > 0
                                                    ? Colors.orange
                                                    : Colors.red,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (!isPremium)
                                  Text(
                                    'Plan gratuito',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showChangeNameDialog(context),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('CAMBIAR NOMBRE'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF333333)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
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
            const Text('Sistema profesional de gestión de recursos militares', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            const Text(
              'AlfaZulu proporciona una plataforma segura y eficiente para la distribución y control de recursos tácticos, con soporte para planes premium y gestión administrativa.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Versión', '1.0.0'),
            _buildInfoRow('Backend', 'Railway'),
            _buildInfoRow('Database', 'Supabase'),
            const SizedBox(height: 16),
            Text('© 2026 AlfaZulu. Todos los derechos reservados.', style: TextStyle(color: Colors.grey[700], fontSize: 10)),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  String _getPlanDisplayName(String? plan) {
    if (plan == null) return 'FREE';
    switch (plan.toLowerCase()) {
      case 'free': return 'FREE';
      case 'premium': return 'PREMIUM';
      case 'premium_plus': return 'PREMIUM+';
      default: return plan.toUpperCase();
    }
  }
}
