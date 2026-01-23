import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_provider.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadUser(int.parse(widget.userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final user = state.selectedUser;
    final currentUser = ref.watch(authProvider).user;
    final isOwnAccount = currentUser != null && user != null && currentUser.id == user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails Utilisateur'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/admin/users/edit', extra: user),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)))
              : user == null
                  ? const Center(child: Text('Utilisateur non trouvé'))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(adminProvider.notifier).loadUser(user.id),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Header Profile
                            Center(
                              child: Stack(
                                children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade200,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: _buildAvatarImage(context, user),
                                    ),
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: user.enabled ? Colors.green : Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(user.email, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                            const SizedBox(height: 12),
                            Chip(
                              label: Text(user.role),
                              backgroundColor: user.role == 'ADMIN' ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                              labelStyle: TextStyle(color: user.role == 'ADMIN' ? Colors.orange : Colors.blue),
                            ),
                            const SizedBox(height: 32),
                            
                            // Info Cards
                            _buildInfoCard(
                              title: 'Informations de Compte',
                              items: [
                                _InfoItem(Icons.badge, 'ID Utilisateur', user.id.toString()),
                                _InfoItem(Icons.calendar_today, 'Inscrit le', 
                                  user.createdAt != null ? DateFormat('dd MMMM yyyy HH:mm').format(user.createdAt!) : 'Inconnu'),
                                _InfoItem(Icons.check_circle, 'Statut', user.enabled ? 'Activé' : 'Désactivé'),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Actions
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: const Text('Compte Actif'),
                                    subtitle: const Text('Permet à l\'utilisateur de se connecter'),
                                    value: user.enabled,
                                    activeColor: Colors.green,
                                    onChanged: (value) async {
                                      final success = await ref.read(adminProvider.notifier).toggleUserStatus(user.id, value);
                                      if (success && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(value ? 'Compte activé' : 'Compte désactivé')),
                                        );
                                      }
                                    },
                                  ),
                                  const Divider(height: 1),
                                  ListTile(
                                    enabled: !isOwnAccount,
                                    leading: Icon(Icons.delete_forever, color: isOwnAccount ? Colors.grey : Colors.red),
                                    title: Text(
                                      isOwnAccount ? 'Vous ne pouvez pas supprimer votre propre compte' : 'Supprimer le compte',
                                      style: TextStyle(color: isOwnAccount ? Colors.grey : Colors.red),
                                    ),
                                    onTap: isOwnAccount ? null : () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Supprimer l\'utilisateur'),
                                          content: Text('Êtes-vous sûr de vouloir supprimer ${user.firstName} ${user.lastName} ? Cette action est irréversible.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              child: const Text('Supprimer'),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirmed == true && mounted) {
                                        await ref.read(adminProvider.notifier).deleteUser(user.id);
                                        if (mounted) {
                                          context.pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Utilisateur supprimé')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildInfoCard({required String title, required List<_InfoItem> items}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: Colors.blue),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(item.value, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
  Widget _buildAvatarImage(BuildContext context, user) {
    if (user.avatarUrl == null || user.avatarUrl!.isEmpty) {
      return Center(
        child: Text(
          user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      );
    }

    String imageUrl = user.avatarUrl!;
    if (!imageUrl.startsWith('http')) {
      String baseUrl = ApiConstants.baseUrl;
      imageUrl = '$baseUrl$imageUrl';
    }
    
    // Quick fix for Android Emulator 'localhost' issue
    if (!kIsWeb && imageUrl.contains('localhost') && Theme.of(context).platform == TargetPlatform.android) {
        imageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(strokeWidth: 4),
      )),
      errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, size: 40, color: Colors.red)),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem(this.icon, this.label, this.value);
}
