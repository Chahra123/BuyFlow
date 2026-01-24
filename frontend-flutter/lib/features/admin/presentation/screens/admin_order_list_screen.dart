import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../providers/admin_orders_provider.dart';
import '../../../auth/domain/entities/user.dart';

class AdminOrderListScreen extends ConsumerStatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  ConsumerState<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends ConsumerState<AdminOrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminOrdersProvider.notifier).loadOrders();
    });
  }

  void _showAssignCourierDialog(int orderId) {
    showDialog(
      context: context,
      builder: (context) => _AssignCourierDialog(orderId: orderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminOrdersProvider.notifier).loadOrders(),
          ),
        ],
      ),
      body: state.isLoading && state.orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('Aucune commande trouvée'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    final date = order.createdAt != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order.createdAt!))
                        : 'Date inconnue';
                    final customerName = order.user != null
                        ? '${order.user!.firstName} ${order.user!.lastName}'
                        : 'Client Inconnu';
                    final hasCourier = order.assignedCourier != null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Commande #${order.id}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                _buildStatusChip(order.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Client: $customerName'),
                            Text('Date: $date', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${order.totalAmount?.toStringAsFixed(2) ?? '0.000'} TND',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                if (order.status != 'CANCELLED' && order.status != 'DELIVERED')
                                  ElevatedButton.icon(
                                    onPressed: () => _showAssignCourierDialog(order.id),
                                    icon: Icon(hasCourier ? Icons.edit : Icons.local_shipping, size: 16),
                                    label: Text(hasCourier ? 'Modifier Livreur' : 'Assigner Livreur'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasCourier ? Colors.orange : Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                              ],
                            ),
                            if (hasCourier) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.motorcycle, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('Livreur: ${order.assignedCourier!.firstName} ${order.assignedCourier!.lastName}',
                                        style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'PLACED':
        color = Colors.blue;
        break;
      case 'CONFIRMED':
        color = Colors.indigo;
        break;
      case 'ASSIGNED':
        color = Colors.orange;
        break;
      case 'OUT_FOR_DELIVERY':
        color = Colors.purple;
        break;
      case 'DELIVERED':
        color = Colors.green;
        break;
      case 'CANCELLED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

class _AssignCourierDialog extends ConsumerStatefulWidget {
  final int orderId;
  const _AssignCourierDialog({required this.orderId});

  @override
  ConsumerState<_AssignCourierDialog> createState() => _AssignCourierDialogState();
}

class _AssignCourierDialogState extends ConsumerState<_AssignCourierDialog> {
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Load users to select from
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadUsers(size: 100); // Load reasonably large number to start
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final orderState = ref.watch(adminOrdersProvider);

    // Filter for couriers
    final couriers = adminState.users
        .where((u) => u.role == 'LIVREUR' || u.role == 'DELIVERY')
        .where((u) => u.firstName.toLowerCase().contains(_searchController.text.toLowerCase()) || 
                      u.lastName.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return AlertDialog(
      title: const Text('Assigner un Livreur'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher un livreur',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (adminState.isLoading)
              const LinearProgressIndicator()
            else if (couriers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Aucun livreur trouvé'),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: couriers.length,
                  itemBuilder: (context, index) {
                    final user = couriers[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(user.firstName[0])),
                      title: Text('${user.firstName} ${user.lastName}'),
                      subtitle: Text(user.email),
                      onTap: () async {
                        try {
                          await ref.read(adminOrdersProvider.notifier).assignCourier(widget.orderId, user.id);
                          if (mounted) Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Livreur assigné avec succès')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
