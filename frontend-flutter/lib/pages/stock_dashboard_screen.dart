import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/stocks_service.dart';
import '../models/stock_stats.dart';
import '../core/theme/app_colors.dart';

class StockDashboardScreen extends StatefulWidget {
  const StockDashboardScreen({super.key});

  @override
  State<StockDashboardScreen> createState() => _StockDashboardScreenState();
}

class _StockDashboardScreenState extends State<StockDashboardScreen> {
  final StockService _service = StockService();
  late Future<StockStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _service.getStockStats().then((data) => StockStats.fromJson(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Dashboard Stock", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Actualiser",
          ),
        ],
      ),
      body: FutureBuilder<StockStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text("Erreur: ${snapshot.error}", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                  TextButton(onPressed: _loadStats, child: const Text("Réessayer"))
                ],
              ),
            );
          }
          if (!snapshot.hasData) return const Center(child: Text("Pas de données disponibles"));

          final stats = snapshot.data!;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryGrid(stats),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Analyse de Santé", 
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.insights_rounded, color: AppColors.primary, size: 20),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                _buildHealthAnalysis(stats),
                const SizedBox(height: 32),
                Text("Dernières Activités", 
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _buildRecentMovements(stats.recentMovements),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryGrid(StockStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          "Total Stocks", 
          stats.totalStocks.toString(), 
          Icons.inventory_2_rounded, 
          AppColors.primary,
          "Entrepôts gérés"
        ),
        _buildStatCard(
          "Produits", 
          stats.totalProducts.toString(), 
          Icons.shopping_bag_rounded, 
          AppColors.secondary,
          "Articles catalogue"
        ),
        _buildStatCard(
          "Alertes Bas", 
          stats.lowStockCount.toString(), 
          Icons.warning_amber_rounded, 
          AppColors.error,
          "À réapprovisionner",
          isUrgent: stats.lowStockCount > 0
        ),
        _buildStatCard(
          "Taux de Santé", 
          "${stats.totalStocks > 0 ? ((1 - stats.lowStockCount / stats.totalStocks) * 100).toInt() : 100}%", 
          Icons.health_and_safety_rounded, 
          AppColors.success,
          "Disponibilité globale"
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle, {bool isUrgent = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (isUrgent) 
                const Badge(backgroundColor: AppColors.error),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAnalysis(StockStats stats) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 6,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: stats.totalStocks.toDouble() - stats.lowStockCount,
                    title: '',
                    radius: 20,
                    color: AppColors.success,
                  ),
                  PieChartSectionData(
                    value: stats.lowStockCount.toDouble(),
                    title: '',
                    radius: 25,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem("Optimal", AppColors.success, stats.totalStocks - stats.lowStockCount),
                const SizedBox(height: 12),
                _buildLegendItem("Alerte", AppColors.error, stats.lowStockCount),
                const Divider(height: 32),
                Text("États des stocks", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
            Text("$count stocks", style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
          ],
        )
      ],
    );
  }

  Widget _buildRecentMovements(List<MovementSummary> movements) {
    if (movements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text("Aucun mouvement récent", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: movements.asMap().entries.map((entry) {
        final m = entry.value;
        final isLast = entry.key == movements.length - 1;
        final isEntree = m.type == "ENTREE";
        
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (isEntree ? AppColors.success : AppColors.error).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEntree ? Icons.south_west_rounded : Icons.north_east_rounded,
                      color: isEntree ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.produitLibelle, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text("${m.raison} • ${m.date.split('T')[0]}", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        "${isEntree ? '+' : '-'}${m.quantite}",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          color: isEntree ? AppColors.success : AppColors.error
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
