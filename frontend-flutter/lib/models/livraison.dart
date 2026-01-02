import 'commande.dart';
import 'operateur.dart';

class Livraison {
  final int idLivraison;
  final Commande commande;
  final String status;
  final String qrToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Operateur? lastUpdatedBy;

  Livraison({
    required this.idLivraison,
    required this.commande,
    required this.status,
    required this.qrToken,
    this.createdAt,
    this.updatedAt,
    this.lastUpdatedBy,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      idLivraison: (json['idLivraison'] ?? 0) as int,
      commande: Commande.fromJson((json['commande'] ?? {}) as Map<String, dynamic>),
      status: (json['status'] ?? '') as String,
      qrToken: (json['qrToken'] ?? '') as String,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      lastUpdatedBy: json['lastUpdatedBy'] != null
          ? Operateur.fromJson((json['lastUpdatedBy']) as Map<String, dynamic>)
          : null,
    );
  }
}
