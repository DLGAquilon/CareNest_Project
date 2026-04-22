import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class MedicationFormScreen extends StatefulWidget {
  const MedicationFormScreen({super.key});
  @override State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _form     = GlobalKey<FormState>();
  final _medName  = TextEditingController();
  final _dosage   = TextEditingController();
  final _notes    = TextEditingController();

  List<dynamic> _residents = [], _caregivers = [], _statuses = [];
  int?      _residentId, _staffId, _statusId;
  DateTime  _scheduledAt = DateTime.now();
  bool      _loading = false;

  @override void initState() { super.initState(); _loadDropdowns(); }

  Future<void> _loadDropdowns() async {
    final r  = await ApiService.get('/residents');
    final c  = await ApiService.get('/caregivers');
    final st = await ApiService.get('/statuses/MedicationStatus');
    setState(() { _residents = r.data; _caregivers = c.data; _statuses = st.data; });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      setState(() => _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_residentId == null || _staffId == null || _statusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all required dropdowns.'),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.post('/medication-logs', {
        'ResidentID':  _residentId,
        'StaffID':     _staffId,
        'MedName':     _medName.text.trim(),
        'Dosage':      _dosage.text.trim(),
        'ScheduledAt': _scheduledAt.toIso8601String(),
        'StatusID':    _statusId,
        'Notes':       _notes.text.trim(),
      });
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Widget _section(String label, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      const SizedBox(height: 14),
      ...children,
    ]),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgPage,
    appBar: AppBar(title: const Text('New Medication Log')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(children: [
          _section('Medication', [
            TextFormField(
              controller: _medName,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                prefixIcon: Icon(Icons.medication_outlined, size: 20),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _dosage,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Dosage (e.g. 5mg)',
                prefixIcon: Icon(Icons.science_outlined, size: 20),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
          ]),
          _section('Assignment', [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Resident'),
              items: _residents.map((r) => DropdownMenuItem(
                value: r['ResidentID'] as int,
                child: Text('${r['FirstName']} ${r['LastName']}'),
              )).toList(),
              onChanged: (v) => setState(() => _residentId = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Caregiver'),
              items: _caregivers.map((c) => DropdownMenuItem(
                value: c['StaffID'] as int,
                child: Text('${c['FirstName']} ${c['LastName']}'),
              )).toList(),
              onChanged: (v) => setState(() => _staffId = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
          ]),
          _section('Schedule & Status', [
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(children: [
                  const Icon(Icons.schedule_rounded, size: 20, color: AppTheme.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    '${_scheduledAt.year}-${_scheduledAt.month.toString().padLeft(2,'0')}-${_scheduledAt.day.toString().padLeft(2,'0')} '
                    '${_scheduledAt.hour.toString().padLeft(2,'0')}:${_scheduledAt.minute.toString().padLeft(2,'0')}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Status'),
              items: _statuses.map((s) => DropdownMenuItem(
                value: s['StatusID'] as int,
                child: Text(s['StatusValue']),
              )).toList(),
              onChanged: (v) => setState(() => _statusId = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
          ]),
          _section('Notes', [
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
          ]),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Medication Log'),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    ),
  );
}
