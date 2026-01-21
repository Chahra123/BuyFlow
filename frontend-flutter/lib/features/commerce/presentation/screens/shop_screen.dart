import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/produit.dart';
import '../../../../services/produits_service.dart';
import '../providers/cart_provider.dart';

final _produitServiceProvider = Provider((ref) => ProduitService());

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(_produitServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique'),
        actions: [
          Consumer(builder: (context, ref, _) {
            final count = ref.watch(cartProvider).totalItems;
            return IconButton(
              onPressed: () => context.push('/cart'),
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text(count.toString()),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            );
          }),
        ],
      ),
      body: FutureBuilder<List<Produit>>(
        future: service.getProduits(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          final produits = snap.data ?? [];
          if (produits.isEmpty) {
            return const Center(child: Text('Aucun produit disponible'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: produits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = produits[i];
              return Card(
                child: ListTile(
                  title: Text(p.libelleProduit),
                  subtitle: Text('Prix: ${p.prix.toStringAsFixed(2)} TND'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      ref.read(cartProvider.notifier).add(p);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajouté au panier')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
