import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/app_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _plans = [];
  String? _selectedPaymentType; // 'mensual' o 'vitalicio'

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${AppProvider.apiUrl}/admin/plans'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _plans = (data['plans'] as List)
              .map((p) => Map<String, dynamic>.from(p))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading plans: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int _getPlanSortValue(String? planName) {
    if (planName == null) return 0;
    switch (planName.toLowerCase()) {
      case 'free': return 0;
      case 'premium': return 1;
      case 'premium_plus': return 2;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final provider = Provider.of<AppProvider>(context);
    final isPremium = provider.currentUser?.isPremium ?? false;
    final premiumPlan = provider.currentUser?.premiumPlan;
    final subscriptionEnd = provider.currentUser?.subscriptionEnd;
    final currentPlanSort = _getPlanSortValue(premiumPlan);

    // Filtrar planes: no mostrar planes iguales o inferiores al actual
    final availablePlans = _plans.where((plan) {
      if (!isPremium) return true;
      final planSort = _getPlanSortValue(plan['plan_name']);
      return planSort > currentPlanSort;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('PREMIUM', style: GoogleFonts.orbitron(letterSpacing: 2, color: Colors.red)),
        backgroundColor: Colors.black,
        actions: [
          if (isPremium)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(premiumPlan?.toUpperCase() ?? 'PREMIUM',
                    style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.red))
        : SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Estado Premium
                Container(
                  padding: EdgeInsets.all(isTablet ? 30 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red.withOpacity(0.3),
                        Colors.red.withOpacity(0.1),
                        Colors.black,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.red.withOpacity(_pulseAnimation.value),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(_pulseAnimation.value * 0.6),
                                  blurRadius: 30 * _pulseAnimation.value,
                                  spreadRadius: 5 * _pulseAnimation.value,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.workspace_premium,
                              size: isTablet ? 80 : 60,
                              color: Colors.amber,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isPremium ? 'YA ERES PREMIUM' : 'DESBLOQUEA TODO',
                        style: GoogleFonts.orbitron(
                          fontSize: isTablet ? 28 : 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isPremium && subscriptionEnd != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Text(
                            'Activo hasta: ${_formatDate(subscriptionEnd)}',
                            style: GoogleFonts.orbitron(
                              color: Colors.amber,
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Accede a contenido exclusivo y características premium',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 16 : 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tipo de pago (solo si no es premium)
                if (!isPremium && availablePlans.isNotEmpty) ...[
                  Text(
                    'TIPO DE PAGO',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentTypeCard(
                          'MENSUAL',
                          Icons.calendar_today,
                          _selectedPaymentType == 'mensual',
                          () => setState(() => _selectedPaymentType = 'mensual'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentTypeCard(
                          'VITALICIO',
                          Icons.lock,
                          _selectedPaymentType == 'vitalicio',
                          () => setState(() => _selectedPaymentType = 'vitalicio'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Planes disponibles
                if (availablePlans.isNotEmpty)
                  Text(
                    'PLANES DISPONIBLES',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  )
                else if (!isPremium)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YA TIENES EL MEJOR PLAN',
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Disfrutas de todas las características disponibles',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                ...availablePlans.map((plan) => _buildPlanCard(plan, isTablet, isPremium)),

                const SizedBox(height: 32),

                // Info - Métodos de pago
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MÉTODOS DE PAGO',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: Colors.grey[500],
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.withOpacity(0.2), Colors.purple.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.phone_iphone, color: Colors.purple, size: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BIZUM',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                                Text(
                                  'Pago rápido y seguro con Bizum',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Al solicitar un plan, el administrador te contactará por Telegram con los datos de pago.',
                        style: TextStyle(color: Colors.grey[700], fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPaymentTypeCard(String type, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Colors.purple, Colors.purple.withOpacity(0.7)])
              : null,
          color: isSelected ? null : const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey[800]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 24),
            const SizedBox(height: 8),
            Text(
              type,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[600],
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, bool isTablet, bool isPremium) {
    final planName = plan['plan_name'] ?? '';
    final displayName = plan['display_name'] ?? 'Unknown';
    final price = plan['price'] ?? '';
    final color = plan['color'] ?? '#666666';
    final features = (plan['features'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final limitations = (plan['limitations'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(int.parse(color.replaceFirst('#', '0xFF'))), Colors.black],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            // Header del plan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.orbitron(
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: GoogleFonts.orbitron(
                        fontSize: isTablet ? 28 : 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ventajas
            if (features.isNotEmpty) ...[
              _buildSectionTitle('VENTAJAS', Colors.green),
              const SizedBox(height: 12),
              ...features.map((feature) => _buildFeatureItem(feature, Colors.green, isTablet)),
            ],

            // Limitaciones
            if (limitations.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionTitle('LIMITACIONES', Colors.orange),
              const SizedBox(height: 12),
              ...limitations.map((limit) => _buildFeatureItem(limit, Colors.orange, isTablet, isLimitation: true)),
            ],

            const SizedBox(height: 20),

            // Botón de solicitud
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _requestPlan(displayName, planName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'SOLICITAR ${displayName.toUpperCase()}',
                  style: GoogleFonts.orbitron(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text, Color color, bool isTablet, {bool isLimitation = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isLimitation ? Icons.cancel : Icons.check_circle,
            color: color,
            size: isTablet ? 18 : 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isLimitation ? Colors.orange : Colors.grey[300],
                fontSize: isTablet ? 13 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _requestPlan(String displayName, String planName) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final userId = provider.currentUser?.id;
    final username = provider.currentUser?.username ?? 'Unknown';

    if (userId == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text('SOLICITAR $displayName', style: GoogleFonts.orbitron(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Se enviará una solicitud al administrador.',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              'Método de pago: Bizum',
              style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
            ),
            if (_selectedPaymentType != null)
              Text(
                'Tipo: ${_selectedPaymentType!.toUpperCase()}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendPremiumRequest(userId, username, displayName, planName);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ENVIAR SOLICITUD'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPremiumRequest(String userId, String username, String displayName, String planName) async {
    try {
      final response = await http.post(
        Uri.parse('${AppProvider.apiUrl}/admin/premium-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'username': username,
          'plan_name': displayName,
          'payment_method': 'Bizum - ${_selectedPaymentType ?? 'No especificado'}',
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Solicitud enviada. El admin te contactará por Telegram.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
