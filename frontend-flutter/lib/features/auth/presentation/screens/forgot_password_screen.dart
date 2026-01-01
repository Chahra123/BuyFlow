import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:buy_flow/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authProvider.notifier)
          .forgotPassword(_emailController.text);

      if (success && mounted) {
        AppSnackBar.showSuccess(
          context,
          'Email de réinitialisation envoyé à ${_emailController.text} 📧',
        );
        await Future.delayed(const Duration(milliseconds: 800));
        context.pop();
      } else {
        final error = ref.read(authProvider).error;
        if (mounted) {
          AppSnackBar.showError(
            context,
            error ?? 'Erreur lors de l\'envoi de l\'email',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPassword)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(l10n.forgotPassword), // Or a better description key
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.fieldRequired;
                  }
                  if (!value.contains('@')) {
                    return l10n.enterValidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (state.error != null)
                Text(state.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _sendResetEmail,
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : Text(l10n.sendResetLink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
