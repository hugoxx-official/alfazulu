import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../widgets/resource_card.dart';
import '../widgets/user_dialog.dart';
import '../widgets/add_resource_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Todos';
  List<String> _categories = ['Todos'];
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

    // Cargar recursos y categorías cuando el usuario esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AppProvider>();
      // Escuchar cambios primero ANTES de verificar estado actual
      p.addListener(() {
        if (p.currentUser != null && p.resources.isEmpty && !p.isLoading) {
          p.loadResources();
        }
        // Actualizar categorías cuando se carguen
        if (p.categories.isNotEmpty) {
          setState(() {
            _categories = ['Todos', ...p.categories];
          });
        }
      });
      // Cargar recursos y categorías solo si ya hay usuario cargado
      if (p.currentUser != null) {
        p.loadResources();
        p.loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ALFAZULU',
            style: GoogleFonts.orbitron(
                letterSpacing: 4,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                  )
                ])),
        actions: [
          Consumer<AppProvider>(builder: (context, provider, _) {
            if (provider.currentUser != null) {
              final isPremium = provider.currentUser!.isPremium;
              final premiumPlan = provider.currentUser!.premiumPlan;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(children: [
                  if (isPremium) ...[
                    _buildPlanIcon(premiumPlan),
                    const SizedBox(width: 6),
                  ],
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(_pulseAnimation.value),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(color: Colors.red, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.person, size: 16, color: Colors.white),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.currentUser!.username,
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ]),
              );
            }
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person_outline, size: 20, color: Colors.red),
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const UserDialog(),
              ),
            );
          })
        ],
      ),
      floatingActionButton: Consumer<AppProvider>(builder: (context, provider, _) {
        if (provider.currentUser == null) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) => const AddResourceDialog(),
            );
            if (result == true) {
              // Recargar recursos después de añadir uno nuevo
              provider.loadResources();
            }
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('AÑADIR'),
        );
      }),
      body: Consumer<AppProvider>(builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildLoading(context);
        }
        if (provider.currentUser == null) return _buildWelcome(context);
        return RefreshIndicator(
          onRefresh: () => provider.loadResources(),
          color: Colors.red,
          backgroundColor: const Color(0xFF0A0A0A),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'EXPLORAR',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryFilter(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              provider.resources.isEmpty
                  ? _buildEmpty(context)
                  : _buildGrid(context, provider),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(_pulseAnimation.value),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(_pulseAnimation.value * 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security,
                  size: 60,
                  color: Colors.red,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            'CARGANDO RECURSOS...',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              color: Colors.grey[600],
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
              if (category == 'Todos') {
                context.read<AppProvider>().loadResources();
              } else {
                context.read<AppProvider>().loadResources(category: category);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.red.withOpacity(0.7),
                        ],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.red : const Color(0xFF222222),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.red.withOpacity(0.2 * _pulseAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(_pulseAnimation.value),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.red,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              'BIENVENIDO A ALFAZULU',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'GESTION DE RECURSOS MILITARES',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const UserDialog(),
              ),
              icon: const Icon(Icons.login),
              label: Text('INGRESAR',
                  style: GoogleFonts.orbitron(letterSpacing: 2)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 18,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildEmpty(BuildContext context) => SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox,
                  size: 64,
                  color: Colors.red.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'NO HAY RECURSOS',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  color: Colors.grey[600],
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Los recursos aparecerán aquí cuando estén disponibles',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ],
          ),
        ),
      );

  Widget _buildGrid(BuildContext context, AppProvider provider) {
    final resources = _selectedCategory == 'Todos'
        ? provider.resources
        : provider.resources
            .where((r) => r.category == _selectedCategory)
            .toList();

    if (resources.isEmpty) return _buildNoResults(context);

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.crossAxisExtent;

        // Responsive breakpoints
        int crossAxisCount;
        double childAspectRatio;
        double horizontalPadding;
        double crossAxisSpacing;
        double mainAxisSpacing;

        if (maxWidth < 600) {
          // Mobile
          crossAxisCount = 2;
          childAspectRatio = 0.75;
          horizontalPadding = 16;
          crossAxisSpacing = 12;
          mainAxisSpacing = 12;
        } else if (maxWidth < 1200) {
          // Tablet
          crossAxisCount = 3;
          childAspectRatio = 0.8;
          horizontalPadding = 24;
          crossAxisSpacing = 16;
          mainAxisSpacing = 16;
        } else {
          // Desktop
          crossAxisCount = 4;
          childAspectRatio = 0.85;
          horizontalPadding = 32;
          crossAxisSpacing = 20;
          mainAxisSpacing = 20;
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ResourceCard(resource: resources[index]),
              childCount: resources.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResults(BuildContext context) => SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 16),
              Text(
                'SIN RESULTADOS',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  color: Colors.grey[600],
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildPlanIcon(String? plan) {
    IconData icon;
    Color color;
    switch (plan?.toLowerCase()) {
      case 'premium_plus':
        icon = Icons.workspace_premium;
        color = Colors.red;
        break;
      case 'premium':
        icon = Icons.star;
        color = Colors.amber;
        break;
      default:
        icon = Icons.shield;
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
