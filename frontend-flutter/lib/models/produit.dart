class Produit {
  final int? idProduit;
  final String codeProduit;
  final String libelleProduit;
  final double prix;
  final String? dateCreation;
  final String? dateDerniereModification;
  final int? idStock;
  final String? libelleStock;

  Produit({
    this.idProduit,
    required this.codeProduit,
    required this.libelleProduit,
    required this.prix,
    this.dateCreation,
    this.dateDerniereModification,
    this.idStock,
    this.libelleStock,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      idProduit: json['idProduit'],
      codeProduit: json['codeProduit'] ?? '',
      libelleProduit: json['libelleProduit'] ?? '',
      prix: (json['prix'] is int)
          ? (json['prix'] as int).toDouble()
          : (json['prix'] as num).toDouble(),
      dateCreation: json['dateCreation']?.toString(),
      dateDerniereModification: json['dateDerniereModification']?.toString(),
      idStock: json['idStock'],
      libelleStock: json['libelleStock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idProduit": idProduit,
      "codeProduit": codeProduit,
      "libelleProduit": libelleProduit,
      "prix": prix,
      "dateCreation": dateCreation,
      "dateDerniereModification": dateDerniereModification,
      "idStock": idStock,
    };
  }
}