import 'commande.dart';
import 'operateur.dart';

class Reclamation {
  final int idReclamation;
  final Operateur operateur;
  final Commande commande;
  final String objet;
  final String description;
  final String status;
  final DateTime? createdAt;

  Reclamation({
    required this.idReclamation,
    required this.operateur,
    required this.commande,
    required this.objet,
    required this.description,
    required this.status,
    this.createdAt,
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      idReclamation: (json['idReclamation'] ?? 0) as int,
      operateur: Operateur.fromJson((json['operateur'] ?? {}) as Map<String, dynamic>),
      commande: Commande.fromJson((json['commande'] ?? {}) as Map<String, dynamic>),
      objet: (json['objet'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
