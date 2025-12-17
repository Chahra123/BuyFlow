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
    produitsDansStock =
        produitService.getProduitsByStock(widget.stock.idStock!);
  }

  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ====== CARD STOCK ======
                  Card(
                    margin: const EdgeInsets.all(20),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.inventory,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
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
                          _buildInfoRow(
                              "ID Stock",
                              widget.stock.idStock?.toString() ?? "-",
                              Icons.tag),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                              "Quantité minimum",
                              widget.stock.qteMin.toString(),
                              Icons.warning_amber),
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Produits liés",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ====== LISTE PRODUITS ======
                  FutureBuilder<List<Produit>>(
                    future: produitsDansStock,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text("Erreur : ${snapshot.error}"));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("Aucun produit lié"));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, i) {
                          final p = snapshot.data![i];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.shopping_bag),
                              title: Text(
                                p.libelleProduit,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Code : ${p.codeProduit}"),
                                  FutureBuilder<int>(
                                    future: produitService.getQuantiteProduit(p.idProduit!),
                                    builder: (context, qteSnapshot) {
                                      if (!qteSnapshot.hasData) {
                                        return const Text("Quantité : ...");
                                      }

                                      final qte = qteSnapshot.data!;
                                      final bool isLow =
                                          qte <= widget.stock.qteMin;

                                      return Text(
                                        "Quantité : $qte",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: qte == 0
                                              ? Colors.red
                                              : isLow
                                              ? Colors.orange
                                              : Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: "remove",
                                    child: Text(
                                      "Désassigner",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                                onSelected: (value) async {
                                  if (value == "remove") {
                                    try {
                                      await produitService
                                          .removeProduitFromStock(
                                          p.idProduit!);
                                      _refreshProduits();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Produit désassigné")));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                          content:
                                          Text("Erreur : $e")));
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
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  void _refreshProduits() {
    setState(() {
      produitsDansStock =
          produitService.getProduitsByStock(widget.stock.idStock!);
    });
  }
}