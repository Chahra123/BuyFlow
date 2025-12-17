class MouvementStock {
  final int? id;
  final int quantite;
  final String type;
  final String? raison;
  final String? utilisateur;

  MouvementStock({
    this.id,
    required this.quantite,
    required this.type,
    this.raison,
    this.utilisateur,
  });

  factory MouvementStock.fromJson(Map<String, dynamic> json) {
    return MouvementStock(
      id: json['id'],
      quantite: json['quantite'],
      type: json['type'],
      raison: json['raison'],
      utilisateur: json['utilisateur'],
    );
  }
}