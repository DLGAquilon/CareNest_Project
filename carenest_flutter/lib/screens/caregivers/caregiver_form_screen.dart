import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class CaregiverFormScreen extends StatefulWidget {
  final int? caregiverId;
  const CaregiverFormScreen({super.key, this.caregiverId});
  @override State<CaregiverFormScreen> createState() => _CaregiverFormScreenState();
}

class _CaregiverFormScreenState extends State<CaregiverFormScreen> {
  final _form          = GlobalKey<FormState>();
  final _firstName     = TextEditingController();
  final _lastName      = TextEditingController();
  final _contactNumber = TextEditingController();
  bool _loading = false;
  bool get _isEdit => widget.caregiverId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final res = await ApiService.get('/caregivers/${widget.caregiverId}');
    final d = res.data;
    _firstName.text     = d['FirstName']     ?? '';
    _lastName.text      = d['LastName']      ?? '';
    _contactNumber.text = d['ContactNumber'] ?? '';
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final adminId = context.read<AuthService>().user?['id'];
    final body = {
      'FirstName':     _firstName.text.trim(),
      'LastName':      _lastName.text.trim(),
      'ContactNumber': _contactNumber.text.trim(),
      'AdminID':       adminId,
    };
    try {
      if (_isEdit) {
        await ApiService.put('/caregivers/${widget.caregiverId}', body);
      } else {
        await ApiService.post('/caregivers', body);
      }
      if (mounted) context.pop();
    } on Exception catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgPage,
    appBar: AppBar(title: Text(_isEdit ? 'Edit Caregiver' : 'Add Caregiver')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Caregiver Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Fill in the details for this caregiver.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(children: [
              TextFormField(
                controller: _firstName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _lastName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contactNumber,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ]),
          ),

          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isEdit ? 'Update Caregiver' : 'Add Caregiver'),
          ),
        ]),
      ),
    ),
  );
}
