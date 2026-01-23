import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../commerce/data/models/order_models.dart';
import '../../data/services/delivery_service.dart';

final _deliveryServiceProvider = Provider((ref) => DeliveryService());

class DeliveryOrdersScreen extends ConsumerWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(_deliveryServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes livraisons')),
      body: FutureBuilder<List<CustomerOrderDto>>(
        future: service.assignedOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('Aucune livraison assignée'));
          }
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final o = orders[i];
              return ListTile(
                title: Text('Commande #${o.id}'),
                subtitle: Text(o.deliveryAddress ?? ''),
                trailing: const Icon(Icons.qr_code_scanner),
                onTap: () => context.push('/delivery/scan/${o.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
