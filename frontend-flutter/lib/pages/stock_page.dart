import 'package:buy_flow/pages/stock_detail_page.dart';
import 'package:flutter/material.dart';
import '../services/stocks_service.dart';
import '../models/stock.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  final StockService service = StockService();
  late Future<List<Stock>> stocks;

  @override
  void initState() {
    super.initState();
    _refreshStocks();
  }

  void _refreshStocks() {
    setState(() {
      stocks = service.getStocks();
    });
  }

  // Dialogue Ajouter / Modifier
  void _showStockDialog({Stock? stock}) {
    final isEdit = stock != null;
    final libelleCtrl = TextEditingController(text: stock?.libelleStock ?? '');
    final qteCtrl = TextEditingController(text: stock?.qte.toString() ?? '');
    final qteMinCtrl = TextEditingController(text: stock?.qteMin.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? "Modifier le stock" : "Nouveau stock",
            textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: libelleCtrl,
                decoration: const InputDecoration(
                  labelText: "Libellé du stock",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantité",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qteMinCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantité minimum",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              final libelle = libelleCtrl.text.trim();
              final qte = int.tryParse(qteCtrl.text) ?? 0;
              final qteMin = int.tryParse(qteMinCtrl.text) ?? 0;

              if (libelle.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Le libellé est requis")));
                return;
              }

              final newStock = Stock(
                idStock: stock?.idStock,
                libelleStock: libelle,
                qte: qte,
                qteMin: qteMin,
              );

              try {
                if (isEdit) {
                  await service.updateStock(newStock);
                } else {
                  await service.addStock(newStock);
                }
                Navigator.pop(ctx);
                _refreshStocks();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur : $e")));
              }
            },
            child: Text(isEdit ? "Modifier" : "Ajouter",
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Liste des stocks")),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _showStockDialog(),
        ),
        body: FutureBuilder<List<Stock>>(
          future: stocks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.blue));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Erreur : ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Aucun stock", style: TextStyle(color: Colors.grey, fontSize: 18)));
            }

            final list = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final s = list[i];
                final isLow = s.qte < s.qteMin;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.inventory,
                        size: 36, color: isLow ? Colors.red : Colors.blue),
                    title: Text(s.libelleStock,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isLow ? Colors.red : Colors.black)),
                    subtitle: Text("Qté : ${s.qte}  •  Min : ${s.qteMin}"),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: "edit", child: Text("Modifier")),
                        const PopupMenuItem(value: "delete", child: Text("Supprimer", style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (val) async {
                        if (val == "edit") {
                          _showStockDialog(stock: s);
                        } else if (val == "delete" && s.idStock != null) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Confirmer"),
                              content: Text("Supprimer ${s.libelleStock} ?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Non")),
                                TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Oui", style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await service.deleteStock(s.idStock!);
                              _refreshStocks();
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text("Erreur suppression")));
                            }
                          }
                        }
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StockDetailPage(stock: s)),
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