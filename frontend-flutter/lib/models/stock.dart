class Stock {
  final int? idStock;
  final String libelleStock;
  final int qteMin;

  Stock({
    this.idStock,
    required this.libelleStock,
    required this.qteMin,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      idStock: json['idStock'],
      libelleStock: json['libelleStock'],
      qteMin: json['qteMin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idStock": idStock,
      "libelleStock": libelleStock,
      "qteMin": qteMin,
    };
  }
}