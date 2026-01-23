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
  String _currentFilter = 'TOUS'; // TOUS, ENTREE, SORTIE

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
      body: Column(
        children: [
          // FILTERS
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Tous", "TOUS", Icons.list),
                const SizedBox(width: 8),
                _buildFilterChip("Entrées", "ENTREE", Icons.download_rounded, color: AppColors.success),
                const SizedBox(width: 8),
                _buildFilterChip("Sorties", "SORTIE", Icons.upload_rounded, color: AppColors.error),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _movementsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erreur: ${snapshot.error}"));
                }
                var movements = snapshot.data ?? [];
                
                // FILTERING LOGIC
                if (_currentFilter != 'TOUS') {
                  movements = movements.where((m) => 
                    m['type']?.toString().toUpperCase() == _currentFilter
                  ).toList();
                }

                if (movements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Icon(Icons.filter_list_off_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                         const SizedBox(height: 16),
                         Text("Aucun mouvement trouvé", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 18)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: movements.length,
                  itemBuilder: (context, index) {
                    final m = movements[index];
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, {Color? color}) {
    final isSelected = _currentFilter == value;
    final baseColor = color ?? AppColors.primary;
    
    return InkWell(
      onTap: () => setState(() => _currentFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? baseColor : AppColors.border,
          ),
          boxShadow: isSelected ? [
             BoxShadow(color: baseColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
