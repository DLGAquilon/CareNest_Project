import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Section header ────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSecondary,
        letterSpacing: 0.8,
      ),
    ),
  );
}

// ── Stat card — FIXED: no Spacer, uses intrinsic sizing ───────
// Previously used Spacer() inside a fixed-height container → overflow.
// Now uses Column with MainAxisSize.min inside an unconstrained container.
class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,           // ← fix: no fixed height needed
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

// ── Status badge WITH icon for color-blind accessibility ──────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const StatusBadge(this.label, {super.key, required this.color, this.icon});

  factory StatusBadge.fromStatus(String status) {
    Color c;
    IconData ic;
    switch (status.toLowerCase()) {
      case 'taken':
        c = AppTheme.success;
        ic = Icons.check_circle_rounded;
        break;
      case 'refused':
        c = AppTheme.danger;
        ic = Icons.cancel_rounded;
        break;
      case 'pending':
        c = AppTheme.warning;
        ic = Icons.schedule_rounded;
        break;
      case 'critical':
        c = AppTheme.danger;
        ic = Icons.emergency_rounded;
        break;
      case 'under observation':
        c = AppTheme.warning;
        ic = Icons.visibility_rounded;
        // Return abbreviated label to prevent overflow in tight spaces
        return StatusBadge('Under Obs.', color: c, icon: ic);
      case 'stable':
        c = AppTheme.success;
        ic = Icons.favorite_rounded;
        break;
      case 'sleeping':
        c = const Color(0xFF6366F1);
        ic = Icons.bedtime_rounded;
        break;
      default:
        c = AppTheme.textSecondary;
        ic = Icons.info_outline_rounded;
    }
    return StatusBadge(status, color: c, icon: ic);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
      ],
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ]),
  );
}

// ── Inventory stock bar ────────────────────────────────────────
class InventoryStockBar extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  const InventoryStockBar({
    super.key,
    required this.quantity,
    this.maxQuantity = 50,
  });

  @override
  Widget build(BuildContext context) {
    final ratio  = (quantity / maxQuantity).clamp(0.0, 1.0);
    final Color barColor;
    if (ratio > 0.5) {
      barColor = AppTheme.success;
    } else if (ratio > 0.2) {
      barColor = AppTheme.warning;
    } else {
      barColor = AppTheme.danger;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$quantity units',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: barColor,
          ),
        ),
      ]),
    ]);
  }
}

// ── Empty state ────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 56, color: AppTheme.textHint),
      const SizedBox(height: 12),
      Text(
        message,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
      ),
    ]),
  );
}

// ── Info row ───────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label, value;
  final IconData? icon;
  const InfoRow({super.key, required this.label, required this.value, this.icon});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      if (icon != null) ...[
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
      ],
      SizedBox(
        width: 130,
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    ]),
  );
}

// ── CareNest logo — compact version for login ─────────────────
// large: false = compact for login (keyboard-safe)
// large: true  = full for splash/onboarding only
class CareNestLogo extends StatelessWidget {
  final bool large;
  const CareNestLogo({super.key, this.large = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: EdgeInsets.all(large ? 14 : 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(large ? 20 : 14),
        ),
        child: Icon(
          Icons.local_hospital_rounded,
          size: large ? 32 : 22,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'CareNest',
          style: TextStyle(
            fontSize: large ? 26 : 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Eldercare Management',
          style: TextStyle(
            fontSize: large ? 12 : 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ]),
    ],
  );
}

// ── Formatted date helper ─────────────────────────────────────
// Converts "2026-04-18 08:00:00" → "Apr 18, 2026 08:00"
String formatDate(String? raw, {bool includeTime = false}) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    final dt = DateTime.parse(raw);
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final date = '${months[dt.month]} ${dt.day}, ${dt.year}';
    if (!includeTime) return date;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$date  $h:$m';
  } catch (_) {
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }
}
