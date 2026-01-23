import 'package:flutter/material.dart';
import '../services/categories_service.dart';
import '../models/categorie_produit.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategorieProduitService service = CategorieProduitService();
  late Future<List<CategorieProduit>> categories;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  void _refreshCategories() {
    setState(() {
      categories = service.getCategories();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF0074D9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCategorieDialog({CategorieProduit? categorie}) {
    final isEdit = categorie != null;

    final codeCtrl =
    TextEditingController(text: categorie?.codeCategorie ?? '');
    final libelleCtrl =
    TextEditingController(text: categorie?.libelleCategorie ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? "Modifier la catégorie" : "Nouvelle catégorie",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF00509E)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: "Code catégorie",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: libelleCtrl,
              decoration: const InputDecoration(
                labelText: "Libellé catégorie",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0074D9),
            ),
            onPressed: () async {
              final code = codeCtrl.text.trim();
              final libelle = libelleCtrl.text.trim();

              if (code.isEmpty || libelle.isEmpty) {
                _showSnackBar("Code et libellé sont obligatoires", isError: true);
                return;
              }

              final newCategorie = CategorieProduit(
                idCategorieProduit: categorie?.idCategorieProduit,
                codeCategorie: code,
                libelleCategorie: libelle,
              );

              try {
                if (isEdit) {
                  await service.updateCategorie(newCategorie);
                  _showSnackBar("Catégorie modifiée avec succès !");
                } else {
                  await service.addCategorie(newCategorie);
                  _showSnackBar("Catégorie ajoutée avec succès !");
                }
                Navigator.pop(context);
                _refreshCategories();
              } catch (e) {
                _showSnackBar("Erreur lors de l'opération", isError: true);
              }
            },
            child: Text(
              isEdit ? "Modifier" : "Ajouter",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catégories produits")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0074D9),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showCategorieDialog(),
      ),
      body: FutureBuilder<List<CategorieProduit>>(
        future: categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0074D9)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Aucune catégorie",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            );
          }

          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final c = list[i];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.category,
                    size: 36,
                    color: Color(0xFF0074D9),
                  ),
                  title: Text(
                    c.libelleCategorie,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text("Code : ${c.codeCategorie}"),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "edit", child: Text("Modifier")),
                      PopupMenuItem(
                        value: "delete",
                        child: Text(
                          "Supprimer",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == "edit") {
                        _showCategorieDialog(categorie: c);
                      } else if (value == "delete" &&
                          c.idCategorieProduit != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Supprimer ?"),
                            content: Text(
                              "Voulez-vous vraiment supprimer « ${c.libelleCategorie} » ?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text("Non"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text(
                                  "Oui",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await service.deleteCategorie(c.idCategorieProduit!);
                            _showSnackBar("Catégorie supprimée avec succès !");
                            _refreshCategories();
                          } catch (e) {
                            _showSnackBar("Échec de la suppression", isError: true);
                          }
                        }
                      }
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
