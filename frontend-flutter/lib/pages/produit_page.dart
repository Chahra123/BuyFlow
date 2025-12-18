import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/produits_service.dart';
import '../models/produit.dart';
import '../services/stocks_service.dart';

class ProduitsPage extends StatefulWidget {
  const ProduitsPage({super.key});

  @override
  State<ProduitsPage> createState() => _ProduitsPageState();
}

class _ProduitsPageState extends State<ProduitsPage> {
  final ProduitService service = ProduitService();
  late Future<List<Produit>> produits;
  late Future<List<Stock>> stocksFuture;
  int? selectedStockId;

  @override
  void initState() {
    super.initState();
    stocksFuture = StockService().getStocks();
    setState(() {
      produits = _loadProduitsAvecQuantite();
    });
  }

  void _refreshProduits() {
    setState(() {
      produits = service.getProduits();
    });
  }

  Future<List<Produit>> _loadProduitsAvecQuantite() async {
    final list = await service.getProduits();
    final List<Produit> updatedList = [];

    for (var p in list) {
      int qte = 0;
      try {
        qte = await service.getQuantiteProduit(p.idProduit!);
      } catch (e) {
        qte = 0;
      }

      updatedList.add(Produit(
        idProduit: p.idProduit,
        codeProduit: p.codeProduit,
        libelleProduit: p.libelleProduit,
        prix: p.prix,
        dateCreation: p.dateCreation,
        dateDerniereModification: p.dateDerniereModification,
        idStock: p.idStock,
        libelleStock: p.libelleStock,
        stockQte: qte,
      ));
    }

    return updatedList;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle,
                color: Colors.white),
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

