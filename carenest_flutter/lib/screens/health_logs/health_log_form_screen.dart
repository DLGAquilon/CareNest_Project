import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class HealthLogFormScreen extends StatefulWidget {
  const HealthLogFormScreen({super.key});
  @override State<HealthLogFormScreen> createState() =>
      _HealthLogFormScreenState();
}

class _HealthLogFormScreenState extends State<HealthLogFormScreen> {
  final _form      = GlobalKey<FormState>();
  final _systolic  = TextEditingController();
  final _diastolic = TextEditingController();
  final _hr        = TextEditingController();
  final _temp      = TextEditingController();
  final _spo2      = TextEditingController();
  final _notes     = TextEditingController();

  List<dynamic> _residents   = [];
  List<dynamic> _caregivers  = [];
  List<dynamic> _medStatuses = [];
  List<dynamic> _resStatuses = [];

  int?  _residentId, _staffId, _medStatusId, _resStatusId;
  bool  _loading         = false;
  bool  _dropsLoading    = true;

  @override
  void initState() { super.initState(); _loadDropdowns(); }

  @override
  void dispose() {
    _systolic.dispose(); _diastolic.dispose(); _hr.dispose();
    _temp.dispose(); _spo2.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _loadDropdowns() async {
    try {
      final r  = await ApiService.get('/residents');
      final c  = await ApiService.get('/caregivers');
      final ms = await ApiService.get('/statuses/MedicationStatus');
      final rs = await ApiService.get('/statuses/ResidentStatus');
      setState(() {
        _residents   = r.data;
        _caregivers  = c.data;
        _medStatuses = ms.data;
        _resStatuses = rs.data;
        _dropsLoading = false;
      });
    } catch (_) { setState(() => _dropsLoading = false); }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.danger,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_residentId == null) { _showError('Please select a resident.'); return; }
    if (_staffId    == null) { _showError('Please select a caregiver.'); return; }
    if (_medStatusId == null){ _showError('Please select medication status.'); return; }
    if (_resStatusId == null){ _showError('Please select resident status.'); return; }

    setState(() => _loading = true);
    try {
      await ApiService.post('/health-logs', {
        'ResidentID':         _residentId,
        'StaffID':            _staffId,
        'LogTimestamp':       DateTime.now().toIso8601String(),
        'SystolicBP':         int.tryParse(_systolic.text),
        'DiastolicBP':        int.tryParse(_diastolic.text),
        'HeartRate':          int.tryParse(_hr.text),
        'Temperature':        double.tryParse(_temp.text),
        'OxygenSaturation':   int.tryParse(_spo2.text),
        'MedicationStatusID': _medStatusId,
        'ResidentStatusID':   _resStatusId,
        'CaregiverNotes':     _notes.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Health log saved successfully.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        context.pop();
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) _showError('Error saving log: $e');
    }
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> children) =>
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              Icon(icon, size: 15, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 2),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: children),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgPage,
    appBar: AppBar(title: const Text('New Health Log')),
    body: _dropsLoading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading data...',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ))
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Form(
              key: _form,
              child: Column(children: [
                // ── Assignment ─────────────────────────────
                _sectionCard(
                  'Assignment',
                  Icons.assignment_ind_rounded,
                  [
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Resident',
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            size: 20),
                      ),
                      items: _residents
                          .map((r) => DropdownMenuItem(
                                value: r['ResidentID'] as int,
                                child: Text(
                                  '${r['FirstName']} ${r['LastName']}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _residentId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Caregiver on Duty',
                        prefixIcon: Icon(Icons.medical_services_outlined,
                            size: 20),
                      ),
                      items: _caregivers
                          .map((c) => DropdownMenuItem(
                                value: c['StaffID'] as int,
                                child: Text(
                                  '${c['FirstName']} ${c['LastName']}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _staffId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ],
                ),

                // ── Vital Signs ────────────────────────────
                _sectionCard(
                  'Vital Signs',
                  Icons.monitor_heart_rounded,
                  [
                    // Blood pressure row
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _systolic,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Systolic',
                            suffixText: 'mmHg',
                            prefixIcon:
                                Icon(Icons.arrow_upward_rounded, size: 18),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('/',
                            style: TextStyle(
                                fontSize: 22,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w300)),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _diastolic,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Diastolic',
                            suffixText: 'mmHg',
                            prefixIcon:
                                Icon(Icons.arrow_downward_rounded, size: 18),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    // HR + Temp + SpO2
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hr,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Heart Rate',
                            suffixText: 'bpm',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _temp,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Temp',
                            suffixText: '°C',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _spo2,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'SpO₂',
                            suffixText: '%',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ]),
                  ],
                ),

                // ── Status ─────────────────────────────────
                _sectionCard(
                  'Status Assessment',
                  Icons.assessment_rounded,
                  [
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Medication Status',
                        prefixIcon:
                            Icon(Icons.medication_outlined, size: 20),
                      ),
                      items: _medStatuses
                          .map((s) => DropdownMenuItem(
                                value: s['StatusID'] as int,
                                child: Text(s['StatusValue']),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _medStatusId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Resident Status',
                        prefixIcon:
                            Icon(Icons.person_search_rounded, size: 20),
                      ),
                      items: _resStatuses
                          .map((s) => DropdownMenuItem(
                                value: s['StatusID'] as int,
                                child: Text(s['StatusValue']),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _resStatusId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ],
                ),

                // ── Notes ──────────────────────────────────
                _sectionCard(
                  'Caregiver Notes',
                  Icons.notes_rounded,
                  [
                    TextFormField(
                      controller: _notes,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe the resident\'s condition, behavior, or any concerns...',
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                // ── Save button ────────────────────────────
                ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(_loading ? 'Saving...' : 'Save Health Log'),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
  );
}
