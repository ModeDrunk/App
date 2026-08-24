import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_spacing.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _shieldController;
  late AnimationController _glowController;
  late AnimationController _contentController;
  late AnimationController _orbitController;

  // Animaciones del escudo
  late Animation<double> _shieldScale;
  late Animation<double> _shieldOpacity;

  // Animación de brillo pulsante
  late Animation<double> _glowAnim;

  // Animaciones de contenido (título, botones)
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _buttonsOpacity;
  late Animation<double> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    // Escudo entra con spring
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _shieldScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.elasticOut),
    );
    _shieldOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shieldController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Glow pulsante continuo
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Órbita de puntos decorativos
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Contenido fade-in escalonado
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _buttonsSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Lanzar secuencia
    _shieldController.forward().then((_) {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _shieldController.dispose();
    _glowController.dispose();
    _contentController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.4,
            colors: [
              Color(0xFF1A1A50),
              Color(0xFF0D0D25),
              Color(0xFF0A0B1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Escudo con efectos ─────────────────────────────
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _shieldController,
                    _glowController,
                    _orbitController,
                  ]),
                  builder: (context, _) {
                    return SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Anillo de brillo exterior
                          Opacity(
                            opacity: _shieldOpacity.value,
                            child: Container(
                              width: 200 * _glowAnim.value * 0.15 + 185,
                              height: 200 * _glowAnim.value * 0.15 + 185,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5555FF)
                                        .withOpacity(0.25 * _glowAnim.value),
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Puntos orbitando
                          ...List.generate(6, (i) {
                            final angle = (i / 6) * 2 * math.pi +
                                _orbitController.value * 2 * math.pi;
                            final r = 95.0;
                            final dx = math.cos(angle) * r;
                            final dy = math.sin(angle) * r;
                            final dotOpacity =
                                (math.sin(angle) * 0.3 + 0.4).clamp(0.0, 1.0);
                            return Opacity(
                              opacity: _shieldOpacity.value * dotOpacity,
                              child: Transform.translate(
                                offset: Offset(dx, dy),
                                child: Container(
                                  width: i % 2 == 0 ? 5 : 3,
                                  height: i % 2 == 0 ? 5 : 3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF7B7BFF)
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Anillo sólido medio
                          Opacity(
                            opacity: _shieldOpacity.value,
                            child: Container(
                              width: 168,
                              height: 168,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      const Color(0xFF3A3A8A).withOpacity(0.8),
                                  width: 1,
                                ),
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF252570)
                                        .withOpacity(0.6 * _glowAnim.value),
                                    const Color(0xFF1A1A50).withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Escudo principal
                          Transform.scale(
                            scale: _shieldScale.value,
                            child: Opacity(
                              opacity: _shieldOpacity.value,
                              child: CustomPaint(
                                size: const Size(110, 120),
                                painter: _ShieldPainter(
                                  glowIntensity: _glowAnim.value,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(flex: 1),

                // ── Título ──────────────────────────────────────────
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _titleOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: Column(
                          children: [
                            Text(
                              'MODO',
                              style: GoogleFonts.inter(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'BORRACHO',
                              style: GoogleFonts.inter(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [
                                      Color(0xFF7B7BFF),
                                      Color(0xFF55AAFF),
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0, 0, 300, 50),
                                  ),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Subtítulo ───────────────────────────────────────
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _subtitleOpacity.value,
                      child: Text(
                        'Tu seguridad es nuestra prioridad',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xFF7777AA),
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),

                const Spacer(flex: 2),

                // ── Botones ─────────────────────────────────────────
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _buttonsOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _buttonsSlide.value),
                        child: Column(
                          children: [
                            // Botón Comenzar
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => context.go(AppRoutes.register),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B5EF8),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Comenzar',
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Link Iniciar sesión
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.login),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm),
                                child: Text(
                                  'Iniciar sesión',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8888CC),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pinta el escudo con degradado y brillo ─────────────────────────────────
class _ShieldPainter extends CustomPainter {
  final double glowIntensity;
  const _ShieldPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Forma del escudo
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.95, h * 0.18)
      ..cubicTo(w * 0.97, h * 0.3, w * 0.97, h * 0.55, w * 0.88, h * 0.7)
      ..cubicTo(w * 0.78, h * 0.85, w * 0.62, h * 0.94, w * 0.5, h)
      ..cubicTo(w * 0.38, h * 0.94, w * 0.22, h * 0.85, w * 0.12, h * 0.7)
      ..cubicTo(w * 0.03, h * 0.55, w * 0.03, h * 0.3, w * 0.05, h * 0.18)
      ..close();

    // Relleno degradado
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
              const Color(0xFF4040CC), const Color(0xFF5555FF), glowIntensity)!,
          Color.lerp(
              const Color(0xFF2A2A88), const Color(0xFF3A3ABB), glowIntensity)!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, fillPaint);

    // Borde brillante
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF9999FF).withOpacity(glowIntensity),
          const Color(0xFF5555CC).withOpacity(0.4),
          const Color(0xFFAAAAFF).withOpacity(glowIntensity * 0.6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, borderPaint);

    // Reflejo superior (brillo)
    final highlightPath = Path()
      ..moveTo(w * 0.3, h * 0.06)
      ..quadraticBezierTo(w * 0.5, h * 0.02, w * 0.7, h * 0.08)
      ..quadraticBezierTo(w * 0.5, h * 0.22, w * 0.3, h * 0.06);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.18 * glowIntensity)
      ..style = PaintingStyle.fill;
    canvas.drawPath(highlightPath, highlightPaint);

    // Icono copa — dibujado con líneas
    final iconPaint = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = w / 2;
    final cy = h * 0.48;
    final cr = w * 0.17;

    // Copa: dos líneas laterales curvas convergentes
    final cupPath = Path()
      ..moveTo(cx - cr, cy - cr * 1.1)
      ..cubicTo(cx - cr * 1.1, cy, cx - cr * 0.4, cy + cr * 0.8, cx, cy + cr)
      ..cubicTo(cx + cr * 0.4, cy + cr * 0.8, cx + cr * 1.1, cy, cx + cr,
          cy - cr * 1.1);

    canvas.drawPath(cupPath, iconPaint);

    // Base
    canvas.drawLine(
      Offset(cx, cy + cr),
      Offset(cx, cy + cr * 1.5),
      iconPaint,
    );
    canvas.drawLine(
      Offset(cx - cr * 0.7, cy + cr * 1.5),
      Offset(cx + cr * 0.7, cy + cr * 1.5),
      iconPaint,
    );

    // Pajita
    final strawPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx + cr * 0.2, cy - cr * 1.1),
      Offset(cx + cr * 0.55, cy - cr * 2.0),
      strawPaint,
    );

    // Bolitas del rim de la copa
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - cr, cy - cr * 1.1), 2.5, dotPaint);
    canvas.drawCircle(Offset(cx + cr, cy - cr * 1.1), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) =>
      old.glowIntensity != glowIntensity;
}