  void _showProduitDialog({Produit? produit}) {
    final isEdit = produit != null;
    final codeCtrl = TextEditingController(text: produit?.codeProduit ?? '');
    final libelleCtrl = TextEditingController(text: produit?.libelleProduit ?? '');
    final prixCtrl = TextEditingController(text: produit?.prix.toString() ?? '');
    final qteInitialeCtrl = TextEditingController(text: '0');

    int? selectedStockId = produit?.idStock;
    int? originalStockId = produit?.idStock;  // Garder le stock d'origine

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(  // Pour rebuilder le dialog
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEdit ? "Modifier le produit" : "Nouveau produit",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF00509E)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: "Code produit",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: libelleCtrl,
                  decoration: const InputDecoration(
                    labelText: "Libellé produit",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: prixCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Prix",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // 🆕 Dropdown avec onChange pour rebuild
                FutureBuilder<List<Stock>>(
                  future: stocksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text("Erreur : ${snapshot.error}");
                    }
                    final stocks = snapshot.data ?? [];
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Stock",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStockId,
                      items: stocks.map((s) => DropdownMenuItem(
                        value: s.idStock,
                        child: Text(s.libelleStock),
                      )).toList(),
                      onChanged: (value) {
                        setDialogState(() {  // Rebuild le dialog
                          selectedStockId = value;
                        });
                      },
                    );
                  },
                ),

                // Afficher le champ quantité SEULEMENT si :
                // - Nouveau produit OU
                // - Modification avec changement de stock
                if (!isEdit || (isEdit && selectedStockId != originalStockId)) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: qteInitialeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isEdit
                          ? "Quantité à transférer"
                          : "Quantité initiale",
                      border: const OutlineInputBorder(),
                      helperText: isEdit
                          ? "Quantité à ajouter au nouveau stock"
                          : null,
                    ),
                  ),
                ],

                // Message informatif en mode édition
                if (isEdit && selectedStockId == originalStockId) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Pour ajuster la quantité, utilisez 'Mouvement stock'",
                            style: TextStyle(fontSize: 13, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0074D9)),
              onPressed: () async {
                final code = codeCtrl.text.trim();
                final libelle = libelleCtrl.text.trim();
                final prix = double.tryParse(prixCtrl.text) ?? 0.0;
                final qteInitiale = int.tryParse(qteInitialeCtrl.text) ?? 0;

                if (code.isEmpty || libelle.isEmpty) {
                  _showSnackBar("Code et libellé obligatoires", isError: true);
                  return;
                }

                final newProduit = Produit(
                  idProduit: produit?.idProduit,
                  codeProduit: code,
                  libelleProduit: libelle,
                  prix: prix,
                  idStock: selectedStockId,
                );

                try {
                  final saved = isEdit
                      ? await service.updateProduit(newProduit)
                      : await service.addProduit(newProduit);

                  // Cas 1 : Nouveau produit avec stock
                  if (!isEdit && selectedStockId != null) {
                    await service.assignProduitToStock(
                        saved.idProduit!,
                        selectedStockId!,
                        qteInitiale
                    );
                  }

                  // Cas 2 : Modification avec changement de stock
                  else if (isEdit && selectedStockId != null && selectedStockId != originalStockId) {
                    await service.assignProduitToStock(
                        saved.idProduit!,
                        selectedStockId!,
                        qteInitiale
                    );
                  }

                  _showSnackBar(isEdit ? "Produit modifié !" : "Produit ajouté !");
                  setState(() {
                    produits = _loadProduitsAvecQuantite();
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSnackBar("Erreur : $e", isError: true);
                }
              },
              child: const Text("Valider", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showMouvementDialog({required Produit produit}) {
    final _formKey = GlobalKey<FormState>();
    int quantite = 0;
    String type = "ENTREE";

    // Sécurité front minimale
    if (produit.idProduit == null) {
      _showSnackBar("Produit invalide", isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mouvement de stock"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: "ENTREE", child: Text("Entrée")),
                  DropdownMenuItem(value: "SORTIE", child: Text("Sortie")),
                ],
                decoration: const InputDecoration(labelText: "Type"),
                onChanged: (value) => type = value!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantité"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Quantité obligatoire";
                  }
                  final q = int.tryParse(value);
                  if (q == null || q <= 0) {
                    return "Quantité invalide";
                  }
                  return null;
                },
                onSaved: (value) => quantite = int.parse(value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();

              try {
                await service.effectuerMouvement(
                  produitId: produit.idProduit!,
                  quantite: quantite,
                  type: type,
                );

                Navigator.pop(context);
                _showSnackBar("Mouvement effectué avec succès");
                _refreshProduits();
              } catch (e) {
                final msg = e.toString().contains("Quantité insuffisante")
                    ? "Quantité insuffisante en stock"
                    : "Erreur lors du mouvement de stock";

                _showSnackBar(msg, isError: true);
              }
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: const Color(0xFF0074D9),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0074D9),
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Liste des produits")),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF0074D9),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _showProduitDialog(),
        ),
        body: FutureBuilder<List<Produit>>(
          future: produits,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0074D9)));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Erreur : ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Aucun produit", style: TextStyle(color: Colors.grey, fontSize: 18)));
            }
            final list = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final p = list[i];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag, size: 36, color: Color(0xFF0074D9)),
                    title: Text(p.libelleProduit, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(
                      "Code: ${p.codeProduit} • Prix: ${p.prix}\n"
                          "Stock: ${p.libelleStock ?? 'Aucun'} • Qté dispo: ${p.stockQte ?? '–'}",
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: "edit", child: Text("Modifier")),
                        const PopupMenuItem(value: "mouvement", child: Text("Mouvement stock")),
                        const PopupMenuItem(value: "delete", child: Text("Supprimer", style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (value) async {
                        if (value == "edit")
                          _showProduitDialog(produit: p);
                        else if (value == "mouvement") {
                          if (p.idStock == null) {
                            _showSnackBar(
                              "Impossible d’effectuer un mouvement : le produit n’est assigné à aucun stock.",
                              isError: true,
                            );
                            return;
                          }
                          _showMouvementDialog(produit: p);
                        }
                        else if (value == "delete" && p.idProduit != null) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Supprimer ?"),
                              content: Text("Voulez-vous vraiment supprimer « ${p.libelleProduit} » ?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Non")),
                                TextButton(onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Oui", style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await service.deleteProduit(p.idProduit!);
                              _showSnackBar("Produit supprimé avec succès !");
                              _loadProduitsAvecQuantite();
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
      ),
    );
  }
}