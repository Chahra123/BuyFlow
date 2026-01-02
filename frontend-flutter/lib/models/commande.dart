import 'produit.dart';
import 'operateur.dart';

class Commande {
  final int idCommande;
  final Operateur operateur;
  final Produit produit;
  final int quantite;
  final String? adresseLivraison;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime? createdAt;

  Commande({
    required this.idCommande,
    required this.operateur,
    required this.produit,
    required this.quantite,
    required this.status,
    this.adresseLivraison,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      idCommande: (json['idCommande'] ?? 0) as int,
      operateur: Operateur.fromJson((json['operateur'] ?? {}) as Map<String, dynamic>),
      produit: Produit.fromJson((json['produit'] ?? {}) as Map<String, dynamic>),
      quantite: (json['quantite'] ?? 0) as int,
      adresseLivraison: json['adresseLivraison'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: (json['status'] ?? '') as String,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
