import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/produit.dart';
import '../core/theme/app_colors.dart';
import '../features/commerce/presentation/providers/cart_provider.dart';
import '../features/commerce/presentation/providers/favorites_provider.dart';

class ProduitDetailPage extends ConsumerWidget {
  final Produit produit;

  const ProduitDetailPage({
    super.key,
    required this.produit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final favorites = ref.watch(favoritesProvider);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    final produitId = produit.idProduit;
    final isFavorite =
        produitId != null && favorites.contains(produitId);

    // 🔍 ligne panier
    final line = cart.lines.where(
          (l) => l.produit.idProduit == produit.idProduit,
    );

    final quantity = line.isNotEmpty ? line.first.quantity : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du produit"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(cartProvider).totalItems;
              return IconButton(
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text(count.toString()),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
        ],
      ),

      body: Container(
        color: Colors.grey[50],
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ================= CARD PRODUIT =================
                  Stack(
                    children: [
                      Card(
                        margin: const EdgeInsets.all(20),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 42,
                                backgroundColor: Colors.grey[200],
                                child: const Icon(
                                  Icons.shopping_bag,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),

                              const SizedBox(height: 20),

                              Text(
                                produit.libelleProduit,
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              if (produit.libelleCategorie != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.category_outlined,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        produit.libelleCategorie!,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 32),

                              _infoRow(
                                label: "Code produit",
                                value: produit.codeProduit,
                                icon: Icons.qr_code_2,
                              ),

                              const SizedBox(height: 18),

                              _infoRow(
                                label: "Prix",
                                value:
                                "${produit.prix.toStringAsFixed(2)} TND",
                                icon: Icons.payments,
                              ),

                              const SizedBox(height: 18),

                              _infoRow(
                                label: "Stock",
                                value:
                                produit.libelleStock ?? "Non assigné",
                                icon: Icons.inventory_2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ❤️ CŒUR FAVORIS — overlay UI propre
                      if (produitId != null)
                        Positioned(
                          top: 32,
                          right: 32,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (isFavorite) {
                                favoritesNotifier
                                    .removeFavorite(produitId);
                              } else {
                                favoritesNotifier
                                    .addFavorite(produitId);
                              }
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.blue,
                              size: 26,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ================= PANIER =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: quantity > 0
                              ? () => cartNotifier.setQty(
                            produit,
                            quantity - 1,
                          )
                              : null,
                          icon:
                          const Icon(Icons.remove_circle_outline),
                        ),

                        Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: () =>
                              cartNotifier.add(produit),
                          icon:
                          const Icon(Icons.add_circle_outline),
                        ),

                        const Spacer(),

                        ElevatedButton.icon(
                          onPressed: quantity > 0
                              ? () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                Text("Panier mis à jour"),
                              ),
                            );
                          }
                              : null,
                          icon:
                          const Icon(Icons.shopping_cart),
                          label: const Text("Ajouter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
