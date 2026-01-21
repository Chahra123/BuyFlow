import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stock.dart';
import '../services/produits_service.dart';
import '../models/produit.dart';
import '../services/stocks_service.dart';
import '../core/theme/app_colors.dart';

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
    _refreshProduits();
  }

  void _refreshProduits() {
    setState(() {
      produits = _loadProduitsAvecQuantite();
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
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.outfit(fontSize: 14))),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
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
    int? originalStockId = produit?.idStock;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isEdit ? "Modifier" : "Nouveau produit",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: "Code produit", prefixIcon: Icon(Icons.qr_code)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: libelleCtrl,
                  decoration: const InputDecoration(labelText: "Libellé", prefixIcon: Icon(Icons.label_outline)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: prixCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Prix", prefixIcon: Icon(Icons.euro), suffixText: "€"),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Stock>>(
                  future: stocksFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    final stocks = snapshot.data ?? [];
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: "Stock", prefixIcon: Icon(Icons.inventory_2_outlined)),
                      value: selectedStockId,
                      items: stocks.map((s) => DropdownMenuItem(
                        value: s.idStock,
                        child: Text(s.libelleStock),
                      )).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedStockId = value);
                      },
                    );
                  },
                ),
                if (!isEdit || (isEdit && selectedStockId != originalStockId)) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: qteInitialeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isEdit ? "Qté à transférer" : "Qté initiale",
                      helperText: isEdit ? "Ajouter au nouveau stock" : null,
                    ),
                  ),
                ],
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
                 // Validation & processing logic (same as before but simplified params)
                 final code = codeCtrl.text.trim();
                 final libelle = libelleCtrl.text.trim();
                 final prix = double.tryParse(prixCtrl.text) ?? 0.0;
                 final qteInitiale = int.tryParse(qteInitialeCtrl.text) ?? 0;

                 if (code.isEmpty || libelle.isEmpty) {
                   _showSnackBar("Champs obligatoires", isError: true);
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
                   
                   if (!isEdit && selectedStockId != null) {
                     await service.assignProduitToStock(saved.idProduit!, selectedStockId!, qteInitiale);
                   } else if (isEdit && selectedStockId != originalStockId && selectedStockId != null) {
                     await service.assignProduitToStock(saved.idProduit!, selectedStockId!, qteInitiale);
                   }

                   _showSnackBar(isEdit ? "Produit modifié" : "Produit ajouté");
                   _refreshProduits();
                   if (mounted) Navigator.pop(context);
                 } catch (e) {
                   _showSnackBar("Erreur: $e", isError: true);
                 }
              },
              child: const Text("Valider"),
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Mouvement", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: "ENTREE", child: Text("Entrée (+)")),
                  DropdownMenuItem(value: "SORTIE", child: Text("Sortie (-)")),
                ],
                onChanged: (v) => type = v!,
                decoration: const InputDecoration(labelText: "Type"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantité"),
                validator: (v) => (v!.isEmpty || int.parse(v) <= 0) ? "Invalide" : null,
                onSaved: (v) => quantite = int.parse(v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
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
                _showSnackBar("Stock mis à jour");
                _refreshProduits();
                Navigator.pop(context);
              } catch (e) {
                _showSnackBar("Erreur: $e", isError: true);
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Produits", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text("Nouveau Produit", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showProduitDialog(),
      ),
      body: FutureBuilder<List<Produit>>(
        future: produits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text("Aucun produit", style: GoogleFonts.outfit(fontSize: 18, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final p = list[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_bag, color: AppColors.secondary),
                  ),
                  title: Text(p.libelleProduit, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Code: ${p.codeProduit}", style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text("${p.prix} €", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          if (p.libelleStock != null)
                            Text("Stock: ${p.libelleStock} (${p.stockQte})", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: "edit", child: Text("Modifier")),
                      const PopupMenuItem(value: "move", child: Text("Mouvement Stock")),
                      const PopupMenuItem(value: "delete", child: Text("Supprimer", style: TextStyle(color: AppColors.error))),
                    ],
                    onSelected: (v) async {
                      if (v == "edit") _showProduitDialog(produit: p);
                      if (v == "move") {
                        if (p.idStock == null) {
                           _showSnackBar("Aucun stock assigné", isError: true);
                        } else {
                           _showMouvementDialog(produit: p);
                        }
                      }
                      if (v == "delete") {
                         // Delete logic
                         await service.deleteProduit(p.idProduit!);
                         _refreshProduits();
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