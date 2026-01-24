import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../../../l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.adminDashboard),
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
              title: Text(AppLocalizations.of(context)!.dashboard),
              onTap: () => context.go('/admin/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(AppLocalizations.of(context)!.users),
              onTap: () => context.go('/admin/users'),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text(AppLocalizations.of(context)!.mesCommandes),
              onTap: () => context.go('/admin/orders'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: Text(AppLocalizations.of(context)!.retourApp),
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
                    Text(AppLocalizations.of(context)!.apercuActivite,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          AppLocalizations.of(context)!.totalUtilisateurs,
                          '${stats?.totalUsers ?? 0}',
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          AppLocalizations.of(context)!.comptesActifs,
                          '${stats?.enabledUsers ?? 0}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatCard(
                          AppLocalizations.of(context)!.administrateurs,
                          '${stats?.adminUsers ?? 0}',
                          Icons.security,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          AppLocalizations.of(context)!.nouveaux24h,
                          '${stats?.newUsersLast24h ?? 0}',
                          Icons.person_add,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(AppLocalizations.of(context)!.actionsRapides,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ListTile(
                      tileColor: Colors.blue.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person_add, color: Colors.white)),
                      title: Text(AppLocalizations.of(context)!.creerUtilisateur),
                      subtitle: Text(AppLocalizations.of(context)!.ajouterManuellement),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/admin/users'),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      tileColor: Colors.orange.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.shopping_bag, color: Colors.white)),
                      title: Text(AppLocalizations.of(context)!.gererCommandes),
                      subtitle: Text(AppLocalizations.of(context)!.voirAssignerLivreurs),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/admin/orders'),
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
