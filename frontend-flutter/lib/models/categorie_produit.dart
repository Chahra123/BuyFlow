class CategorieProduit {
  final int? idCategorieProduit;
  final String codeCategorie;
  final String libelleCategorie;

  CategorieProduit({
    this.idCategorieProduit,
    required this.codeCategorie,
    required this.libelleCategorie,
  });

  factory CategorieProduit.fromJson(Map<String, dynamic> json) {
    return CategorieProduit(
      idCategorieProduit: json['idCategorieProduit'],
      codeCategorie: json['codeCategorie'] ?? '',
      libelleCategorie: json['libelleCategorie'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idCategorieProduit": idCategorieProduit,
      "codeCategorie": codeCategorie,
      "libelleCategorie": libelleCategorie,
    };
  }
}
