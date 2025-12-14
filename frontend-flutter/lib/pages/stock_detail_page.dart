import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/produit.dart';
import '../services/produits_service.dart';

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
    produitsDansStock = produitService.getProduitsByStock(widget.stock.idStock!);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = widget.stock.qte <= widget.stock.qteMin;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du stock"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(20),
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icône + statut
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: isLowStock ? Colors.red : Colors.blue,
                            child: Icon(
                              isLowStock ? Icons.warning : Icons.inventory,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Libellé
                          Text(
                            widget.stock.libelleStock,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

                          // Infos en cartes
                          _buildInfoRow("ID Stock", "${widget.stock.idStock ?? '-'}", Icons.tag),
                          const SizedBox(height: 16),
                          _buildInfoRow("Quantité actuelle", "${widget.stock.qte}", Icons.inventory_2),
                          const SizedBox(height: 16),
                          _buildInfoRow("Quantité minimum", "${widget.stock.qteMin}", Icons.warning_amber),
                          const SizedBox(height: 24),

                          // Alerte stock faible
                          if (isLowStock)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning, color: Colors.red),
                                  SizedBox(width: 10),
                                  Text(
                                    "Stock faible – Réapprovisionnement requis",
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Produits liés", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),

                  FutureBuilder<List<Produit>>(
                    future: produitsDansStock,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Erreur: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("Aucun produit lié"));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}