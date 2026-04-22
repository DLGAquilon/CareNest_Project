import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/main_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _data;
  bool _loading = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/dashboard');
      setState(() {
        _data = res.data;
        _loading = false;
      });
      _animCtrl
        ..reset()
        ..forward();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Greeting ────────────────────────────────
                      _GreetingBanner(username: user?['username'] ?? 'Admin'),
                      const SizedBox(height: 24),

                      // ── Stats row ────────────────────────────────
                      const SectionHeader('OVERVIEW'),
                      Row(children: [
                        Expanded(
                            child: StatCard(
                          label: 'Residents',
                          value: '${_data?['total_residents'] ?? 0}',
                          icon: Icons.people_alt_rounded,
                          color: AppTheme.primary,
                          onTap: () => context.push('/residents'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: StatCard(
                          label: 'Caregivers',
                          value: '${_data?['total_caregivers'] ?? 0}',
                          icon: Icons.medical_services_rounded,
                          color: AppTheme.accent,
                          onTap: () => context.push('/caregivers'),
                        )),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: StatCard(
                          label: 'Low Stock',
                          value: '${_data?['low_stock_count'] ?? 0}',
                          icon: Icons.inventory_2_rounded,
                          color: AppTheme.warning,
                          onTap: () => context.push('/inventory'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: StatCard(
                          label: 'Logs Today',
                          value: '${_data?['logs_today'] ?? 0}',
                          icon: Icons.assignment_rounded,
                          color: const Color(0xFF8B5CF6),
                          onTap: () => context.push('/health-logs'),
                        )),
                      ]),
                      const SizedBox(height: 28),

                      // ── Quick actions ─────────────────────────────
                      const SectionHeader('QUICK ACTIONS'),
                      Row(children: [
                        _QuickAction(
                          icon: Icons.person_add_rounded,
                          label: 'Add Resident',
                          color: AppTheme.primary,
                          onTap: () =>
                              context.push('/residents/new').then((_) => _load()),
                        ),
                        const SizedBox(width: 10),
                        _QuickAction(
                          icon: Icons.favorite_rounded,
                          label: 'Health Log',
                          color: Colors.pinkAccent,
                          onTap: () => context
                              .push('/health-logs/new')
                              .then((_) => _load()),
                        ),
                        const SizedBox(width: 10),
                        _QuickAction(
                          icon: Icons.medication_rounded,
                          label: 'Medication',
                          color: AppTheme.accent,
                          onTap: () => context
                              .push('/medications/new')
                              .then((_) => _load()),
                        ),
                      ]),
                      const SizedBox(height: 28),

                      // ── Critical residents ────────────────────────
                      if ((_data?['critical_residents'] as List?)?.isNotEmpty == true) ...[
                        Row(children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SectionHeader('CRITICAL ALERTS'),
                        ]),
                        const SizedBox(height: 6),
                        ...(_data!['critical_residents'] as List)
                            .map((r) => _CriticalCard(data: r)),
                        const SizedBox(height: 28),
                      ],

                      // ── Navigation grid ───────────────────────────
                      const SectionHeader('MODULES'),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.95,
                        children: const [
                          _ModuleCard(Icons.people_alt_rounded, 'Residents',
                              '/residents', AppTheme.primary),
                          _ModuleCard(Icons.medical_services_rounded,
                              'Caregivers', '/caregivers', AppTheme.accent),
                          _ModuleCard(Icons.favorite_rounded, 'Health Logs',
                              '/health-logs', Colors.pinkAccent),
                          _ModuleCard(Icons.medication_rounded, 'Medications',
                              '/medications', Color(0xFF8B5CF6)),
                          _ModuleCard(Icons.inventory_2_rounded, 'Inventory',
                              '/inventory', AppTheme.warning),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _GreetingBanner extends StatelessWidget {
  final String username;
  const _GreetingBanner({required this.username});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_greeting()},',
              style: TextStyle(
                  fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 2),
          Text(username,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ]),
      );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ]),
          ),
        ),
      );
}

class _CriticalCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CriticalCard({required this.data});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.danger.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppTheme.danger, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data['resident'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(data['caregiver_notes'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ]),
          ),
          const SizedBox(width: 8),
          StatusBadge.fromStatus(data['status'] ?? ''),
        ]),
      );
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String label, route;
  final Color color;
  const _ModuleCard(this.icon, this.label, this.route, this.color);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary)),
          ]),
        ),
      );
}