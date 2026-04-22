// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/main_drawer.dart';

class CaregiversScreen extends StatefulWidget {
  const CaregiversScreen({super.key});
  @override State<CaregiversScreen> createState() => _CaregiversScreenState();
}

class _CaregiversScreenState extends State<CaregiversScreen> {
  List<dynamic> _caregivers = [];
  List<dynamic> _filtered   = [];
  bool          _loading    = true;
  final _search = TextEditingController();

  @override void initState() { super.initState(); _load(); }
  @override void dispose()   { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/caregivers');
      setState(() {
        _caregivers = res.data;
        _filtered   = res.data;
        _loading    = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  void _filter(String q) {
    setState(() => _filtered = _caregivers.where((c) =>
        '${c['FirstName']} ${c['LastName']}'
            .toLowerCase()
            .contains(q.toLowerCase()) ||
        (c['ContactNumber'] ?? '').contains(q)).toList());
  }

  // ── Archive with confirmation popup ───────────────────────
  Future<void> _confirmArchive(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.archive_rounded, color: AppTheme.warning, size: 22),
          SizedBox(width: 10),
          Text('Archive Caregiver'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Are you sure you want to archive $name?',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'The caregiver record will stay in the database '
              'but will no longer appear in the active list. '
              'All health logs and shift records are preserved.',
              style: TextStyle(fontSize: 12, color: AppTheme.warning),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warning,
                foregroundColor: Colors.white),
            icon: const Icon(Icons.archive_rounded, size: 16),
            label: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.put('/caregivers/$id/archive', {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$name has been archived.'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ));
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgPage,
    appBar: AppBar(title: const Text('Caregivers')),
    drawer: const MainDrawer(),
    floatingActionButton: FloatingActionButton(
      heroTag: 'cg-fab',
      onPressed: () =>
          context.push('/caregivers/new').then((_) => _load()),
      tooltip: 'Add caregiver',
      child: const Icon(Icons.person_add_rounded),
    ),
    body: Column(children: [
      // Search bar
      Container(
        color: AppTheme.bgCard,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: TextField(
          controller: _search,
          onChanged: _filter,
          decoration: const InputDecoration(
            hintText: 'Search caregivers...',
            prefixIcon: Icon(Icons.search_rounded, size: 20),
          ),
        ),
      ),

      // Count chip
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
                '${_filtered.length} active caregiver${_filtered.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
        ),

      // List
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _filtered.isEmpty
                ? const EmptyState(
                    message: 'No caregivers found',
                    icon: Icons.medical_services_outlined)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          16, 8, 16, 80),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final c = _filtered[i];
                        final shifts =
                            (c['shifts'] as List?) ?? [];
                        final initials =
                            '${(c['FirstName'] as String? ?? '?')[0]}'
                            '${(c['LastName']  as String? ?? '?')[0]}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(children: [
                              // Avatar
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppTheme.primaryLight,
                                child: Text(initials,
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    )),
                              ),
                              const SizedBox(width: 14),

                              // Info
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                    '${c['FirstName']} ${c['LastName']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(children: [
                                    const Icon(Icons.phone_outlined,
                                        size: 12,
                                        color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(c['ContactNumber'] ?? '-',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                AppTheme.textSecondary)),
                                  ]),
                                  const SizedBox(height: 2),
                                  Row(children: [
                                    const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 12,
                                        color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${shifts.length} shift${shifts.length != 1 ? 's' : ''} assigned',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppTheme.textSecondary),
                                    ),
                                  ]),
                                ]),
                              ),

                              // Actions menu
                              PopupMenuButton<String>(
                                icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: AppTheme.textSecondary,
                                    size: 20),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      Icon(Icons.edit_rounded,
                                          size: 16,
                                          color: AppTheme.textSecondary),
                                      SizedBox(width: 10),
                                      Text('Edit'),
                                    ]),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'archive',
                                    child: Row(children: [
                                      Icon(Icons.archive_rounded,
                                          size: 16,
                                          color: AppTheme.warning),
                                      SizedBox(width: 10),
                                      Text('Archive',
                                          style: TextStyle(
                                              color: AppTheme.warning)),
                                    ]),
                                  ),
                                ],
                                onSelected: (v) {
                                  if (v == 'edit') {
                                    context
                                        .push('/caregivers/${c['StaffID']}/edit')
                                        .then((_) => _load());
                                  }
                                  if (v == 'archive') {
                                    _confirmArchive(
                                      c['StaffID'] as int,
                                      '${c['FirstName']} ${c['LastName']}',
                                    );
                                  }
                                },
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    ]),
  );
}