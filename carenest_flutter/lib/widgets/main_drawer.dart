import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});
  @override State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  int _lowStockCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      final res = await ApiService.get('/dashboard');
      if (mounted) {
        setState(() => _lowStockCount = res.data['low_stock_count'] ?? 0);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final role = user?['role'] ?? 'Administrator';

    return Drawer(
      backgroundColor: AppTheme.bgCard,
      child: Column(children: [
        // ── Profile header ──────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                (user?['username'] ?? 'A')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + role
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  user?['username'] ?? 'Admin',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user?['email'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),

        // ── Navigation items ────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const SizedBox(height: 4),
              const _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  route: '/'),
              const _NavItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Residents',
                  route: '/residents'),
              const _NavItem(
                  icon: Icons.medical_services_rounded,
                  label: 'Caregivers',
                  route: '/caregivers'),
              const _NavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Health Logs',
                  route: '/health-logs'),
              const _NavItem(
                  icon: Icons.medication_rounded,
                  label: 'Medications',
                  route: '/medications'),
                _NavItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventory',
                  route: '/inventory',
                  // Badge shows low stock count — updates on drawer open
                  badge: _lowStockCount > 0 ? '$_lowStockCount' : null,
                  badgeColor: AppTheme.warning),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(height: 1),
              ),

              // Logout — InkWell for explicit pressed ripple
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    splashColor: AppTheme.danger.withValues(alpha: 0.1),
                    highlightColor: AppTheme.danger.withValues(alpha: 0.06),
                    onTap: () async {
                      Navigator.pop(context);
                      await context.read<AuthService>().logout();
                      if (context.mounted) context.go('/login');
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(children: [
                        Icon(Icons.logout_rounded,
                            color: AppTheme.danger, size: 20),
                        SizedBox(width: 16),
                        Text('Sign Out',
                            style: TextStyle(
                              color: AppTheme.danger,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            )),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Footer ──────────────────────────────────────
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          child: Row(children: [
            const Icon(Icons.local_hospital_rounded,
                size: 14, color: AppTheme.textHint),
            const SizedBox(width: 6),
            const Text('CareNest v1.0.0',
                style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
          ]),
        ),
      ]),
    );
  }
}

// ── Nav item with active state + pressed ripple + optional badge ──
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label, route;
  final String?  badge;
  final Color    badgeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
    this.badgeColor = AppTheme.danger,
  });

  @override
  Widget build(BuildContext context) {
    final loc    = GoRouterState.of(context).matchedLocation;
    final active = loc == route ||
        (route != '/' && loc.startsWith(route));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: active ? AppTheme.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          // Explicit pressed colour — requirement from QA
          splashColor: AppTheme.primary.withOpacity(0.12),
          highlightColor: AppTheme.primary.withOpacity(0.08),
          onTap: () {
            Navigator.pop(context);
            context.go(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 11),
            child: Row(children: [
              // Icon — active = filled colour, inactive = muted
              Icon(
                icon,
                size: 20,
                color: active ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 14),

              // Label
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? AppTheme.primary
                        : AppTheme.textPrimary,
                  ),
                ),
              ),

              // Optional badge (e.g. low stock count)
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),

              // Active indicator dot
              if (active) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
