import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _isPinVisible = false;
  bool _isConfirmPinVisible = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Acepta los términos y condiciones',
              style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: const Color(0xFF1E1E4A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Los PINs no coinciden',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.register(
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: 'Password123!', // Password por defecto para MVP
      fullName: _nameController.text.trim(),
      pinCode: _pinController.text,
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
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.8),
            radius: 1.1,
            colors: [
              Color(0xFF1A1A4E),
              Color(0xFF0A0B1A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Botón atrás ───────────────────────────────
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: Container(
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
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF8888AA),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Título ────────────────────────────────────
                  Text(
                    'Crear cuenta',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Únete y viaja protegido',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF8888AA),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Nombre completo ───────────────────────────
                  _buildField(
                    controller: _nameController,
                    hint: 'Nombre completo',
                    icon: Icons.person_outline_rounded,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Correo electrónico ────────────────────────
                  _buildField(
                    controller: _emailController,
                    hint: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Teléfono ──────────────────────────────────
                  _buildField(
                    controller: _phoneController,
                    hint: 'Teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── PIN (6 dígitos) ───────────────────────────
                  _buildField(
                    controller: _pinController,
                    hint: 'PIN de 6 dígitos',
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    obscureText: !_isPinVisible,
                    maxLength: 6,
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _isPinVisible = !_isPinVisible),
                      child: Icon(
                        _isPinVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF6666AA),
                        size: 20,
                      ),
                    ),
                    validator: Validators.validatePin,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Confirmar PIN ─────────────────────────────
                  _buildField(
                    controller: _confirmPinController,
                    hint: 'Confirmar PIN',
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    obscureText: !_isConfirmPinVisible,
                    maxLength: 6,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                        () => _isConfirmPinVisible = !_isConfirmPinVisible,
                      ),
                      child: Icon(
                        _isConfirmPinVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF6666AA),
                        size: 20,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Confirma tu PIN' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Términos ──────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: (v) =>
                              setState(() => _acceptedTerms = v ?? false),
                          activeColor: const Color(0xFF6B5EF8),
                          checkColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFF4040AA),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF8888AA),
                            ),
                            children: [
                              const TextSpan(text: 'Acepto los '),
                              TextSpan(
                                text: 'Términos y Condiciones',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF7B7BFF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

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
                            fontSize: 12, color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // ── Botón Registrarme ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _register,
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
                              'Registrarme',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Link login ────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF8888AA),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Text(
                            'Inicia sesión',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7B7BFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int? maxLength,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      buildCounter: (context,
              {required currentLength,
              required isFocused,
              required maxLength}) =>
          null,
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
}
