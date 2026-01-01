import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/stocks_service.dart';
import '../models/stock.dart';
import '../pages/stock_detail_page.dart';
import '../pages/stock_dashboard_screen.dart';
import '../pages/stock_movement_page.dart';
import '../core/theme/app_colors.dart';

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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.outfit(fontSize: 16)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showStockDialog({Stock? stock}) {
    final isEdit = stock != null;
    final libelleCtrl = TextEditingController(text: stock?.libelleStock ?? '');
    final qteMinCtrl = TextEditingController(text: stock?.qteMin.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? "Modifier le stock" : "Nouveau stock",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: libelleCtrl,
              decoration: const InputDecoration(labelText: "Libellé du stock"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qteMinCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantité minimum"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final libelle = libelleCtrl.text.trim();
              final qteMin = int.tryParse(qteMinCtrl.text) ?? 0;

              if (libelle.isEmpty) {
                _showSnackBar("Le libellé est obligatoire", isError: true);
                return;
              }

              final newStock = Stock(
                idStock: stock?.idStock,
                libelleStock: libelle,
                qteMin: qteMin,
              );

              try {
                if (isEdit) {
                  await service.updateStock(newStock);
                } else {
                  await service.addStock(newStock);
                }
                _showSnackBar(isEdit ? "Stock modifié !" : "Stock ajouté !");
                _refreshStocks();
                if (mounted) Navigator.of(context).pop();
              } catch (e) {
                _showSnackBar("Erreur : $e", isError: true);
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
        title: Text("Gestion des stocks", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "movements",
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            label: Text("Historique", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockMovementPage())),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "dashboard",
            backgroundColor: AppColors.secondary,
            icon: const Icon(Icons.analytics_rounded, color: Colors.white),
            label: Text("Analytics", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockDashboardScreen())),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "newStock",
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text("Nouveau Stock", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => _showStockDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<Stock>>(
        future: stocks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}", style: const TextStyle(color: AppColors.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text("Aucun stock", style: GoogleFonts.outfit(fontSize: 18, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final s = list[i];
              return FutureBuilder<int>(
                future: service.getQteTotale(s.idStock!),
                builder: (context, qteSnapshot) {
                  final qte = qteSnapshot.data ?? 0;
                  final isLow = qte < s.qteMin;
                  
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
                          color: isLow ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          color: isLow ? AppColors.error : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        s.libelleStock,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            _Badge(label: "Total: $qte", color: isLow ? AppColors.error : AppColors.textSecondary),
                            const SizedBox(width: 8),
                            _Badge(label: "Min: ${s.qteMin}", color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: "edit", child: Text("Modifier")),
                          const PopupMenuItem(value: "delete", child: Text("Supprimer", style: TextStyle(color: AppColors.error))),
                        ],
                        onSelected: (value) async {
                          if (value == "edit") {
                            _showStockDialog(stock: s);
                          } else if (value == "delete") {
                             // Delete logic (simplified for brevity)
                             await service.deleteStock(s.idStock!);
                             _refreshStocks();
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
          );
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}