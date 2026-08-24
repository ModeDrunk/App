import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/contacts_provider.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsProvider);

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contactos seguros',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (!contactsState.isLoading &&
                              contactsState.contacts.isNotEmpty)
                            Text(
                              '${contactsState.contacts.length} contacto${contactsState.contacts.length != 1 ? 's' : ''} registrado${contactsState.contacts.length != 1 ? 's' : ''}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: const Color(0xFF7777AA),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _AddButton(
                      onTap: () async {
                        final result = await context.push('/add-contact');
                        if (result == true && mounted) {
                          ref.read(contactsProvider.notifier).loadContacts();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Contact list ──────────────────────────────────────
              Expanded(
                child: contactsState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6B5EF8),
                          strokeWidth: 2,
                        ),
                      )
                    : contactsState.contacts.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                            itemCount: contactsState.contacts.length,
                            itemBuilder: (context, index) {
                              final contact = contactsState.contacts[index];
                              return _ContactCard(
                                contact: contact,
                                onToggle: () {
                                  ref
                                      .read(contactsProvider.notifier)
                                      .toggleContact(contact['id']);
                                },
                                onEdit: () async {
                                  final result = await context.push(
                                    '/edit-contact/${contact['id']}',
                                    extra: contact,
                                  );
                                  if (result == true && mounted) {
                                    ref
                                        .read(contactsProvider.notifier)
                                        .loadContacts();
                                  }
                                },
                                onDelete: () =>
                                    _showDeleteDialog(contact['id']),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF12143A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A2D5A)),
              ),
              child: const Icon(
                Icons.contact_phone_outlined,
                size: 36,
                color: Color(0xFF5A5A8A),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin contactos seguros',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCCCCEE),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega personas de confianza\nque te ayuden en emergencias',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF6666AA),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () async {
                final result = await context.push('/add-contact');
                if (result == true && mounted) {
                  ref.read(contactsProvider.notifier).loadContacts();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B5EF8),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B5EF8).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Agregar contacto',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String contactId) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF12143A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2D5A)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Eliminar contacto',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Estás seguro de eliminar este contacto? Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: const Color(0xFF9090BB),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2A2D5A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF9090BB),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref
                            .read(contactsProvider.notifier)
                            .deleteContact(contactId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'Eliminar',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          border: Border.all(color: const Color(0xFF2A2D5A), width: 1),
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

// ── Add Button ────────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF6B5EF8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B5EF8).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 24, color: Colors.white),
      ),
    );
  }
}

// ── Contact Card ──────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final Map<String, dynamic> contact;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  // Generate a consistent color from name
  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF6B5EF8),
      const Color(0xFF22C97A),
      const Color(0xFFFFAA44),
      const Color(0xFF4EC3E0),
      const Color(0xFFE06B8B),
    ];
    final idx = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = contact['isEnabled'] as bool? ?? true;
    final name = contact['name'] as String? ?? 'Sin nombre';
    final phone = contact['phone'] as String? ?? '';
    final email = contact['email'] as String? ?? '';
    final priority = contact['priority'] as int?;
    final color = _avatarColor(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12143A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEnabled ? const Color(0xFF2A2D5A) : const Color(0xFF1E2040),
          width: 1,
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(isEnabled ? 0.15 : 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withOpacity(isEnabled ? 0.4 : 0.15),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isEnabled ? color : color.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isEnabled
                                ? Colors.white
                                : const Color(0xFF6666AA),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (priority != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'P${priority + 1}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: const Color(0xFF7777AA),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          phone,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: const Color(0xFF9090BB),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 13,
                          color: const Color(0xFF7777AA),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            email,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF666699),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Toggle + Menu
            Column(
              children: [
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: isEnabled,
                    onChanged: (_) => onToggle(),
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF22C97A),
                    inactiveThumbColor: const Color(0xFF555577),
                    inactiveTrackColor: const Color(0xFF1E2050),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: Color(0xFF6666AA),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  color: const Color(0xFF1A1C45),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF2A2D5A)),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      height: 44,
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 18, color: Color(0xFF8B7FF8)),
                          const SizedBox(width: 12),
                          Text(
                            'Editar',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem<String>(
                      value: 'delete',
                      onTap: onDelete,
                      height: 44,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: AppColors.error),
                          const SizedBox(width: 12),
                          Text(
                            'Eliminar',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
