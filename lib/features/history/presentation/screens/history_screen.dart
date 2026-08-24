import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).loadHistory();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    } else {
      final months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(DateTime? activatedAt, DateTime? deactivatedAt) {
    if (activatedAt == null) return '0m';
    final end = deactivatedAt ?? DateTime.now();
    final duration = end.difference(activatedAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

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
                      'Historial de sesiones',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Stats summary bar ────────────────────────────────
              if (!historyState.isLoading && historyState.sessions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: _StatsSummary(
                    totalSessions: historyState.sessions.length,
                  ),
                ),
              const SizedBox(height: 8),

              // ── Session list ──────────────────────────────────────
              Expanded(
                child: historyState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6B5EF8),
                          strokeWidth: 2,
                        ),
                      )
                    : historyState.sessions.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(historyProvider.notifier)
                                .loadHistory(),
                            color: const Color(0xFF6B5EF8),
                            backgroundColor: const Color(0xFF12143A),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                              itemCount: historyState.sessions.length,
                              itemBuilder: (context, index) {
                                final session = historyState.sessions[index];
                                final activatedAt =
                                    session['activatedAt'] != null
                                        ? DateTime.parse(session['activatedAt'])
                                        : null;
                                final deactivatedAt =
                                    session['deactivatedAt'] != null
                                        ? DateTime.parse(
                                            session['deactivatedAt'])
                                        : null;

                                return _HistoryCard(
                                  index: index,
                                  date: _formatDate(
                                      activatedAt ?? DateTime.now()),
                                  time: activatedAt != null
                                      ? _formatTime(activatedAt)
                                      : '--:--',
                                  duration: _formatDuration(
                                      activatedAt, deactivatedAt),
                                  activationType:
                                      session['activationType'] ?? 'manual',
                                  isActive: deactivatedAt == null &&
                                      activatedAt != null,
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              Icons.history_rounded,
              size: 38,
              color: Color(0xFF5A5A8A),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sin sesiones registradas',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFCCCCEE),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activa el Modo Borracho para\nver tu historial aquí',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFF6666AA),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Summary ─────────────────────────────────────────────────────────
class _StatsSummary extends StatelessWidget {
  final int totalSessions;

  const _StatsSummary({required this.totalSessions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF12143A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2D5A), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(
            label: 'Total sesiones',
            value: '$totalSessions',
            color: const Color(0xFF8B7FF8),
          ),
          Container(width: 1, height: 32, color: const Color(0xFF2A2D5A)),
          _StatItem(
            label: 'Esta semana',
            value: '—',
            color: const Color(0xFF22C97A),
          ),
          Container(width: 1, height: 32, color: const Color(0xFF2A2D5A)),
          _StatItem(
            label: 'Tipo usual',
            value: 'Manual',
            color: const Color(0xFFFFAA44),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: const Color(0xFF8888AA),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── History Card ──────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final int index;
  final String date;
  final String time;
  final String duration;
  final String activationType;
  final bool isActive;

  const _HistoryCard({
    required this.index,
    required this.date,
    required this.time,
    required this.duration,
    required this.activationType,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isActive ? const Color(0xFFFFAA44) : const Color(0xFF22C97A);
    final statusLabel = isActive ? 'Activa' : 'Completada';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF12143A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2D5A),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFFAA44).withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),

            // Session number icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF6B5EF8).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '#${index + 1}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8B7FF8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Color(0xFF7777AA),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: const Color(0xFF9090BB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: Color(0xFF7777AA),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: const Color(0xFF9090BB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right side badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Activation type badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B5EF8).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activationType == 'manual' ? 'Manual' : 'Auto',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9B8FFF),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
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
