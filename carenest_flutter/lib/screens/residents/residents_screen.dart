import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/main_drawer.dart';

class ResidentsScreen extends StatefulWidget {
  const ResidentsScreen({super.key});
  @override State<ResidentsScreen> createState() => _ResidentsScreenState();
}

class _ResidentsScreenState extends State<ResidentsScreen> {
  List<dynamic> _residents = [];
  List<dynamic> _filtered  = [];
  bool          _loading   = true;
  final _search = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/residents');
      setState(() {
        _residents = res.data;
        _filtered  = res.data;
        _loading   = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  void _filter(String q) {
    setState(() => _filtered = _residents.where((r) =>
        '${r['FirstName']} ${r['LastName']}'
            .toLowerCase()
            .contains(q.toLowerCase())).toList());
  }

  /// Calculates age from ISO birth date string
  String _age(String? birthDate) {
    if (birthDate == null) return '-';
    final dob = DateTime.tryParse(birthDate);
    if (dob == null) return '-';
    final age = DateTime.now().difference(dob).inDays ~/ 365;
    return '$age yrs';
  }

  /// Returns initials from full name
  String _initials(String first, String last) =>
      '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
          .toUpperCase();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgPage,
    appBar: AppBar(title: const Text('Residents')),
    drawer: const MainDrawer(),
    floatingActionButton: FloatingActionButton(
      heroTag: 'res-fab',
      onPressed: () => context.push('/residents/new').then((_) => _load()),
      tooltip: 'Add resident',
      child: const Icon(Icons.person_add_rounded),
    ),
    body: Column(children: [
      // ── Search bar ──────────────────────────────────
      Container(
        color: AppTheme.bgCard,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: TextField(
          controller: _search,
          onChanged: _filter,
          decoration: const InputDecoration(
            hintText: 'Search by name...',
            prefixIcon: Icon(Icons.search_rounded, size: 20),
          ),
        ),
      ),

      // ── Count chip ──────────────────────────────────
      if (!_loading)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_filtered.length} resident${_filtered.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
        ),

      // ── List ────────────────────────────────────────
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _filtered.isEmpty
                ? const EmptyState(
                    message: 'No residents found',
                    icon: Icons.people_outline_rounded)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final r = _filtered[i];
                        final contacts =
                            (r['family_contacts'] as List?)?.length ?? 0;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            splashColor: AppTheme.primary.withValues(alpha: 0.06),
                            highlightColor:
                                AppTheme.primary.withValues(alpha: 0.04),
                            onTap: () => context
                                .push('/residents/${r['ResidentID']}')
                                .then((_) => _load()),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: AppTheme.border),
                              ),
                              child: Row(children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppTheme.primaryLight,
                                  child: Text(
                                    _initials(r['FirstName'] ?? '',
                                        r['LastName'] ?? ''),
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${r['FirstName']} ${r['LastName']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Age + Admission date (human-readable)
                                      Row(children: [
                                        const Icon(Icons.cake_rounded,
                                            size: 12,
                                            color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          _age(r['BirthDate']),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 12,
                                            color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          // "Admitted Apr 10, 2024"
                                          formatDate(r['AdmissionDate']),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ]),
                                      if (contacts > 0) ...[
                                        const SizedBox(height: 3),
                                        Row(children: [
                                          const Icon(
                                              Icons
                                                  .contact_phone_rounded,
                                              size: 12,
                                              color: AppTheme.accent),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$contacts contact${contacts > 1 ? 's' : ''}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.accent,
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ],
                                  ),
                                ),

                                const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.textHint,
                                    size: 20),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    ]),
  );
}