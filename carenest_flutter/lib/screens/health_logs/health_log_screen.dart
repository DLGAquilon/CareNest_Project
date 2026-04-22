// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/main_drawer.dart';

class HealthLogScreen extends StatefulWidget {
  const HealthLogScreen({super.key});
  @override
  State<HealthLogScreen> createState() => _HealthLogScreenState();
}

class _HealthLogScreenState extends State<HealthLogScreen> {
  List<dynamic> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/health-logs');
      setState(() {
        _logs = res.data['data'] ?? [];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgPage,
    appBar: AppBar(title: const Text('Health Logs')),
    drawer: const MainDrawer(),

    // FIX: Use a plain FAB with Icon only — no text — avoids overflow
    // The "Log Vitals" label was overflowing on small screens.
    // Icon-only FAB is cleaner and the tooltip still communicates intent.
    floatingActionButton: FloatingActionButton(
      heroTag: 'hl-fab',
      onPressed: () => context.push('/health-logs/new').then((_) => _load()),
      tooltip: 'Log Vitals',
      child: const Icon(Icons.add_rounded),
    ),

    body:
        _loading
            ? const Center(child: CircularProgressIndicator())
            : _logs.isEmpty
            ? const EmptyState(
              message: 'No health logs recorded yet',
              icon: Icons.favorite_border_rounded,
            )
            : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _logs.length,
                itemBuilder: (_, i) {
                  final l = _logs[i];
                  final status = l['resident_status']?['StatusValue'] ?? '-';
                  final medStatus =
                      l['medication_status']?['StatusValue'] ?? '-';
                  final isAlert =
                      status == 'Critical' || status == 'Under Observation';
                  final resident =
                      '${l['resident']?['FirstName'] ?? ''} '
                              '${l['resident']?['LastName'] ?? ''}'
                          .trim();
                  final caregiver =
                      '${l['caregiver']?['FirstName'] ?? ''} '
                              '${l['caregiver']?['LastName'] ?? ''}'
                          .trim();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color:
                          isAlert
                              ? AppTheme.danger.withOpacity(0.04)
                              : AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isAlert
                                ? AppTheme.danger.withOpacity(0.3)
                                : AppTheme.border,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header row ──────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ResidentAvatar(name: resident, isAlert: isAlert),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resident,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.medical_services_outlined,
                                          size: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            caregiver,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule_rounded,
                                          size: 11,
                                          color: AppTheme.textHint,
                                        ),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            formatDate(
                                              l['LogTimestamp']?.toString(),
                                              includeTime: true,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textHint,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),
                              // Badges column — uses FittedBox so long labels
                              // like "Under Obs." scale down rather than clip.
                              // Background colour preserved because no clip.
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: StatusBadge.fromStatus(status),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: StatusBadge.fromStatus(medStatus),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── Vitals row ───────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.bgPage,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                _VitalChip(
                                  'BP',
                                  '${l['SystolicBP']}/${l['DiastolicBP']}',
                                  Icons.monitor_heart_rounded,
                                ),
                                _VitalChip(
                                  'HR',
                                  '${l['HeartRate']}bpm',
                                  Icons.favorite_rounded,
                                ),
                                _VitalChip(
                                  'Temp',
                                  '${l['Temperature']}°C',
                                  Icons.thermostat_rounded,
                                ),
                                _VitalChip(
                                  'SpO₂',
                                  '${l['OxygenSaturation']}%',
                                  Icons.air_rounded,
                                ),
                              ],
                            ),
                          ),

                          if ((l['CaregiverNotes'] ?? '').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              l['CaregiverNotes'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textPrimary.withOpacity(0.55),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
  );
}

// ── Resident avatar with pulsing ring for critical ────────────
class _ResidentAvatar extends StatefulWidget {
  final String name;
  final bool isAlert;
  const _ResidentAvatar({required this.name, required this.isAlert});
  @override
  State<_ResidentAvatar> createState() => _ResidentAvatarState();
}

class _ResidentAvatarState extends State<_ResidentAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.22,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isAlert) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _initials {
    final p = widget.name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}';
    return p[0].isNotEmpty ? p[0][0] : '?';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAlert) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.primaryLight,
        child: Text(
          _initials,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.danger.withOpacity(0.12),
          border: Border.all(color: AppTheme.danger, width: 1.5),
        ),
        child: const Center(
          child: Icon(
            Icons.emergency_rounded,
            size: 18,
            color: AppTheme.danger,
          ),
        ),
      ),
    );
  }
}

// ── Vital chip ────────────────────────────────────────────────
class _VitalChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _VitalChip(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    ),
  );
}
