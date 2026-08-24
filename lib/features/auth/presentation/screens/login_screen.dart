import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B1A),
      body: Container(
        // Fondo con gradiente azul-oscuro igual al mockup
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              Color(0xFF1A1A4E),
              Color(0xFF0A0B1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Icono escudo ──────────────────────────────
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E1E5A),
                        border: Border.all(
                          color: const Color(0xFF4040AA),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 46,
                        color: Color(0xFF7B7BFF),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Título ────────────────────────────────────
                    Text(
                      'Iniciar sesión',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bienvenido de vuelta',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF8888AA),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Email ─────────────────────────────────────
                    _buildField(
                      controller: _emailController,
                      hint: 'usuario@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu email';
                        if (!v.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Contraseña ────────────────────────────────
                    _buildField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                        child: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF6666AA),
                          size: 20,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Ingresa tu contraseña';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Recordarme / Olvidaste PIN ────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                                activeColor: const Color(0xFF6B5EF8),
                                checkColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF4040AA),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recordarme',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF8888AA),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            '¿Olvidaste tu PIN?',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF7B7BFF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Error ─────────────────────────────────────
                    if (authState.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          authState.errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // ── Botón principal ───────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B5EF8),
                          disabledBackgroundColor:
                              const Color(0xFF6B5EF8).withOpacity(0.4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Iniciar sesión',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Divisor ───────────────────────────────────
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Color(0xFF2A2A4A),
                            thickness: 0.8,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'o continúa con',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF5555AA),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Color(0xFF2A2A4A),
                            thickness: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Botón Google ──────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF12122A),
                          side: const BorderSide(
                            color: Color(0xFF2A2A4A),
                            width: 0.8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ícono G multicolor
                            _googleIcon(),
                            const SizedBox(width: 10),
                            Text(
                              'Google',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Link registro ─────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta? ',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF8888AA),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.register),
                          child: Text(
                            'Regístrate',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7B7BFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Campo de texto con estilo oscuro azulado del mockup
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF555577),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF6666AA), size: 20),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 40),
        filled: true,
        fillColor: const Color(0xFF13132E),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A4A), width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A4A), width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6B5EF8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.error),
      ),
      validator: validator,
    );
  }

  // Ícono G de Google con colores reales
  Widget _googleIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

// Pinta la G de Google con sus colores reales
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Arcos de colores
    final segments = [
      // azul — arriba-derecha
      [270.0, 90.0, const Color(0xFF4285F4)],
      // rojo — abajo-derecha
      [0.0, 90.0, const Color(0xFFEA4335)],
      // amarillo — abajo-izquierda
      [90.0, 90.0, const Color(0xFFFBBC05)],
      // verde — arriba-izquierda
      [180.0, 90.0, const Color(0xFF34A853)],
    ];

    const double strokeW = 3.5;
    final rect =
        Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeW / 2);

    for (final seg in segments) {
      final paint = Paint()
        ..color = seg[2] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        (seg[0] as double) * (3.14159265 / 180),
        (seg[1] as double) * (3.14159265 / 180),
        false,
        paint,
      );
    }

    // Barra horizontal de la G (color azul)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r - strokeW / 2, cy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
