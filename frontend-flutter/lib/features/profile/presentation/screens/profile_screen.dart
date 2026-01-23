import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buy_flow/l10n/app_localizations.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Caméra'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final success = await ref.read(authProvider.notifier).uploadAvatar(bytes, image.name);
        if (success && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.successGeneric)),
           );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Erreur lors de la sélection de l\'image');
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

  Widget _buildAvatarImage(user) {
    if (user.avatarUrl == null || user.avatarUrl!.isEmpty) {
      return Center(
        child: Text(
          user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      );
    }

    String imageUrl = user.avatarUrl!;
    if (!imageUrl.startsWith('http')) {
      // Handle relative path
      String baseUrl = ApiConstants.baseUrl;
      // Fix for Android emulator accessing localhost
      if (baseUrl.contains('localhost')) {
         // This assumes the app might be running on emulator where localhost needs to be 10.0.2.2
         // However, we should be careful. 
         // A better approach is to rely on what works for the device.
         // But commonly:
         // baseUrl = baseUrl.replaceFirst('localhost', '10.0.2.2');
         // We will only do this if it fails? No, preemptive.
         // Let's rely on the fact that if it's relative, we append base.
      }
      imageUrl = '$baseUrl$imageUrl';
    }
    
    // Quick fix for Android Emulator 'localhost' issue if ApiConstants uses localhost
    if (!kIsWeb && imageUrl.contains('localhost') && Theme.of(context).platform == TargetPlatform.android) {
        imageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        return const Center(child: Icon(Icons.error, color: Colors.red));
      },
      // Force refresh if needed just by ensuring key changes with URL? URL changes with UUID.
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isCurrentPasswordVisible = false;
    bool isNewPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe actuel',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCurrentPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isCurrentPasswordVisible = !isCurrentPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isCurrentPasswordVisible,
                    validator: (val) => val!.isEmpty ? 'Requis' : null,
                  ),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isNewPasswordVisible = !isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isNewPasswordVisible,
                    validator: (val) => val!.length < 6 ? 'Min 6 caractères' : null,
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible = !isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isConfirmPasswordVisible,
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
                  onTap: _showImagePickerOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildAvatarImage(user),
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
