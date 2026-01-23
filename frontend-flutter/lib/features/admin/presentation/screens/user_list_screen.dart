import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:buy_flow/l10n/app_localizations.dart';
import '../providers/admin_provider.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(adminProvider.notifier).loadUsers(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(l10n.users),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/users/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchUsers,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      }
                    ) 
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.05),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(adminProvider.notifier).loadUsers(query: _searchController.text),
              child: state.isLoading && state.users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.users.isEmpty
                      ? Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text('Aucun utilisateur trouvé'),
                          ],
                        ))
                      : ListView.builder(
                          itemCount: state.users.length,
                          itemBuilder: (context, index) {
                            final user = state.users[index];
                            final createdAt = user.createdAt != null 
                                ? DateFormat('dd/MM/yyyy').format(user.createdAt!)
                                : 'Inconnu';

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                                      child: user.avatarUrl == null ? Text(user.firstName.isNotEmpty ? user.firstName[0] : '?') : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: user.enabled ? Colors.green : Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text('${user.firstName} ${user.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.email),
                                    Text('Inscrit le: $createdAt', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Chip(
                                      label: Text(user.role, style: const TextStyle(fontSize: 10)),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: user.role == 'ADMIN' ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                                onTap: () => context.push('/admin/users/${user.id}'),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
