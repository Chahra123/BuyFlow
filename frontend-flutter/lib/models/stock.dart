class Stock {
  final int? idStock;
  final String libelleStock;
  final int qteMin;
  final int? qteTotale; // New from Backend Optimization
  final String? status; // New from Backend Optimization

  Stock({
    this.idStock,
    required this.libelleStock,
    required this.qteMin,
    this.qteTotale,
    this.status,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      idStock: json['idStock'],
      libelleStock: json['libelleStock'],
      qteMin: json['qteMin'],
      qteTotale: json['qteTotale'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idStock": idStock,
      "libelleStock": libelleStock,
      "qteMin": qteMin,
      // qteTotale & status are read-only from backend
    };
  }
}