import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/produit.dart';
import '../services/produits_service.dart';
import '../services/stocks_service.dart';

class StockDetailPage extends StatefulWidget {
  final Stock stock;
  const StockDetailPage({super.key, required this.stock});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  final ProduitService produitService = ProduitService();
  late Future<List<Produit>> produitsDansStock;

  @override
  void initState() {
    super.initState();
    _refreshProduits();
  }

  void _refreshProduits() {
    produitsDansStock = produitService.getProduitsByStock(widget.stock.idStock!);
  }

  void _assignerProduit() async {
    final stocks = await StockService().getStocks();
    final produits = await produitService.getProduits();

    Produit? produitChoisi;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Affecter un produit à ce stock"),
        content: DropdownButtonFormField<Produit>(
          hint: const Text("Choisir un produit"),
          items: produits.map((p) => DropdownMenuItem(
            value: p,
            child: Text("${p.codeProduit} - ${p.libelleProduit}"),
          )).toList(),
          onChanged: (value) => produitChoisi = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: produitChoisi == null ? null : () async {
              await produitService.assignProduitToStock(
                produitChoisi!.idProduit!,
                widget.stock.idStock!,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Produit affecté avec succès")),
              );
              // Optionnel : rafraîchir listes globales si besoin
            },
            child: const Text("Affecter"),
          ),
        ],
      ),
    );
  }

  final bool isLowStock = false; // conservé pour compatibilité

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock : ${widget.stock.libelleStock}"),
        actions: [
          IconButton(icon: const Icon(Icons.link), onPressed: _assignerProduit),
        ],
      ),
      body: Column(
        children: [
          // Détails stock (ton code existant)
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(widget.stock.libelleStock, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text("Qté : ${widget.stock.qte} | Min : ${widget.stock.qteMin}"),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Produits dans ce stock", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          Expanded(
            child: FutureBuilder<List<Produit>>(
              future: produitsDansStock,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun produit affecté"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final p = snapshot.data![i];
                    return ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text(p.libelleProduit),
                      subtitle: Text("Code: ${p.codeProduit} | Prix: ${p.prix}"),
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