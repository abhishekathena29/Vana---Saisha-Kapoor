import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/provider/auth_provider.dart';
import '../features/favorites/provider/favorites_provider.dart';
import '../features/calculator/provider/estimates_provider.dart';
import '../features/visualize/provider/moodboards_provider.dart';
import '../features/vendors/provider/vendors_provider.dart';
import '../features/ai_assistant/provider/chat_provider.dart';
import 'router.dart';

class VanaApp extends StatefulWidget {
  const VanaApp({super.key});

  @override
  State<VanaApp> createState() => _VanaAppState();
}

class _VanaAppState extends State<VanaApp> {
  final AuthProvider _authProvider = AuthProvider();
  late final GoRouter _router = buildRouter(_authProvider);

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => EstimatesProvider()),
        ChangeNotifierProvider(create: (_) => MoodboardsProvider()),
        ChangeNotifierProvider(create: (_) => VendorsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp.router(
        title: 'Vana — Sustainable Interior Design',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: _router,
      ),
    );
  }
}
