import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/mobile_shell.dart';
import '../features/auth/provider/auth_provider.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/materials/screens/materials_index_screen.dart';
import '../features/materials/screens/material_detail_screen.dart';
import '../features/plants/screens/plants_screen.dart';
import '../features/vendors/screens/vendors_screen.dart';
import '../features/calculator/screens/calculator_screen.dart';
import '../features/visualize/screens/visualize_screen.dart';
import '../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../features/profile/screens/profile_screen.dart';

const _publicPaths = {'/welcome', '/login', '/signup'};

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Built once (in [VanaApp]'s state) so `authProvider` also drives
/// `refreshListenable` without the router itself being recreated.
GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final signedIn = authProvider.isSignedIn;
      final isPublic = _publicPaths.contains(state.uri.path);
      if (!signedIn && !isPublic) return '/welcome';
      if (signedIn && isPublic) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
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
          GoRoute(path: '/ai', builder: (context, state) => const AiAssistantScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => _NotFoundScreen(location: state.uri.toString()),
  );
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
