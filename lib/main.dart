import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';
import 'widgets/mobile_shell.dart';
import 'screens/home_screen.dart';
import 'screens/materials_index_screen.dart';
import 'screens/material_detail_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/vendors_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/visualize_screen.dart';

void main() {
  runApp(const VanaApp());
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MobileShell(
          location: state.uri.toString(),
          onNavigate: (path) => context.go(path),
          child: child,
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/materials', builder: (context, state) => const MaterialsIndexScreen()),
        GoRoute(
          path: '/materials/:id',
          builder: (context, state) => MaterialDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(path: '/plants', builder: (context, state) => const PlantsScreen()),
        GoRoute(path: '/vendors', builder: (context, state) => const VendorsScreen()),
        GoRoute(path: '/calculator', builder: (context, state) => const CalculatorScreen()),
        GoRoute(path: '/visualize', builder: (context, state) => const VisualizeScreen()),
      ],
    ),
  ],
  errorBuilder: (context, state) => _NotFoundScreen(location: state.uri.toString()),
);

class VanaApp extends StatelessWidget {
  const VanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vana — Sustainable Interior Design',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  final String location;
  const _NotFoundScreen({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('404', style: AppTextStyles.display(fontSize: 56, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Page not found', style: AppTextStyles.sans(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                'This page has grown roots elsewhere.',
                textAlign: TextAlign.center,
                style: AppTextStyles.sans(fontSize: 13, color: AppColors.mutedForeground),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Back home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
