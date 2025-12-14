class MouvementStock {
  final int? id;
  final int quantite;
  final String type;

  MouvementStock({this.id, required this.quantite, required this.type});

  factory MouvementStock.fromJson(Map<String, dynamic> json) {
    return MouvementStock(
      id: json['id'],
      quantite: json['quantite'],
      type: json['type'],
    );
  }
}