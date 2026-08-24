// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/drunk-mode/providers/drunk_mode_provider.dart';

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final String _pin = '';
  final List<int> _digits = [];
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Verificar que hay un modo activo antes de mostrar PIN
    _checkActiveMode();
  }

  Future<void> _checkActiveMode() async {
    final drunkState = ref.read(drunkModeProvider);
    if (!drunkState.isActive && mounted) {
      // Si no hay modo activo, regresar a Home
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No hay un modo borracho activo',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.home);
    }
  }

  void _addDigit(int digit) {
    if (_digits.length < 6) {
      setState(() {
        _digits.add(digit);
        _errorMessage = '';
      });

      // Cuando llegue a 6 dígitos, validar automáticamente
      if (_digits.length == 6) {
        _validatePin();
      }
    }
  }

  void _removeDigit() {
    if (_digits.isNotEmpty) {
      setState(() {
        _digits.removeLast();
        _errorMessage = '';
      });
    }
  }

  Future<void> _validatePin() async {
    final pinCode = _digits.join();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success =
        await ref.read(drunkModeProvider.notifier).deactivate(pinCode);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      // Desactivación exitosa
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Modo Borracho desactivado',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.home);
    } else if (mounted) {
      // PIN incorrecto
      setState(() {
        _errorMessage = 'PIN incorrecto. Intenta de nuevo.';
        _digits.clear();
      });
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
              // ── Botón atrás ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
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
                ),
              ),

              const Spacer(),

              // ── Título ──────────────────────────────────────────
              Text(
                'Ingresar PIN',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Para desactivar el Modo Borracho',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF8888AA),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Círculos de PIN ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final bool hasDigit = index < _digits.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasDigit
                          ? const Color(0xFF6B5EF8)
                          : Colors.transparent,
                      border: Border.all(
                        color: hasDigit
                            ? const Color(0xFF6B5EF8)
                            : const Color(0xFF4040AA),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Mensaje de error ─────────────────────────────────
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _errorMessage,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(),

              // ── Loading overlay ──────────────────────────────────
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF6B5EF8),
                  ),
                ),

              const Spacer(),

              // ── Teclado numérico ─────────────────────────────────
              _buildKeyboard(),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Column(
      children: [
        // Filas 1, 2, 3
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int j = 1; j <= 3; j++) _buildKey((i * 3) + j),
              ],
            ),
          ),

        // Fila 4 (0, backspace)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKey(0),
              const SizedBox(width: AppSpacing.lg),
              _buildBackspaceKey(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKey(int digit) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _addDigit(digit),
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF13132E),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF2A2A4A),
            width: 0.8,
          ),
        ),
        child: Center(
          child: Text(
            digit.toString(),
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return GestureDetector(
      onTap: _isLoading ? null : _removeDigit,
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF13132E),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF2A2A4A),
            width: 0.8,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: Color(0xFF8888AA),
          ),
        ),
      ),
    );
  }
}
