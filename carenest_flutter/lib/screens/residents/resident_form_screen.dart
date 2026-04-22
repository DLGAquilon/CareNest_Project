import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ResidentFormScreen extends StatefulWidget {
  final int? residentId;
  const ResidentFormScreen({super.key, this.residentId});
  @override State<ResidentFormScreen> createState() => _ResidentFormScreenState();
}
class _ResidentFormScreenState extends State<ResidentFormScreen> {
  final _form      = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName  = TextEditingController();
  DateTime? _birthDate, _admissionDate;
  bool _loading = false;
  bool get _isEdit => widget.residentId != null;

  @override void initState() { super.initState(); if (_isEdit) _loadExisting(); }

  Future<void> _loadExisting() async {
    final res = await ApiService.get('/residents/${widget.residentId}');
    final d = res.data;
    _firstName.text = d['FirstName'];
    _lastName.text  = d['LastName'];
    _birthDate      = DateTime.tryParse(d['BirthDate'] ?? '');
    _admissionDate  = DateTime.tryParse(d['AdmissionDate'] ?? '');
    setState(() {});
  }

  Future<void> _pick(bool isBirth) async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (d != null) setState(() => isBirth ? _birthDate = d : _admissionDate = d);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_birthDate == null || _admissionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both dates.')));
      return;
    }
    setState(() => _loading = true);
    final adminId = context.read<AuthService>().user?['id'];
    final body = {
      'FirstName':     _firstName.text.trim(),
      'LastName':      _lastName.text.trim(),
      'BirthDate':     _birthDate!.toIso8601String().substring(0,10),
      'AdmissionDate': _admissionDate!.toIso8601String().substring(0,10),
      'AdminID':       adminId,
    };
    try {
      if (_isEdit) { await ApiService.put('/residents/${widget.residentId}', body); }
      else          { await ApiService.post('/residents', body); }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isEdit ? 'Edit Resident' : 'Add Resident')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(key: _form, child: Column(children: [
        TextFormField(controller: _firstName, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _lastName,  decoration: const InputDecoration(labelText: 'Last Name',  border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        ListTile(
          tileColor: Colors.grey[100], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(_birthDate == null ? 'Select Birth Date' : 'Birth Date: ${_birthDate!.toIso8601String().substring(0,10)}'),
          trailing: const Icon(Icons.calendar_today), onTap: () => _pick(true),
        ),
        const SizedBox(height: 12),
        ListTile(
          tileColor: Colors.grey[100], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(_admissionDate == null ? 'Select Admission Date' : 'Admission: ${_admissionDate!.toIso8601String().substring(0,10)}'),
          trailing: const Icon(Icons.calendar_today), onTap: () => _pick(false),
        ),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF185FA5), foregroundColor: Colors.white),
            child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(_isEdit ? 'Update' : 'Save'),
          ),
        ),
      ])),
    ),
  );
}