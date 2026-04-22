import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class InventoryFormScreen extends StatefulWidget {
  final int? itemId;
  const InventoryFormScreen({super.key, this.itemId});
  @override State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _form     = GlobalKey<FormState>();
  final _itemName = TextEditingController();
  final _qty      = TextEditingController();

  List<dynamic> _categories = [];
  int?  _categoryId;
  bool  _loading = false;
  bool  get _isEdit => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (_isEdit) _loadExisting();
  }

  Future<void> _loadCategories() async {
    final res = await ApiService.get('/inventory-categories');
    setState(() => _categories = res.data);
  }

  Future<void> _loadExisting() async {
    final res = await ApiService.get('/inventory/${widget.itemId}');
    final d = res.data;
    _itemName.text = d['ItemName']       ?? '';
    _qty.text      = '${d['QuantityOnHand'] ?? 0}';
    _categoryId    = d['CategoryID'];
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a category.'),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    final adminId = context.read<AuthService>().user?['id'];
    final body = {
      'ItemName':       _itemName.text.trim(),
      'QuantityOnHand': int.tryParse(_qty.text) ?? 0,
      'CategoryID':     _categoryId,
      'AdminID':        adminId,
    };
    try {
      if (_isEdit) {
        await ApiService.put('/inventory/${widget.itemId}', body);
      } else {
        await ApiService.post('/inventory', body);
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgPage,
    appBar: AppBar(title: Text(_isEdit ? 'Edit Item' : 'Add Inventory Item')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(children: [
              TextFormField(
                controller: _itemName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                ),
                items: _categories.map((c) => DropdownMenuItem(
                  value: c['CategoryID'] as int,
                  child: Text(c['CategoryName']),
                )).toList(),
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _qty,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Quantity on Hand',
                  prefixIcon: Icon(Icons.numbers_rounded, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Must be a number';
                  return null;
                },
              ),
            ]),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isEdit ? 'Update Item' : 'Add Item'),
          ),
        ]),
      ),
    ),
  );
}
