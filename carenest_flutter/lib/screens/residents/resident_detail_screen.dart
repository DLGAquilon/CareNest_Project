// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class ResidentDetailScreen extends StatefulWidget {
  final int id;
  const ResidentDetailScreen({super.key, required this.id});
  @override
  State<ResidentDetailScreen> createState() => _ResidentDetailScreenState();
}

class _ResidentDetailScreenState extends State<ResidentDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _data;
  bool _loading = true;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.get('/residents/${widget.id}');
      setState(() {
        _data = res.data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _ageFrom(String? d) {
    if (d == null) return '-';
    final dob = DateTime.tryParse(d);
    if (dob == null) return '-';
    return '${DateTime.now().difference(dob).inDays ~/ 365} years old';
  }

  // ── Archive confirmation dialog ────────────────────────────
  Future<void> _confirmArchive() async {
    final name = '${_data!['FirstName']} ${_data!['LastName']}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.archive_rounded, color: AppTheme.warning, size: 22),
                SizedBox(width: 10),
                Text('Archive Resident'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to archive $name?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'The resident record will remain in the database '
                    'but will no longer appear in the residents list. '
                    'All health logs and medication records are preserved.',
                    style: TextStyle(fontSize: 12, color: AppTheme.warning),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warning,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.archive_rounded, size: 16),
                label: const Text('Archive'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.put('/residents/${widget.id}/archive', {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resident archived successfully.'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(); // go back to resident list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        _data == null
            ? 'Loading...'
            : '${_data!['FirstName']} ${_data!['LastName']}';

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : NestedScrollView(
                headerSliverBuilder:
                    (_, __) => [
                      SliverAppBar(
                        expandedHeight: 230,
                        pinned: true,
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded),
                            tooltip: 'Edit',
                            onPressed:
                                () => context
                                    .push('/residents/${widget.id}/edit')
                                    .then((_) => _load()),
                          ),
                          // Archive button in app bar
                          IconButton(
                            icon: const Icon(Icons.archive_rounded),
                            tooltip: 'Archive resident',
                            onPressed: _confirmArchive,
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.primaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                CircleAvatar(
                                  radius: 38,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                  child: Text(
                                    _data == null
                                        ? '?'
                                        : '${_data!['FirstName'][0]}${_data!['LastName'][0]}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _ageFrom(_data?['BirthDate']),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                // 12px gap between age string and tab bar
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        bottom: TabBar(
                          controller: _tabs,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white.withOpacity(0.6),
                          indicatorColor: Colors.white,
                          indicatorWeight: 3,
                          tabs: const [
                            Tab(text: 'Profile'),
                            Tab(text: 'Health Logs'),
                            Tab(text: 'Medications'),
                          ],
                        ),
                      ),
                    ],
                body: TabBarView(
                  controller: _tabs,
                  children: [
                    _ProfileTab(
                      data: _data!,
                      residentId: widget.id,
                      onContactAdded: _load,
                    ),
                    _HealthLogTab(residentId: widget.id),
                    _MedLogTab(residentId: widget.id),
                  ],
                ),
              ),
    );
  }
}

// ── Profile tab ───────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final Map<String, dynamic> data;
  final int residentId;
  final VoidCallback onContactAdded;
  const _ProfileTab({
    required this.data,
    required this.residentId,
    required this.onContactAdded,
  });

  void _showAddContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) =>
              _AddContactSheet(residentId: residentId, onSaved: onContactAdded),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = (data['family_contacts'] as List?) ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Basic info
        _Card(
          title: 'Basic Information',
          icon: Icons.person_outline_rounded,
          children: [
            InfoRow(label: 'First Name', value: data['FirstName'] ?? '-'),
            const Divider(),
            InfoRow(label: 'Last Name', value: data['LastName'] ?? '-'),
            const Divider(),
            InfoRow(label: 'Birth Date', value: formatDate(data['BirthDate'])),
            const Divider(),
            InfoRow(
              label: 'Admission',
              value: formatDate(data['AdmissionDate']),
            ),
            const Divider(),
            InfoRow(
              label: 'Managed by',
              value: data['admin']?['Username'] ?? '-',
              icon: Icons.admin_panel_settings_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Family contacts
        _Card(
          title: 'Family Contacts',
          icon: Icons.contact_phone_rounded,
          trailing: TextButton.icon(
            onPressed: () => _showAddContactSheet(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(
              Icons.add_rounded,
              size: 16,
              color: AppTheme.primary,
            ),
            label: const Text(
              'Add',
              style: TextStyle(fontSize: 13, color: AppTheme.primary),
            ),
          ),
          children: [
            // FIX: padding so "Family Contacts" header is not too close
            // to the divider line — added top padding here
            if (contacts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No contacts on file.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              )
            else
              ...contacts.asMap().entries.map((entry) {
                final fc = entry.value;
                final idx = entry.key;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.bgChip,
                          child: Text(
                            (fc['FirstName'] as String? ?? '?')[0],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${fc['FirstName']} ${fc['LastName']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${fc['Relationship']} • ${fc['PhoneNumber']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (idx < contacts.length - 1) const Divider(height: 20),
                  ],
                );
              }),
          ],
        ),
      ],
    );
  }
}

// ── Add contact bottom sheet ──────────────────────────────────
class _AddContactSheet extends StatefulWidget {
  final int residentId;
  final VoidCallback onSaved;
  const _AddContactSheet({required this.residentId, required this.onSaved});
  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _form = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _relationship = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _relationship.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.post('/residents/${widget.residentId}/contacts', {
        'FirstName': _firstName.text.trim(),
        'LastName': _lastName.text.trim(),
        'Relationship': _relationship.text.trim(),
        'PhoneNumber': _phone.text.trim(),
        'Address': _address.text.trim(),
      });
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    padding: EdgeInsets.only(
      left: 24,
      right: 24,
      top: 20,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Add Family Contact',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        Form(
          key: _form,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _tf(
                      _firstName,
                      'First Name',
                      TextInputAction.next,
                      v: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _tf(
                      _lastName,
                      'Last Name',
                      TextInputAction.next,
                      v: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _tf(
                _relationship,
                'Relationship (e.g. Son, Daughter)',
                TextInputAction.next,
                v: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _tf(
                _phone,
                'Phone Number',
                TextInputAction.next,
                type: TextInputType.phone,
                v: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _tf(
                _address,
                'Address',
                TextInputAction.done,
                v: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _loading ? null : _save,
          icon:
              _loading
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Icon(Icons.save_rounded, size: 16),
          label: Text(_loading ? 'Saving...' : 'Save Contact'),
        ),
      ],
    ),
  );

  Widget _tf(
    TextEditingController ctrl,
    String label,
    TextInputAction action, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? v,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: type,
    textInputAction: action,
    decoration: InputDecoration(labelText: label),
    validator: v,
  );
}

// ── Health log tab ────────────────────────────────────────────
class _HealthLogTab extends StatefulWidget {
  final int residentId;
  const _HealthLogTab({required this.residentId});
  @override
  State<_HealthLogTab> createState() => _HealthLogTabState();
}

class _HealthLogTabState extends State<_HealthLogTab> {
  List<dynamic> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.get(
        '/residents/${widget.residentId}/health-logs',
      );
      setState(() {
        _logs = res.data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const EmptyState(
            message: 'No health logs recorded',
            icon: Icons.favorite_border_rounded,
          )
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _logs.length,
            itemBuilder: (_, i) {
              final l = _logs[i];
              final status = l['resident_status']?['StatusValue'] ?? '-';
              final isAlert =
                  status == 'Critical' || status == 'Under Observation';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      isAlert
                          ? AppTheme.danger.withOpacity(0.04)
                          : AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isAlert
                            ? AppTheme.danger.withOpacity(0.3)
                            : AppTheme.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 14,
                          color: isAlert ? AppTheme.danger : Colors.pinkAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatDate(
                            l['LogTimestamp']?.toString(),
                            includeTime: true,
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        // FIX: constrain badge width to prevent overflow
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 130),
                          child: StatusBadge.fromStatus(status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Vital('BP', '${l['SystolicBP']}/${l['DiastolicBP']}'),
                        _Vital('HR', '${l['HeartRate']}'),
                        _Vital('Temp', '${l['Temperature']}°C'),
                        _Vital('SpO₂', '${l['OxygenSaturation']}%'),
                      ],
                    ),
                    if ((l['CaregiverNotes'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        l['CaregiverNotes'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
}

class _Vital extends StatelessWidget {
  final String label, value;
  const _Vital(this.label, this.value);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
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

// ── Medication log tab ────────────────────────────────────────
class _MedLogTab extends StatefulWidget {
  final int residentId;
  const _MedLogTab({required this.residentId});
  @override
  State<_MedLogTab> createState() => _MedLogTabState();
}

class _MedLogTabState extends State<_MedLogTab> {
  List<dynamic> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.get(
        '/residents/${widget.residentId}/medication-logs',
      );
      setState(() {
        _logs = res.data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const EmptyState(
            message: 'No medication logs recorded',
            icon: Icons.medication_outlined,
          )
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _logs.length,
            itemBuilder: (_, i) {
              final m = _logs[i];
              final status = m['status']?['StatusValue'] ?? 'Pending';
              // FIX: Darken "Taken" badge background for better visibility
              final isTaken = status.toLowerCase() == 'taken';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  // Slightly tinted background for Taken entries
                  color:
                      isTaken
                          ? AppTheme.success.withOpacity(0.05)
                          : AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isTaken
                            ? AppTheme.success.withOpacity(0.25)
                            : AppTheme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isTaken
                                ? AppTheme.success.withOpacity(0.15)
                                : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.medication_rounded,
                        color: isTaken ? AppTheme.success : AppTheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m['MedName']} • ${m['Dosage']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            formatDate(
                              m['ScheduledAt']?.toString(),
                              includeTime: true,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if ((m['Notes'] ?? '').toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                m['Notes'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Darker badge for Taken — use solid background
                    _MedStatusBadge(status: status),
                  ],
                ),
              );
            },
          );
}

/// Medication-specific badge with darker background for "Taken"
class _MedStatusBadge extends StatelessWidget {
  final String status;
  const _MedStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    IconData ic;
    switch (status.toLowerCase()) {
      case 'taken':
        // FIX: Darker green background so "Taken" stands out clearly
        bg = AppTheme.success.withOpacity(0.22);
        fg = AppTheme.success;
        ic = Icons.check_circle_rounded;
        break;
      case 'refused':
        bg = AppTheme.danger.withOpacity(0.12);
        fg = AppTheme.danger;
        ic = Icons.cancel_rounded;
        break;
      default: // Pending
        bg = AppTheme.warning.withOpacity(0.12);
        fg = AppTheme.warning;
        ic = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ic, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable card with optional trailing widget ───────────────
class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  const _Card({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // FIX: top padding increased to 16 so label is not pressed
          // against the card edge/divider line
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      ],
    ),
  );
}
