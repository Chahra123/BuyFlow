import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/produit.dart';
import '../../../../models/categorie_produit.dart';
import '../../../../services/produits_service.dart';
import '../../../../services/categories_service.dart';
import '../../../../pages/produit_detail_page.dart';
import '../../../../core/theme/app_colors.dart';

import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

// ======================
// SERVICE PROVIDERS
// ======================
final _produitServiceProvider = Provider((ref) => ProduitService());
final _categorieServiceProvider =
Provider((ref) => CategorieProduitService());

// ======================
// SHOP SCREEN
// ======================
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String searchText = '';
  final Set<int> selectedCategorieIds = {};

  bool showFavoritesOnly = false; // ❤️ FILTRE FAVORIS
  bool _favoritesLoaded = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!_favoritesLoaded) {
        _favoritesLoaded = true;
        ref.read(favoritesProvider.notifier).loadFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final produitService = ref.read(_produitServiceProvider);
    final categorieService = ref.read(_categorieServiceProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              ref.watch(cartProvider).totalItems;
              return IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_outlined),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ======================
          // FILTRE TEXTE
          // ======================
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher un produit...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          // ======================
          // FILTRES (FAVORIS + CATÉGORIES)
          // ======================
          FutureBuilder<List<CategorieProduit>>(
            future: categorieService.getCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final categories = snapshot.data!;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // ❤️ FILTRE FAVORIS
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Row(
                          children: [
                            Icon(Icons.favorite, size: 16),
                            SizedBox(width: 4),
                            Text('Favoris'),
                          ],
                        ),
                        selected: showFavoritesOnly,
                        selectedColor: Colors.blue.withOpacity(0.15),
                        onSelected: (selected) {
                          setState(() {
                            showFavoritesOnly = selected;
                          });
                        },
                      ),
                    ),

                    // 📂 CATÉGORIES
                    ...categories.map((c) {
                      final isChecked =
                      selectedCategorieIds.contains(c.idCategorieProduit);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(c.libelleCategorie),
                          selected: isChecked,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedCategorieIds
                                    .add(c.idCategorieProduit!);
                              } else {
                                selectedCategorieIds
                                    .remove(c.idCategorieProduit);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // ======================
          // LISTE PRODUITS
          // ======================
          Expanded(
            child: FutureBuilder<List<Produit>>(
              future: produitService.getProduits(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snap.hasError) {
                  return Center(child: Text('Erreur : ${snap.error}'));
                }

                final allProduits = snap.data ?? [];

                final produits = allProduits.where((p) {
                  final matchText = searchText.isEmpty ||
                      p.libelleProduit
                          .toLowerCase()
                          .contains(searchText);

                  final matchCategorie =
                      selectedCategorieIds.isEmpty ||
                          selectedCategorieIds
                              .contains(p.idCategorieProduit);

                  final matchFavorite = !showFavoritesOnly ||
                      (p.idProduit != null &&
                          favorites.contains(p.idProduit));

                  return matchText && matchCategorie && matchFavorite;
                }).toList();

                if (produits.isEmpty) {
                  return const Center(
                    child: Text('Aucun produit trouvé'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: produits.length,
                  itemBuilder: (context, index) {
                    final p = produits[index];

                    return _ProductGridCard(
                      produit: p,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProduitDetailPage(produit: p),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================
// PRODUCT CARD
// ======================
class _ProductGridCard extends ConsumerWidget {
  final Produit produit;
  final VoidCallback onTap;

  const _ProductGridCard({
    required this.produit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitId = produit.idProduit;
    if (produitId == null) {
      return const SizedBox.shrink();
    }

    final favorites = ref.watch(favoritesProvider);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    final isFavorite = favorites.contains(produitId);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      produit.libelleProduit,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      produit.libelleCategorie ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${produit.prix.toStringAsFixed(2)} TND',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ❤️ CŒUR FAVORIS
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isFavorite) {
                    favoritesNotifier.removeFavorite(produitId);
                  } else {
                    favoritesNotifier.addFavorite(produitId);
                  }
                },
                child: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.blue,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
