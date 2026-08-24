import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/design_system/glass_card.dart';
import '../../providers/drunk_mode_provider.dart';

class ActiveModeScreen extends ConsumerStatefulWidget {
  const ActiveModeScreen({super.key});

  @override
  ConsumerState<ActiveModeScreen> createState() => _ActiveModeScreenState();
}

class _ActiveModeScreenState extends ConsumerState<ActiveModeScreen> {
  late Timer _timer;
  late Duration _elapsedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _elapsedTime = const Duration(seconds: 0);
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = _elapsedTime + const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> _finalizeMode() async {
    setState(() => _isLoading = true);

    // Navegar a pantalla PIN
    if (mounted) {
      await context.push('/pin');
      // Después de volver del PIN, verificar estado
      final drunkState = ref.read(drunkModeProvider);
      if (!drunkState.isActive && mounted) {
        _timer.cancel();
        context.go(AppRoutes.home);
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
              // ── Top bar con estado ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.home),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF13132E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2A2A4A),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF8888AA),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MODO ACTIVO',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // ── Ícono de estado ──────────────────────────
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.error.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 50,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Título ────────────────────────────────────
                      Text(
                        'Protegiéndote',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'El Modo Borracho está activo',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF8888AA),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Timer Glass Card ──────────────────────────
                      GlassCard(
                        child: Column(
                          children: [
                            Text(
                              'Tiempo activo',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF8888AA),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _formatTime(_elapsedTime),
                              style: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Seguimiento en curso',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Lista de protecciones activas ─────────────
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Protecciones activas',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _ProtectionItem(
                              icon: Icons.block_outlined,
                              text: 'Apps peligrosas bloqueadas',
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _ProtectionItem(
                              icon: Icons.call_end_outlined,
                              text: 'Llamadas salientes limitadas',
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _ProtectionItem(
                              icon: Icons.notifications_active_outlined,
                              text: 'Contactos de confianza alertados',
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _ProtectionItem(
                              icon: Icons.location_on_outlined,
                              text: 'Ubicación en seguimiento',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Botón Finalizar Modo ──────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _finalizeMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            disabledBackgroundColor:
                                AppColors.error.withOpacity(0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Finalizar Modo',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widget para cada protección activa ─────────────────────────────────────
class _ProtectionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProtectionItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF22C97A)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF8888AA),
            ),
          ),
        ),
      ],
    );
  }
}
