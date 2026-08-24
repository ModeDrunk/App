import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../drunk-mode/providers/drunk_mode_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import 'dart:math' as math;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(drunkModeProvider.notifier).checkCurrentStatus();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _activateMode() async {
    final success = await ref.read(drunkModeProvider.notifier).activate();
    if (success && mounted) {
      context.go(AppRoutes.activeMode);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al activar el modo',
              style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final drunkState = ref.watch(drunkModeProvider);
    final userName = authState.userEmail?.split('@').first ?? 'Usuario';
    final displayName = userName.isNotEmpty
        ? userName[0].toUpperCase() + userName.substring(1)
        : 'Usuario';

    final bool isActive = drunkState.isActive;
    final Color ringColor =
        isActive ? const Color(0xFFFF3B30) : const Color(0xFF22C97A);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.3,
            colors: [
              Color(0xFF1A1A4E),
              Color(0xFF0A0B1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¡Hola, $displayName!',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF13132E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2A2A4A),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF8888AA),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      // ── Card estado ──────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13132E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2A2A4A),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estado actual',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF8888AA),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isActive ? 'MODO ACTIVO' : 'MODO INACTIVO',
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: ringColor,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isActive
                                  ? 'Protección activa — no estás en condiciones óptimas'
                                  : 'Estás en condiciones normales',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF8888AA),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Botón de poder animado ───────────────────
                      GestureDetector(
                        onTap: drunkState.isLoading
                            ? null
                            : (isActive
                                ? () => context.go(AppRoutes.pin)
                                : _activateMode),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: ringColor.withOpacity(
                                            0.15 * _pulseAnimation.value),
                                        blurRadius: 40,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                CustomPaint(
                                  size: const Size(170, 170),
                                  painter: _RingPainter(
                                    color: ringColor,
                                    progress: _pulseAnimation.value,
                                    isActive: isActive,
                                  ),
                                ),
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0E0E2A),
                                    border: Border.all(
                                      color: ringColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: drunkState.isLoading
                                      ? Center(
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: ringColor,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.power_settings_new_rounded,
                                          size: 54,
                                          color: ringColor,
                                        ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Text(
                        isActive
                            ? 'Toca para desactivar\nModo Borracho'
                            : 'Toca para activar\nModo Borracho',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF8888AA),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Quick actions ────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.group_outlined,
                              label: 'Contactos\nseguros',
                              onTap: () => context.go(AppRoutes.contacts),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.history_rounded,
                              label: 'Historial\nde sesiones',
                              onTap: () => context.go(AppRoutes.history),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),

              // ── Bottom Navigation ────────────────────────────────
              _BottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pintor del anillo animado ──────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isActive;

  const _RingPainter({
    required this.color,
    required this.progress,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final trackPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final sweepAngle =
        2 * math.pi * (isActive ? progress : (0.7 + 0.3 * progress));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.isActive != isActive;
}

// ── Tarjeta de acción rápida ───────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF13132E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF2A2A4A),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7B7BFF), size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barra de navegación inferior ──────────────────────────────────────────
class _BottomNavBar extends StatefulWidget {
  @override
  State<_BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<_BottomNavBar> {
  int _selected = 0;

  final _items = const [
    _NavItem(icon: Icons.home_rounded, label: 'Inicio', route: AppRoutes.home),
    _NavItem(icon: Icons.map_outlined, label: 'Mapa', route: null),
    _NavItem(
        icon: Icons.group_outlined,
        label: 'Contactos',
        route: AppRoutes.contacts),
    _NavItem(
        icon: Icons.history_rounded,
        label: 'Historial',
        route: AppRoutes.history),
    _NavItem(
        icon: Icons.person_outline_rounded,
        label: 'Perfil',
        route: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E26),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A4A), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final selected = i == _selected;
          final item = _items[i];
          return GestureDetector(
            onTap: () {
              setState(() => _selected = i);
              if (item.route != null) {
                context.go(item.route!);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 24,
                    color: selected
                        ? const Color(0xFF7B7BFF)
                        : const Color(0xFF555577),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? const Color(0xFF7B7BFF)
                          : const Color(0xFF555577),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String? route;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
