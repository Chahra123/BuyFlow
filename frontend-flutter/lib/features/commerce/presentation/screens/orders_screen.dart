import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/order_models.dart';
import '../../data/services/orders_service.dart';

final _ordersServiceProvider = Provider((ref) => OrdersService());

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(_ordersServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: FutureBuilder<List<CustomerOrderDto>>(
        future: service.myOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? const [];
          if (orders.isEmpty) {
            return const Center(child: Text('Aucune commande'));
          }
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final o = orders[i];
              return ListTile(
                title: Text('Commande #${o.id}'),
                subtitle: Text(o.status),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/orders/${o.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
