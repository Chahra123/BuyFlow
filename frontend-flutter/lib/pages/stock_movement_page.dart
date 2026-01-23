import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/stocks_service.dart';
import '../core/theme/app_colors.dart';

class StockMovementPage extends StatefulWidget {
  const StockMovementPage({super.key});

  @override
  State<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends State<StockMovementPage> {
  final StockService _service = StockService();
  late Future<List<dynamic>> _movementsFuture;

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  void _loadMovements() {
    setState(() {
      _movementsFuture = _service.getMouvements();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Historique Mouvements", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _movementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          final movements = snapshot.data ?? [];
          if (movements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history_toggle_off_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                   const SizedBox(height: 16),
                   Text("Aucun mouvement enregistré", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movements.length,
            itemBuilder: (context, index) {
              final m = movements[index];
              // Safety check: if 'type' is missing, assume ENTREE or handle error
              final typeStr = m['type']?.toString().toUpperCase() ?? 'INCONNU';
              final isEntree = typeStr == "ENTREE";
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isEntree ? AppColors.success : AppColors.error).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEntree ? Icons.add_rounded : Icons.remove_rounded,
                        color: isEntree ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['produit'] != null ? m['produit']['libelleProduit'] : "Produit inconnu", 
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(m['raison'] ?? "Pas de raison", 
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(_formatDate(m['dateMouvement']), 
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${isEntree ? '+' : '-'}${m['quantite']}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, 
                            fontSize: 18,
                            color: isEntree ? AppColors.success : AppColors.error
                          ),
                        ),
                        Text(m['utilisateur'] ?? "admin", 
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
