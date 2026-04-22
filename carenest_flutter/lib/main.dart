import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  runApp(
    ChangeNotifierProvider.value(
      value: authService,
      child: const CareNestApp(),
    ),
  );
}

class CareNestApp extends StatelessWidget {
  const CareNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareNest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter(context.watch<AuthService>()),
    );
  }
}
