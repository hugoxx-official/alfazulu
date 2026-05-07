import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/tgcf_tables.dart';

class TGCFScreen extends StatefulWidget {
  const TGCFScreen({super.key});

  @override
  State<TGCFScreen> createState() => _TGCFScreenState();
}

class _TGCFScreenState extends State<TGCFScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _pushupsController = TextEditingController();
  final _situpsController = TextEditingController();
  final _cavController = TextEditingController();
  final _run6000Controller = TextEditingController();

  String _gender = 'M';
  int _ageGroupIndex = 0; // 17-21
  Map<String, dynamic>? _result;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _ageGroups = [
    '17-21', '22-26', '27-31', '32-36', '37-41',
    '42-46', '47-51', '52-56', '57-61', '62+'
  ];

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
    _pushupsController.dispose();
    _situpsController.dispose();
    _cavController.dispose();
    _run6000Controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _calculateTGCF() {
    if (!_formKey.currentState!.validate()) return;

    try {
      final pushups = int.tryParse(_pushupsController.text) ?? 0;
      final situps = int.tryParse(_situpsController.text) ?? 0;
      final cavTime = double.tryParse(_cavController.text.replaceAll(',', '.')) ?? 99.9;

      // Parsear tiempo 6000m (formato MM:SS o solo segundos)
      int runSeconds = 999;
      final runText = _run6000Controller.text.trim();
      if (runText.contains(':')) {
        final parts = runText.split(':');
        final mins = int.tryParse(parts[0]) ?? 0;
        final secs = int.tryParse(parts[1]) ?? 0;
        runSeconds = mins * 60 + secs;
      } else {
        runSeconds = int.tryParse(runText) ?? 999;
      }

      // Calcular puntos usando tablas oficiales
      final result = TGCFTables.calculateTotal(
        pushups: pushups,
        situps: situps,
        cavTime: cavTime,
        run6000Seconds: runSeconds,
        ageGroupIndex: _ageGroupIndex,
        sex: _gender,
      );

      // Determinar color según nivel
      Color levelColor;
      switch (result['level']) {
        case 'EXCELENTE': levelColor = Colors.green; break;
        case 'MUY BUENO': levelColor = Colors.lightGreen; break;
        case 'BUENO': levelColor = Colors.orange; break;
        case 'REGULAR': levelColor = Colors.orangeAccent; break;
        default: levelColor = Colors.red;
      }

      setState(() {
        _result = {
          'total': result['total'],
          'max': result['max'],
          'percentage': result['percentage'],
          'level': result['level'],
          'levelColor': levelColor,
          'message': result['message'],
          'details': result['details'],
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al calcular: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('TGCF', style: GoogleFonts.orbitron(letterSpacing: 2, color: Colors.red)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.withOpacity(0.2), Colors.black],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
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
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(Icons.fitness_center, size: isTablet ? 60 : 40, color: Colors.red),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TEST GENERAL DE CONDICIÓN FÍSICA',
                    style: GoogleFonts.orbitron(
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Baremo oficial Ejército de Tierra',
                    style: TextStyle(color: Colors.grey[600], fontSize: isTablet ? 14 : 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Selector género y edad
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    dropdownColor: const Color(0xFF0A0A0A),
                    decoration: InputDecoration(
                      labelText: 'GÉNERO',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Masculino')),
                      DropdownMenuItem(value: 'F', child: Text('Femenino')),
                    ],
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _ageGroupIndex,
                    dropdownColor: const Color(0xFF0A0A0A),
                    decoration: InputDecoration(
                      labelText: 'EDAD',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: _ageGroups.asMap().entries.map((e) =>
                      DropdownMenuItem(value: e.key, child: Text('${e.value} años'))
                    ).toList(),
                    onChanged: (v) => setState(() => _ageGroupIndex = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Formulario
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildExerciseField(
                    'Flexiones de brazos (2 min)',
                    _pushupsController,
                    'repeticiones',
                    Icons.fitness_center,
                  ),
                  const SizedBox(height: 12),
                  _buildExerciseField(
                    'Abdominales en 2 min',
                    _situpsController,
                    'repeticiones',
                    Icons.self_improvement,
                  ),
                  const SizedBox(height: 12),
                  _buildExerciseField(
                    'Circuito CAV (segundos)',
                    _cavController,
                    'ej: 15.3',
                    Icons.timer,
                    isTime: false,
                  ),
                  const SizedBox(height: 12),
                  _buildExerciseField(
                    'Carrera 6000m (MM:SS)',
                    _run6000Controller,
                    'ej: 24:30',
                    Icons.directions_run,
                    isTime: true,
                  ),
                  const SizedBox(height: 20),

                  // Botón calcular
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateTGCF,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('CALCULAR TGCF', style: GoogleFonts.orbitron(letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),

            // Resultados
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResults(isTablet),
            ],

            const SizedBox(height: 32),

            // Info mínimo BRIPAC
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MÍNIMO BRIPAC',
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'Se requieren 310 puntos mínimos para apto en BRIPAC',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseField(String label, TextEditingController controller, String hint, IconData icon, {bool isTime = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isTime ? TextInputType.datetime : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.red.withOpacity(0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (isTime && !v.contains(':') && double.tryParse(v) == null) return 'Formato inválido';
        if (!isTime && double.tryParse(v.replaceAll(',', '.')) == null) return 'Número inválido';
        return null;
      },
    );
  }

  Widget _buildResults(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.1), Colors.black],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Puntuación total
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (_result!['levelColor'] as Color).withOpacity(_pulseAnimation.value),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_result!['levelColor'] as Color).withOpacity(_pulseAnimation.value * 0.5),
                      blurRadius: 30,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${_result!['total']}/${_result!['max']}',
                      style: GoogleFonts.orbitron(
                        fontSize: isTablet ? 48 : 36,
                        fontWeight: FontWeight.bold,
                        color: _result!['levelColor'] as Color,
                      ),
                    ),
                    Text(
                      '${(_result!['percentage'] as double).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _result!['level'] as String,
            style: GoogleFonts.orbitron(
              fontSize: isTablet ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: _result!['levelColor'] as Color,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _result!['message'] as String,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: isTablet ? 14 : 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Detalles por prueba
          ...(_result!['details'] as Map<String, dynamic>).entries.map((entry) =>
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          entry.value['value'].toString(),
                          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${entry.value['score']}/${entry.value['max']} pts',
                          style: const TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
