import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_badge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(email: _emailCtrl.text, password: _passwordCtrl.text);
    if (ok && mounted) context.go('/');
  }

  Future<void> _forgotPassword() async {
    final auth = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      auth.setError('Enter your email above first, then tap "Forgot password?" again.');
      return;
    }
    final ok = await auth.sendPasswordReset(email);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.go('/welcome'),
                  icon: const Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
                  style: IconButton.styleFrom(backgroundColor: AppColors.card, side: const BorderSide(color: AppColors.border)),
                ),
                const SizedBox(height: 24),
                const AppIconBadge(size: 44),
                const SizedBox(height: 16),
                Text('Welcome back', style: AppTextStyles.display(fontSize: 30, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Log in to pick up your saved rooms, favourites and estimates.',
                    style: AppTextStyles.sans(fontSize: 14, color: AppColors.mutedForeground, height: 1.4)),
                const SizedBox(height: 32),
                if (auth.errorMessage != null) AuthErrorBanner(message: auth.errorMessage!),
                AuthTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your email';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  hint: 'Your password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: auth.isLoading ? null : _forgotPassword,
                    child: Text('Forgot password?',
                        style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: auth.isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryForeground),
                          )
                        : Text('Log in', style: AppTextStyles.sans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryForeground)),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.sans(fontSize: 13.5, color: AppColors.mutedForeground),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(text: 'Sign up', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
