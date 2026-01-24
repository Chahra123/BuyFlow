import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buy_flow/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

   bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authProvider.notifier)
          .login(_emailController.text, _passwordController.text);
      if (success) {
        if (mounted) context.go('/');
      } else {
        if (mounted) {
           AppSnackBar.showError(context, ref.read(authProvider).error ?? 'Erreur');
        }
      }
    }
  }

  void _googleLogin() async {
    final url = Uri.parse('http://127.0.0.1:9091/oauth2/authorization/google');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: Row(
        children: [
          // Left Side - Decorative
          if (MediaQuery.of(context).size.width > 900)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Icon(Icons.inventory_2_outlined, size: 80, color: Colors.white.withOpacity(0.9)),
                       const SizedBox(height: 24),
                       Text(
                         "BuyFlow",
                         style: GoogleFonts.outfit(
                           fontSize: 42,
                           fontWeight: FontWeight.bold,
                           color: Colors.white,
                           letterSpacing: 2,
                         ),
                       ),
                       const SizedBox(height: 12),
                       Text(
                         "Gérez votre stock intelligemment.",
                         style: GoogleFonts.outfit(
                           fontSize: 18,
                           color: Colors.white70,
                           ),
                       ),
                    ],
                  ),
                ),
              ),
            ),

          // Right Side - Form
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.welcomeBack,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                        const SizedBox(height: 48),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: l10n.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? l10n.fieldRequired : null,
                          onFieldSubmitted: (_) => _login(),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(
                              l10n.forgotPassword,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            onPressed: _login,
                            child: Text(l10n.login),
                          ),
                        
                        const SizedBox(height: 24),
                        Row(children: [
                          const Expanded(child: Divider()),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(l10n.ou)),
                          const Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 24),

                        OutlinedButton.icon(
                          onPressed: _googleLogin,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: Text(l10n.continuerAvecGoogle),
                        ),

                        const SizedBox(height: 32),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(l10n.noAccount, style: TextStyle(color: AppColors.textSecondary)),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: Text(l10n.createAccount, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
