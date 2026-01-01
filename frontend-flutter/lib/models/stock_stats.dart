class StockStats {
  final int totalStocks;
  final int totalProducts;
  final int lowStockCount;
  final List<MovementSummary> recentMovements;

  StockStats({
    required this.totalStocks,
    required this.totalProducts,
    required this.lowStockCount,
    required this.recentMovements,
  });

  factory StockStats.fromJson(Map<String, dynamic> json) {
    return StockStats(
      totalStocks: json['totalStocks'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      lowStockCount: json['lowStockCount'] ?? 0,
      recentMovements: (json['recentMovements'] as List? ?? [])
          .map((m) => MovementSummary.fromJson(m))
          .toList(),
    );
  }
}

class MovementSummary {
  final int id;
  final String produitLibelle;
  final int quantite;
  final String type;
  final String date;
  final String raison;

  MovementSummary({
    required this.id,
    required this.produitLibelle,
    required this.quantite,
    required this.type,
    required this.date,
    required this.raison,
  });

  factory MovementSummary.fromJson(Map<String, dynamic> json) {
    return MovementSummary(
      id: json['id'] ?? 0,
      produitLibelle: json['produitLibelle'] ?? '',
      quantite: json['quantite'] ?? 0,
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      raison: json['raison'] ?? '',
    );
  }
}
