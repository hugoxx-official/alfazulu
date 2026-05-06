import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class TGCFScreen extends StatefulWidget {
  const TGCFScreen({super.key});

  @override
  State<TGCFScreen> createState() => _TGCFScreenState();
}

class _TGCFScreenState extends State<TGCFScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Campos del TGCF
  final _pushupsController = TextEditingController();
  final _situpsController = TextEditingController();
  final _pullupsController = TextEditingController();
  final _squatsController = TextEditingController();
  final _shuttleRunController = TextEditingController();

  String _gender = 'male';
  int? _age;
  Map<String, dynamic>? _result;

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
    _pushupsController.dispose();
    _situpsController.dispose();
    _pullupsController.dispose();
    _squatsController.dispose();
    _shuttleRunController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _calculateTGCF() {
    if (!_formKey.currentState!.validate()) return;

    try {
      final pushups = int.parse(_pushupsController.text);
      final situps = int.parse(_situpsController.text);
      final pullups = int.parse(_pullupsController.text);
      final squats = int.parse(_squatsController.text);
      final shuttleRun = double.parse(_shuttleRunController.text.replaceAll(',', '.'));

      // Puntuación TGCF (baremo militar aproximado)
      final pushupsScore = _scorePushups(pushups, _gender, _age);
      final situpsScore = _scoreSitups(situps, _gender, _age);
      final pullupsScore = _scorePullups(pullups, _gender);
      final squatsScore = _scoreSquats(squats, _gender, _age);
      final shuttleRunScore = _scoreShuttleRun(shuttleRun, _gender, _age);

      final totalScore = pushupsScore + situpsScore + pullupsScore + squatsScore + shuttleRunScore;
      final maxScore = 50;
      final percentage = (totalScore / maxScore * 100).clamp(0, 100);

      String level;
      Color levelColor;
      if (percentage >= 90) {
        level = 'EXCELENTE';
        levelColor = Colors.green;
      } else if (percentage >= 75) {
        level = 'BUENO';
        levelColor = Colors.lightGreen;
      } else if (percentage >= 60) {
        level = 'REGULAR';
        levelColor = Colors.orange;
      } else if (percentage >= 40) {
        level = 'DEFICIENTE';
        levelColor = Colors.orangeAccent;
      } else {
        level = 'MUY DEFICIENTE';
        levelColor = Colors.red;
      }

      setState(() {
        _result = {
          'total': totalScore,
          'max': maxScore,
          'percentage': percentage,
          'level': level,
          'levelColor': levelColor,
          'details': {
            'Flexiones': {'value': pushups, 'score': pushupsScore},
            'Abdominales': {'value': situps, 'score': situpsScore},
            'Dominadas': {'value': pullups, 'score': pullupsScore},
            'Sentadillas': {'value': squats, 'score': squatsScore},
            'Shuttle Run': {'value': shuttleRun, 'score': shuttleRunScore},
          },
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

  int _scorePushups(int reps, String gender, int? age) {
    if (gender == 'male') {
      if (reps >= 50) return 10;
      if (reps >= 40) return 8;
      if (reps >= 30) return 6;
      if (reps >= 20) return 4;
      if (reps >= 10) return 2;
      return 1;
    } else {
      if (reps >= 40) return 10;
      if (reps >= 30) return 8;
      if (reps >= 20) return 6;
      if (reps >= 15) return 4;
      if (reps >= 10) return 2;
      return 1;
    }
  }

  int _scoreSitups(int reps, String gender, int? age) {
    if (gender == 'male') {
      if (reps >= 60) return 10;
      if (reps >= 50) return 8;
      if (reps >= 40) return 6;
      if (reps >= 30) return 4;
      if (reps >= 20) return 2;
      return 1;
    } else {
      if (reps >= 50) return 10;
      if (reps >= 40) return 8;
      if (reps >= 30) return 6;
      if (reps >= 20) return 4;
      if (reps >= 15) return 2;
      return 1;
    }
  }

  int _scorePullups(int reps, String gender) {
    if (gender == 'male') {
      if (reps >= 15) return 10;
      if (reps >= 12) return 8;
      if (reps >= 8) return 6;
      if (reps >= 5) return 4;
      if (reps >= 3) return 2;
      return 1;
    } else {
      if (reps >= 10) return 10;
      if (reps >= 8) return 8;
      if (reps >= 5) return 6;
      if (reps >= 3) return 4;
      if (reps >= 1) return 2;
      return 1;
    }
  }

  int _scoreSquats(int reps, String gender, int? age) {
    if (gender == 'male') {
      if (reps >= 60) return 10;
      if (reps >= 50) return 8;
      if (reps >= 40) return 6;
      if (reps >= 30) return 4;
      if (reps >= 20) return 2;
      return 1;
    } else {
      if (reps >= 50) return 10;
      if (reps >= 40) return 8;
      if (reps >= 30) return 6;
      if (reps >= 20) return 4;
      if (reps >= 15) return 2;
      return 1;
    }
  }

  int _scoreShuttleRun(double time, String gender, int? age) {
    // Tiempo en segundos (ej: 20.5 = 20.5 segundos)
    if (gender == 'male') {
      if (time <= 18) return 10;
      if (time <= 20) return 8;
      if (time <= 22) return 6;
      if (time <= 25) return 4;
      if (time <= 28) return 2;
      return 1;
    } else {
      if (time <= 20) return 10;
      if (time <= 22) return 8;
      if (time <= 24) return 6;
      if (time <= 27) return 4;
      if (time <= 30) return 2;
      return 1;
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
                    'Evalúa tu condición física militar',
                    style: TextStyle(color: Colors.grey[600], fontSize: isTablet ? 14 : 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Formulario
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Género y edad
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
                            DropdownMenuItem(value: 'male', child: Text('Masculino')),
                            DropdownMenuItem(value: 'female', child: Text('Femenino')),
                          ],
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _age ?? 25,
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
                          items: List.generate(5, (i) => 20 + i * 5)
                              .expand((baseAge) => List.generate(5, (j) => baseAge + j))
                              .map((age) => DropdownMenuItem(value: age, child: Text('$age')))
                              .toList(),
                          onChanged: (v) => setState(() => _age = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ejercicios
                  _buildExerciseField('Flexiones de brazos', _pushupsController, 'repeticiones'),
                  const SizedBox(height: 12),
                  _buildExerciseField('Abdominales en 2 min', _situpsController, 'repeticiones'),
                  const SizedBox(height: 12),
                  _buildExerciseField('Dominadas', _pullupsController, 'repeticiones'),
                  const SizedBox(height: 12),
                  _buildExerciseField('Sentadillas en 2 min', _squatsController, 'repeticiones'),
                  const SizedBox(height: 12),
                  _buildExerciseField('Shuttle Run (segundos)', _shuttleRunController, 'ej: 20.5'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseField(String label, TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Número inválido';
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
          const SizedBox(height: 20),

          // Detalles por ejercicio
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
                          '${entry.value['value']}',
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
                          '+${entry.value['score']} pts',
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
