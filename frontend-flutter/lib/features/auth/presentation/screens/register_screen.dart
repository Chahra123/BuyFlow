import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buy_flow/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedRole = 'USER';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).register(
            _emailController.text,
            _passwordController.text,
            _firstNameController.text,
            _lastNameController.text,
            _selectedRole,
          );
      if (success) {
        if (mounted) {
           AppSnackBar.showSuccess(context, "Compte créé avec succès !");
           context.go('/login');
        }
      } else {
        if (mounted) {
           AppSnackBar.showError(context, ref.read(authProvider).error ?? 'Erreur');
        }
      }
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
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Icon(Icons.rocket_launch_outlined, size: 80, color: Colors.white.withOpacity(0.9)),
                       const SizedBox(height: 24),
                       Text(
                         "Join BuyFlow",
                         style: GoogleFonts.outfit(
                           fontSize: 42,
                           fontWeight: FontWeight.bold,
                           color: Colors.white,
                           letterSpacing: 2,
                         ),
                       ),
                       const SizedBox(height: 12),
                       Text(
                         "Commencez votre aventure maintenant.",
                         textAlign: TextAlign.center,
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
                          "Inscription",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Remplissez les informations ci-dessous.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                        const SizedBox(height: 48),

                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(labelText: "Prénom"),
                              validator: (v) => v!.isEmpty ? "Requis" : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(labelText: "Nom"),
                              validator: (v) => v!.isEmpty ? "Requis" : null,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        
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
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            helperText: "8 caractères min, majuscule, chiffre",
                          ),
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 24),

                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          items: const [
                             DropdownMenuItem(value: 'USER', child: Text('Utilisateur Standard')),
                             DropdownMenuItem(value: 'ADMIN', child: Text('Administrateur')),
                          ],
                          onChanged: (v) => setState(() => _selectedRole = v!),
                          decoration: const InputDecoration(
                            labelText: "Rôle",
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 32),

                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            onPressed: _register,
                            child: const Text("Créer mon compte"),
                          ),
                        
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Déjà un compte ?", style: TextStyle(color: AppColors.textSecondary)),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text("Se connecter", style: TextStyle(fontWeight: FontWeight.bold)),
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
