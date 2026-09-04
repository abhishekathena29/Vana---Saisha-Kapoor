import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_badge.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );
    if (ok && mounted) context.go('/');
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
                Text('Create your account', style: AppTextStyles.display(fontSize: 28, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Save favourites, moodboards and estimates as you plan your space.',
                    style: AppTextStyles.sans(fontSize: 14, color: AppColors.mutedForeground, height: 1.4)),
                const SizedBox(height: 28),
                if (auth.errorMessage != null) AuthErrorBanner(message: auth.errorMessage!),
                AuthTextField(
                  controller: _nameCtrl,
                  label: 'Name',
                  hint: 'Aarav Sharma',
                  icon: LucideIcons.user,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
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
                  hint: 'At least 6 characters',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmCtrl,
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => (v != _passwordCtrl.text) ? 'Passwords don\'t match' : null,
                ),
                const SizedBox(height: 24),
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
                        : Text('Create account',
                            style: AppTextStyles.sans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryForeground)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'By continuing you agree to Vana\'s terms and privacy policy.',
                  style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground, height: 1.4),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.sans(fontSize: 13.5, color: AppColors.mutedForeground),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(text: 'Log in', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
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
