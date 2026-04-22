import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';

// Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

// Dashboard
import 'screens/dashboard_screen.dart';

// Residents
import 'screens/residents/residents_screen.dart';
import 'screens/residents/resident_detail_screen.dart';
import 'screens/residents/resident_form_screen.dart';

// Caregivers
import 'screens/caregivers/caregivers_screen.dart';
import 'screens/caregivers/caregiver_form_screen.dart';

// Health Logs
import 'screens/health_logs/health_log_screen.dart';
import 'screens/health_logs/health_log_form_screen.dart';

// Medications
import 'screens/medications/medication_screen.dart';
import 'screens/medications/medication_form_screen.dart';

// Inventory
import 'screens/inventory/inventory_screen.dart';
import 'screens/inventory/inventory_form_screen.dart';

GoRouter appRouter(AuthService auth) => GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = auth.isLoggedIn;
    final loc      = state.matchedLocation;
    final isPublic = loc == '/login' || loc == '/signup';

    if (!loggedIn && !isPublic) return '/login';
    if (loggedIn  &&  isPublic) return '/';
    return null;
  },
  routes: [
    // ── Auth ──────────────────────────────────────────────
    GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),

    // ── Dashboard ─────────────────────────────────────────
    GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),

    // ── Residents ─────────────────────────────────────────
    GoRoute(path: '/residents',          builder: (_, __) => const ResidentsScreen()),
    GoRoute(path: '/residents/new',      builder: (_, __) => const ResidentFormScreen()),
    GoRoute(path: '/residents/:id',      builder: (_, s)  => ResidentDetailScreen(
        id: int.parse(s.pathParameters['id']!))),
    GoRoute(path: '/residents/:id/edit', builder: (_, s)  => ResidentFormScreen(
        residentId: int.parse(s.pathParameters['id']!))),

    // ── Caregivers ────────────────────────────────────────
    GoRoute(path: '/caregivers',          builder: (_, __) => const CaregiversScreen()),
    GoRoute(path: '/caregivers/new',      builder: (_, __) => const CaregiverFormScreen()),
    GoRoute(path: '/caregivers/:id/edit', builder: (_, s)  => CaregiverFormScreen(
        caregiverId: int.parse(s.pathParameters['id']!))),

    // ── Health Logs ───────────────────────────────────────
    GoRoute(path: '/health-logs',     builder: (_, __) => const HealthLogScreen()),
    GoRoute(path: '/health-logs/new', builder: (_, __) => const HealthLogFormScreen()),

    // ── Medications ───────────────────────────────────────
    GoRoute(path: '/medications',     builder: (_, __) => const MedicationScreen()),
    GoRoute(path: '/medications/new', builder: (_, __) => const MedicationFormScreen()),

    // ── Inventory ─────────────────────────────────────────
    GoRoute(path: '/inventory',          builder: (_, __) => const InventoryScreen()),
    GoRoute(path: '/inventory/new',      builder: (_, __) => const InventoryFormScreen()),
    GoRoute(path: '/inventory/:id/edit', builder: (_, s)  => InventoryFormScreen(
        itemId: int.parse(s.pathParameters['id']!))),
  ],
);
