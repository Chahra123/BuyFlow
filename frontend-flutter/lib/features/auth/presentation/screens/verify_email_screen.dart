import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String? token;

  const VerifyEmailScreen({super.key, this.token});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verify();
      });
    }
  }

  Future<void> _verify() async {
    setState(() => _isVerifying = true);
    final success = await ref.read(authProvider.notifier).verifyEmail(widget.token!);
    
    if (mounted) {
      if (success) {
        AppSnackBar.showSuccess(context, 'Email vérifié avec succès ! Vous pouvez maintenant vous connecter.');
        context.go('/login');
      } else {
        final error = ref.read(authProvider).error;
        AppSnackBar.showError(context, error ?? 'Échec de la vérification');
      }
    }
    if (mounted) setState(() => _isVerifying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification Email')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.token == null || widget.token!.isEmpty)
                const Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.orange),
                    SizedBox(height: 16),
                    Text('Lien invalide ou token manquant.', textAlign: TextAlign.center),
                  ],
                )
              else if (_isVerifying)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Vérification de votre compte...', textAlign: TextAlign.center),
                  ],
                )
              else if (ref.watch(authProvider).error != null)
                Column(
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      ref.watch(authProvider).error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _verify,
                      child: const Text('Réessayer la vérification'),
                    ),
                  ],
                )
              else
                const Text('Initialisation de la vérification...', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
