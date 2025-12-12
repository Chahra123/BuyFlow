import 'package:flutter/material.dart';
import '../models/stock.dart';

class StockDetailPage extends StatelessWidget {
  final Stock stock;

  const StockDetailPage({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = stock.qte <= stock.qteMin;

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
            child: Card(
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
                      stock.libelleStock,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Infos en cartes
                    _buildInfoRow("ID Stock", "${stock.idStock ?? '-'}", Icons.tag),
                    const SizedBox(height: 16),
                    _buildInfoRow("Quantité actuelle", "${stock.qte}", Icons.inventory_2),
                    const SizedBox(height: 16),
                    _buildInfoRow("Quantité minimum", "${stock.qteMin}", Icons.warning_amber),
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