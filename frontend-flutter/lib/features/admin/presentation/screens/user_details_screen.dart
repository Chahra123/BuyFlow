import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                                    child: user.avatarUrl == null 
                                        ? Text(user.firstName[0], style: const TextStyle(fontSize: 48)) 
                                        : null,
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
                                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                                    title: const Text('Supprimer le compte', style: TextStyle(color: Colors.red)),
                                    onTap: () async {
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
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem(this.icon, this.label, this.value);
}
