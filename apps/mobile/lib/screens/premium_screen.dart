import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  bool _isPremium = false;
  String? _subscriptionEnd;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'MENSUAL',
      'price': '4.99€',
      'period': '/mes',
      'features': [
        'Acceso ilimitado a recursos',
        'Descargas sin límites',
        'Mapas premium',
        'Soporte prioritario',
      ],
      'popular': false,
    },
    {
      'name': 'ANUAL',
      'price': '39.99€',
      'period': '/año',
      'features': [
        'Todo lo del plan mensual',
        '2 meses gratis',
        'Contenido exclusivo',
        'Actualizaciones anticipadas',
        'Badge premium',
      ],
      'popular': true,
    },
    {
      'name': 'VITALICIO',
      'price': '99.99€',
      'period': '',
      'features': [
        'Acceso de por vida',
        'Todas las features',
        'Contenido futuro incluido',
        'Soporte VIP 24/7',
        'Badge exclusivo',
      ],
      'popular': false,
    },
  ];

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

    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    // TODO: Implementar verificación real con backend
    // Por ahora, simulado
    setState(() {
      _isPremium = false;
      _subscriptionEnd = null;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('PREMIUM', style: GoogleFonts.orbitron(letterSpacing: 2, color: Colors.red)),
        backgroundColor: Colors.black,
        actions: [
          if (_isPremium)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('ACTIVO', style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                    _isPremium ? 'YA ERES PREMIUM' : 'DESBLOQUEA TODO',
                    style: GoogleFonts.orbitron(
                      fontSize: isTablet ? 28 : 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.amber,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPremium
                        ? 'Tu suscripción está activa hasta el $_subscriptionEnd'
                        : 'Accede a contenido exclusivo y características premium',
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

            // Features
            if (!_isPremium) ...[
              Text(
                'CARACTERÍSTICAS PREMIUM',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureGrid(isTablet),
              const SizedBox(height: 32),
            ],

            // Planes
            Text(
              'PLANES DISPONIBLES',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ..._plans.map((plan) => _buildPlanCard(plan, isTablet)),

            const SizedBox(height: 32),

            // Info
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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildPaymentChip(Icons.credit_card, 'Tarjeta'),
                      _buildPaymentChip(Icons.account_balance, 'PayPal'),
                      _buildPaymentChip(Icons.phone_android, 'Google Pay'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pago seguro procesado a través de Stripe. Puedes cancelar tu suscripción en cualquier momento.',
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

  Widget _buildFeatureGrid(bool isTablet) {
    final features = [
      {'icon': Icons.download_rounded, 'label': 'Descargas ilimitadas'},
      {'icon': Icons.map, 'label': 'Mapas premium'},
      {'icon': Icons.folder_special, 'label': 'Recursos exclusivos'},
      {'icon': Icons.speed, 'label': 'Sin anuncios'},
      {'icon': Icons.support, 'label': 'Soporte prioritario'},
      {'icon': Icons.security, 'label': 'Acceso anticipado'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.withOpacity(0.2),
                Colors.black,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feature['icon'] as IconData,
                color: Colors.red,
                size: isTablet ? 36 : 28,
              ),
              const SizedBox(height: 8),
              Text(
                feature['label'] as String,
                style: GoogleFonts.orbitron(
                  fontSize: isTablet ? 12 : 10,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, bool isTablet) {
    final isPopular = plan['popular'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPopular
              ? [Colors.red, Colors.red.withOpacity(0.5)]
              : [Colors.grey[800]!, Colors.grey[900]!],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['name'] as String,
                      style: GoogleFonts.orbitron(
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: isPopular ? Colors.red : Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan['price'] as String,
                      style: GoogleFonts.orbitron(
                        fontSize: isTablet ? 28 : 22,
                        fontWeight: FontWeight.w900,
                        color: isPopular ? Colors.red : Colors.white,
                      ),
                    ),
                  ],
                ),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'POPULAR',
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              plan['period'] as String,
              style: TextStyle(color: Colors.grey[600], fontSize: isTablet ? 14 : 12),
            ),
            const SizedBox(height: 16),
            ...(plan['features'] as List).map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.red, size: isTablet ? 20 : 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature as String,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: isTablet ? 14 : 13,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _purchasePlan(plan['name'] as String),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular ? Colors.red : Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'CONTRATAR',
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

  Widget _buildPaymentChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[500], size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePlan(String planName) async {
    // TODO: Implementar con Stripe/RevenueCat
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text('PRÓXIMAMENTE', style: GoogleFonts.orbitron(color: Colors.red)),
        content: Text(
          'El sistema de pagos estará disponible pronto. Por ahora, contacta con admin para acceso premium.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }
}
