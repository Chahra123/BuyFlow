import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../commerce/data/models/order_models.dart';
import '../../data/services/delivery_service.dart';

final _deliveryServiceProvider = Provider((ref) => DeliveryService());

class DeliveryOrdersScreen extends ConsumerStatefulWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  ConsumerState<DeliveryOrdersScreen> createState() => _DeliveryOrdersScreenState();
}

class _DeliveryOrdersScreenState extends ConsumerState<DeliveryOrdersScreen> {
  late Future<List<CustomerOrderDto>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _ordersFuture = ref.read(_deliveryServiceProvider).assignedOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes livraisons')),
      body: FutureBuilder<List<CustomerOrderDto>>(
        future: _ordersFuture,
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      tooltip: 'Valider (Livré & Payé)',
                      onPressed: () async {
                        try {
                          await ref.read(_deliveryServiceProvider).validateDelivery(o.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Commande validée !')),
                            );
                            setState(() {
                              _refresh();
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () => context.push('/delivery/scan/${o.id}'),
                    ),
                  ],
                ),
                onTap: () => context.push('/delivery/scan/${o.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
