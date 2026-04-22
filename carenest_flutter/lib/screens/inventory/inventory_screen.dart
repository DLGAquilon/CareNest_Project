import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/main_drawer.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> _items = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/inventory');
      setState(() {
        _items = res.data;
        _filtered = res.data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _filter(String q) {
    setState(() => _filtered = _items
        .where((i) =>
            i['ItemName'].toString().toLowerCase().contains(q.toLowerCase()) ||
            (i['category']?['CategoryName'] ?? '')
                .toString()
                .toLowerCase()
                .contains(q.toLowerCase()))
        .toList());
  }

  int get _lowCount =>
      _items.where((i) => (i['QuantityOnHand'] as int) < 10).length;

  // Pick a representative max for the stock bar.
  // Uses the max quantity across all items, minimum 50.
  int get _maxQty {
    if (_items.isEmpty) return 50;
    final max = _items
        .map((i) => i['QuantityOnHand'] as int)
        .reduce((a, b) => a > b ? a : b);
    return max < 50 ? 50 : max;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.bgPage,
        appBar: AppBar(title: const Text('Inventory')),
        drawer: const MainDrawer(),
        floatingActionButton: FloatingActionButton(
          heroTag: 'inv-fab',
          onPressed: () => context.push('/inventory/new').then((_) => _load()),
          tooltip: 'Add item',
          child: const Icon(Icons.add),
        ),
        body: Column(children: [
          // Search + low stock banner
          Container(
            color: AppTheme.bgCard,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: [
              TextField(
                controller: _search,
                onChanged: _filter,
                decoration: const InputDecoration(
                  hintText: 'Search items or category...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                ),
              ),
              if (!_loading && _lowCount > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppTheme.warning.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppTheme.warning, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '$_lowCount item${_lowCount > 1 ? 's' : ''} '
                      'running low — reorder needed',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warning,
                      ),
                    ),
                  ]),
                ),
              ],
            ]),
          ),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const EmptyState(
                        message: 'No inventory items found',
                        icon: Icons.inventory_2_outlined)
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final item = _filtered[i];
                            final qty = item['QuantityOnHand'] as int;
                            final low = qty < 10;

                            return GestureDetector(
                              onTap: () => context
                                  .push('/inventory/${item['ItemID']}/edit')
                                  .then((_) => _load()),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: low
                                      ? AppTheme.warning.withOpacity(0.04)
                                      : AppTheme.bgCard,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: low
                                        ? AppTheme.warning.withOpacity(0.3)
                                        : AppTheme.border,
                                  ),
                                ),
                                child: Column(children: [
                                  Row(children: [
                                    // Icon
                                    Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: low
                                            ? AppTheme.warning.withOpacity(0.1)
                                            : AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.inventory_2_rounded,
                                        size: 18,
                                        color: low
                                            ? AppTheme.warning
                                            : AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Name + category
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(item['ItemName'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppTheme.textPrimary,
                                              )),
                                          const SizedBox(height: 2),
                                          Text(
                                              item['category']
                                                      ?['CategoryName'] ??
                                                  '-',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary,
                                              )),
                                        ])),

                                    // Quantity badge
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$qty',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: low
                                                  ? AppTheme.warning
                                                  : AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            low ? 'LOW' : 'units',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: low
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                              color: low
                                                  ? AppTheme.warning
                                                  : AppTheme.textHint,
                                              letterSpacing: low ? 0.5 : 0,
                                            ),
                                          ),
                                        ]),
                                  ]),

                                  // ── Stock progress bar ─────────────
                                  const SizedBox(height: 12),
                                  InventoryStockBar(
                                    quantity: qty,
                                    maxQuantity: _maxQty,
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
