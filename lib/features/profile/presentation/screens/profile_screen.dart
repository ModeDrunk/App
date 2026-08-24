import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/design_system/glass_card.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Cerrar sesión',
      message: '¿Estás seguro de que quieres cerrar sesión?',
      confirmText: 'Cerrar sesión',
      confirmColor: AppColors.error,
    );

    if (confirmed && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);

    final userEmail = authState.userEmail ?? 'usuario@ejemplo.com';
    final userName = userEmail.split('@').first;
    final displayName = userName.isNotEmpty
        ? userName[0].toUpperCase() + userName.substring(1)
        : 'Usuario';

    return Scaffold(
      backgroundColor: const Color(0xFF080916),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1035),
              Color(0xFF080916),
            ],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    _BackButton(onTap: () => context.go(AppRoutes.home)),
                    const SizedBox(width: 16),
                    Text(
                      'Mi perfil',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // ── Avatar card ──────────────────────────────
                      _AvatarCard(
                        displayName: displayName,
                        userEmail: userEmail,
                        phone: profileState.phone,
                      ),
                      const SizedBox(height: 16),

                      // ── Menu card ────────────────────────────────
                      _MenuCard(
                        notificationsEnabled: profileState.notificationsEnabled,
                        onToggleNotifications: () {
                          ref
                              .read(profileProvider.notifier)
                              .toggleNotifications();
                        },
                        onChangePIN: () async {
                          final result = await context.push('/change-pin');
                          if (result == true && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'PIN actualizado correctamente',
                                  style: GoogleFonts.outfit(fontSize: 14),
                                ),
                                backgroundColor: const Color(0xFF22C97A),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // ── Logout button ────────────────────────────
                      _LogoutButton(onTap: _logout),
                      const SizedBox(height: 20),

                      // ── Version ──────────────────────────────────
                      Text(
                        'Versión 1.0.0',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF444466),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
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

// ── Avatar Card ───────────────────────────────────────────────────────────
class _AvatarCard extends StatelessWidget {
  final String displayName;
  final String userEmail;
  final String? phone;

  const _AvatarCard({
    required this.displayName,
    required this.userEmail,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF12143A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A2D5A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5EF8).withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar circle with gradient border
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B7FF8), Color(0xFF5B4EE8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B5EF8).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            userEmail,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFF9090BB),
              fontWeight: FontWeight.w400,
            ),
          ),
          if (phone != null) ...[
            const SizedBox(height: 4),
            Text(
              phone!,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF9090BB),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Menu Card ─────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final bool notificationsEnabled;
  final VoidCallback onToggleNotifications;
  final VoidCallback onChangePIN;

  const _MenuCard({
    required this.notificationsEnabled,
    required this.onToggleNotifications,
    required this.onChangePIN,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12143A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A2D5A),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Información personal',
            onTap: () {},
            isFirst: true,
          ),
          _Divider(),
          _ProfileMenuItem(
            icon: Icons.lock_outline_rounded,
            title: 'Cambiar PIN',
            onTap: onChangePIN,
          ),
          _Divider(),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            onTap: () {},
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (_) => onToggleNotifications(),
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF22C97A),
              inactiveThumbColor: const Color(0xFF9090BB),
              inactiveTrackColor: const Color(0xFF2A2D5A),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          _Divider(),
          _ProfileMenuItem(
            icon: Icons.shield_outlined,
            title: 'Privacidad y seguridad',
            onTap: () {},
          ),
          _Divider(),
          _ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Ayuda y soporte',
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: const Color(0xFF1E2050),
        height: 1,
        thickness: 1,
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFE53935),
            width: 1.5,
          ),
          backgroundColor: const Color(0xFFE53935).withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              size: 20,
              color: Color(0xFFE53935),
            ),
            const SizedBox(width: 10),
            Text(
              'Cerrar sesión',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE53935),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Back Button ───────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF12143A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2A2D5A),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Color(0xFFCCCCEE),
        ),
      ),
    );
  }
}

// ── Menu Item ─────────────────────────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    BorderRadius? borderRadius;
    if (isFirst) {
      borderRadius = const BorderRadius.vertical(top: Radius.circular(20));
    } else if (isLast) {
      borderRadius = const BorderRadius.vertical(bottom: Radius.circular(20));
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: const Color(0xFF6B5EF8).withOpacity(0.1),
        highlightColor: const Color(0xFF6B5EF8).withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B5EF8).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF8B7FF8)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFEEEEFF),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
              if (trailing == null)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Color(0xFF5A5A7A),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
