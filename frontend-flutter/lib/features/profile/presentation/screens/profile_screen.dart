import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buy_flow/l10n/app_localizations.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _avatarUrlController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _avatarUrlController = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      final success = await ref.read(authProvider.notifier).uploadAvatar(bytes, image.name);
      if (success && mounted) {
        AppSnackBar.showSuccess(context, 'Photo de profil mise à jour');
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).updateProfile(
            _firstNameController.text,
            _lastNameController.text,
            _avatarUrlController.text,
          );
      
      if (success && mounted) {
         setState(() {
           _isEditing = false;
         });
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.successGeneric)));
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
                  obscureText: true,
                  validator: (val) => val!.isEmpty ? 'Requis' : null,
                ),
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? 'Min 6 caractères' : null,
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                  obscureText: true,
                  validator: (val) {
                    if (val!.isEmpty) return 'Requis';
                    if (val != newPasswordController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await ref.read(authProvider.notifier).changePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                      confirmPasswordController.text,
                    );
                if (mounted) {
                  if (success) {
                    Navigator.pop(context);
                    AppSnackBar.showSuccess(context, 'Mot de passe mis à jour');
                  } else {
                    final error = ref.read(authProvider).error;
                    AppSnackBar.showError(context, error ?? 'Erreur lors du changement');
                  }
                }
              }
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final user = state.user;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return const Center(child: Text('No user data'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                   _firstNameController.text = user.firstName;
                   _lastNameController.text = user.lastName;
                   _avatarUrlController.text = user.avatarUrl ?? '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
               ref.read(authProvider.notifier).logout();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.avatarUrl != null 
                            ? NetworkImage(user.avatarUrl!.startsWith('http') 
                                ? user.avatarUrl! 
                                : '${ApiConstants.baseUrl}${user.avatarUrl}') 
                            : null,
                        child: user.avatarUrl == null ? Text(user.firstName[0], style: const TextStyle(fontSize: 40)) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
               const SizedBox(height: 20),
               TextFormField(
                 controller: _firstNameController,
                 decoration: InputDecoration(labelText: l10n.firstName),
                 enabled: _isEditing,
                 validator: (val) => val!.isEmpty ? l10n.fieldRequired : null,
               ),
               const SizedBox(height: 16),
               TextFormField(
                 controller: _lastNameController,
                 decoration: InputDecoration(labelText: l10n.lastName),
                 enabled: _isEditing,
                 validator: (val) => val!.isEmpty ? l10n.fieldRequired : null,
               ),
               const SizedBox(height: 16),
               TextFormField(
                 controller: _avatarUrlController,
                 decoration: const InputDecoration(labelText: 'Avatar URL'),
                 enabled: _isEditing,
               ),
               const SizedBox(height: 24),
               if (_isEditing)
                 if (state.isLoading)
                   const CircularProgressIndicator()
                 else
                   ElevatedButton(
                     onPressed: _updateProfile,
                     child: Text(l10n.save),
                   ),
               const SizedBox(height: 16),
               if (!_isEditing)
                 Column(
                   children: [
                     OutlinedButton(
                       onPressed: _showChangePasswordDialog,
                       child: Text(l10n.changePassword),
                     ),
                     if (user.role == 'ADMIN') ...[
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/admin/dashboard'),
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Admin Dashboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                     ],
                   ],
                 ),
            ],
          ),
        ),
      ),
    );
  }
}
