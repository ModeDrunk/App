import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/design_system/glass_card.dart';
import '../../providers/profile_provider.dart';

class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _showCurrentPin = false;
  bool _showNewPin = false;
  bool _showConfirmPin = false;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _changePin() async {
    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Los nuevos PINs no coinciden',
              style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_newPinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El PIN debe tener 6 dígitos',
              style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(profileProvider.notifier).changePin(
          currentPin: _currentPinController.text,
          newPin: _newPinController.text,
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PIN actual incorrecto',
              style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
              // ── App Bar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Cambiar PIN',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seguridad',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Cambia tu PIN de 6 dígitos para desactivar el Modo Borracho',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF8888AA),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // PIN actual
                        TextFormField(
                          controller: _currentPinController,
                          obscureText: !_showCurrentPin,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            labelText: 'PIN actual',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showCurrentPin
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _showCurrentPin = !_showCurrentPin,
                              ),
                            ),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // PIN nuevo
                        TextFormField(
                          controller: _newPinController,
                          obscureText: !_showNewPin,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            labelText: 'PIN nuevo (6 dígitos)',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showNewPin
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _showNewPin = !_showNewPin,
                              ),
                            ),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Confirmar PIN
                        TextFormField(
                          controller: _confirmPinController,
                          obscureText: !_showConfirmPin,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            labelText: 'Confirmar PIN nuevo',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPin
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _showConfirmPin = !_showConfirmPin,
                              ),
                            ),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Botón guardar
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _changePin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B5EF8),
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
                                    'Actualizar PIN',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
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
