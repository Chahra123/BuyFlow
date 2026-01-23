import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: cart.lines.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, idx) {
                final line = cart.lines[idx];
                return ListTile(
                  title: Text(line.produit.libelleProduit),
                  subtitle: Text('${line.produit.prix.toStringAsFixed(2)} TND'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => notifier.setQty(line.produit, line.quantity - 1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(line.quantity.toString()),
                      IconButton(
                        onPressed: () => notifier.setQty(line.produit, line.quantity + 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      IconButton(
                        onPressed: () => notifier.remove(line.produit),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: cart.lines.length,
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total: ${cart.total.toStringAsFixed(2)} TND',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton(
                onPressed: cart.lines.isEmpty ? null : () => context.push('/checkout'),
                child: const Text('Commander'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
