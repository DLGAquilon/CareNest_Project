import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/main_drawer.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});
  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
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
      final res = await ApiService.get('/medication-logs');
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
        appBar: AppBar(title: const Text('Medication Logs')),
        drawer: const MainDrawer(),
        floatingActionButton: FloatingActionButton(
          heroTag: 'med-fab',
          onPressed: () =>
              context.push('/medications/new').then((_) => _load()),
          tooltip: 'Log medication',
          child: const Icon(Icons.medication_rounded),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _logs.isEmpty
                ? const EmptyState(
                    message: 'No medication logs yet',
                    icon: Icons.medication_outlined)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _logs.length,
                      itemBuilder: (_, i) {
                        final m = _logs[i];
                        final status = m['status']?['StatusValue'] ?? 'Pending';
                        final resident =
                            '${m['resident']?['FirstName'] ?? ''} ${m['resident']?['LastName'] ?? ''}'
                                .trim();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon container
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.medication_rounded,
                                        color: AppTheme.primary, size: 20),
                                  ),
                                  const SizedBox(width: 14),

                                  // Content
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        // Med name + dosage
                                        Text(
                                          '${m['MedName']} • ${m['Dosage']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),

                                        // Resident name
                                        if (resident.isNotEmpty)
                                          Row(children: [
                                            const Icon(
                                                Icons.person_outline_rounded,
                                                size: 12,
                                                color: AppTheme.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(resident,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme
                                                        .textSecondary)),
                                          ]),
                                        const SizedBox(height: 3),

                                        // Human-readable date — e.g. "Apr 18, 2026  08:00"
                                        Row(children: [
                                          const Icon(Icons.schedule_rounded,
                                              size: 12,
                                              color: AppTheme.textHint),
                                          const SizedBox(width: 4),
                                          Text(
                                            formatDate(
                                                m['ScheduledAt']?.toString(),
                                                includeTime: true),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textHint),
                                          ),
                                        ]),

                                        // Caregiver notes if any
                                        if ((m['Notes'] ?? '')
                                            .toString()
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 5),
                                          Text(
                                            m['Notes'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textPrimary
                                                  .withOpacity(0.5),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ])),

                                  // Status badge with icon (color-blind safe)
                                  const SizedBox(width: 8),
                                  StatusBadge.fromStatus(status),
                                ]),
                          ),
                        );
                      },
                    ),
                  ),
      );
}
