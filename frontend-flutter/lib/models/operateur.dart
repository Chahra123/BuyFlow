class Operateur {
  final int idOperateur;
  final String nom;
  final String prenom;

  Operateur({
    required this.idOperateur,
    required this.nom,
    required this.prenom,
  });

  factory Operateur.fromJson(Map<String, dynamic> json) {
    return Operateur(
      idOperateur: (json['idOperateur'] ?? 0) as int,
      nom: (json['nom'] ?? '') as String,
      prenom: (json['prenom'] ?? '') as String,
    );
  }
}
