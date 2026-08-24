import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/design_system/glass_card.dart';
import '../../providers/contacts_provider.dart';

class AddEditContactScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? contact;

  const AddEditContactScreen({super.key, this.contact});

  @override
  ConsumerState<AddEditContactScreen> createState() =>
      _AddEditContactScreenState();
}

class _AddEditContactScreenState extends ConsumerState<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  int _priority = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!['name'] ?? '';
      _phoneController.text = widget.contact!['phone'] ?? '';
      _emailController.text = widget.contact!['email'] ?? '';
      _priority = widget.contact!['priority'] ?? 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final contactData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      'priority': _priority,
      'isEnabled': true,
    };

    final success = widget.contact == null
        ? await ref.read(contactsProvider.notifier).createContact(contactData)
        : await ref
            .read(contactsProvider.notifier)
            .updateContact(widget.contact!['id'], contactData);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.contact == null
                ? 'Error al crear contacto'
                : 'Error al actualizar contacto',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

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
                        isEditing ? 'Editar contacto' : 'Nuevo contacto',
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información del contacto',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Nombre
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.person_outline_rounded),
                                  labelText: 'Nombre completo',
                                  hintText: 'Ej: María González',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nombre requerido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Teléfono
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.phone_outlined),
                                  labelText: 'Teléfono',
                                  hintText: '+521234567890',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Teléfono requerido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Email (opcional)
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined),
                                  labelText: 'Email (opcional)',
                                  hintText: 'maria@ejemplo.com',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Prioridad
                              Text(
                                'Nivel de prioridad',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF8888AA),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  _buildPriorityButton(0, 'Alta'),
                                  const SizedBox(width: AppSpacing.sm),
                                  _buildPriorityButton(1, 'Media'),
                                  const SizedBox(width: AppSpacing.sm),
                                  _buildPriorityButton(2, 'Baja'),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Los contactos con prioridad alta serán notificados primero',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF555577),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Botón guardar
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveContact,
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
                                    isEditing
                                        ? 'Actualizar contacto'
                                        : 'Crear contacto',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityButton(int priority, String label) {
    final isSelected = _priority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF6B5EF8) : const Color(0xFF13132E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6B5EF8)
                  : const Color(0xFF2A2A4A),
              width: 0.8,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : const Color(0xFF8888AA),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
