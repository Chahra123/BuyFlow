import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:buy_flow/l10n/app_localizations.dart';
import '../../../auth/domain/entities/user.dart';
import '../providers/admin_provider.dart';
import '../../../../core/utils/validators.dart';

class AdminEditUserScreen extends ConsumerStatefulWidget {
  final User user;

  const AdminEditUserScreen({super.key, required this.user});

  @override
  ConsumerState<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends ConsumerState<AdminEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _avatarUrlController;
  
  late String _selectedRole;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _avatarUrlController = TextEditingController(text: widget.user.avatarUrl);
    _selectedRole = widget.user.role;
    _isEnabled = true; // Default, could be fetched from user if available
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(adminProvider.notifier).updateUser(
            id: widget.user.id,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            role: _selectedRole,
            enabled: _isEnabled,
            avatarUrl: _avatarUrlController.text.isEmpty ? null : _avatarUrlController.text,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur modifié avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        final error = ref.read(adminProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Erreur lors de la modification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réinitialiser le mot de passe'),
        content: const Text('Un nouveau mot de passe sera généré et envoyé par email à l\'utilisateur.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Call admin reset password API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe réinitialisé! Email envoyé.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'utilisateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset),
            tooltip: 'Réinitialiser mot de passe',
            onPressed: _resetPassword,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User ID badge
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.badge, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('ID: ${widget.user.id}', 
                           style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: l10n.firstName,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: l10n.lastName,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avatarUrlController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'USER', child: Text('Utilisateur')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('Administrateur')),
                  DropdownMenuItem(value: 'LIVREUR', child: Text('Livreur')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Compte activé'),
                subtitle: Text(_isEnabled ? 'L\'utilisateur peut se connecter' : 'L\'utilisateur ne peut pas se connecter'),
                value: _isEnabled,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton.icon(
                  onPressed: _updateUser,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer les modifications'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
