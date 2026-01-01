import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final stats = state.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminProvider.notifier).loadStats(),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Admin'),
              accountEmail: Text('admin@buyflow.com'),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.admin_panel_settings)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => context.go('/admin/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Utilisateurs'),
              onTap: () => context.go('/admin/users'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Retour à l\'App'),
              onTap: () => context.go('/'),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminProvider.notifier).loadStats(),
        child: state.isLoading && stats == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Aperçu de l\'Activité',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                          'Total Utilisateurs',
                          '${stats?.totalUsers ?? 0}',
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Comptes Actifs',
                          '${stats?.enabledUsers ?? 0}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Administrateurs',
                          '${stats?.adminUsers ?? 0}',
                          Icons.security,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Nouveaux (24h)',
                          '${stats?.newUsersLast24h ?? 0}',
                          Icons.person_add,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Actions Rapides',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ListTile(
                      tileColor: Colors.blue.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person_add, color: Colors.white)),
                      title: const Text('Créer un utilisateur'),
                      subtitle: const Text('Ajouter manuellement un compte'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/admin/users'), // Or dedicated create screen
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
