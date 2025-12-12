class Stock {
  final int? idStock;
  final String libelleStock;
  final int qte;
  final int qteMin;

  Stock({
    this.idStock,
    required this.libelleStock,
    required this.qte,
    required this.qteMin,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      idStock: json['idStock'],
      libelleStock: json['libelleStock'],
      qte: json['qte'],
      qteMin: json['qteMin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idStock": idStock,
      "libelleStock": libelleStock,
      "qte": qte,
      "qteMin": qteMin,
    };
  }
}