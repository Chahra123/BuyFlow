class DetailFournisseur {
  final int? idDetailFournisseur;
  final String? email;
  final String? dateDebutCollaboration;
  final String? adresse;
  final String? matricule;

  DetailFournisseur({
    this.idDetailFournisseur,
    this.email,
    this.dateDebutCollaboration,
    this.adresse,
    this.matricule,
  });

  factory DetailFournisseur.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DetailFournisseur();
    return DetailFournisseur(
      idDetailFournisseur: json['idDetailFournisseur'],
      email: json['email'],
      dateDebutCollaboration: json['dateDebutCollaboration'],
      adresse: json['adresse'],
      matricule: json['matricule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idDetailFournisseur": idDetailFournisseur,
      "email": email,
      "dateDebutCollaboration": dateDebutCollaboration,
      "adresse": adresse,
      "matricule": matricule,
    };
  }
}

class Fournisseur {
  final int? idFournisseur;
  final String code;
  final String libelle;
  final String? categorieFournisseur;
  final DetailFournisseur? detailFournisseur;
  final List<String>? secteurActivites; // List of secteur libellés

  Fournisseur({
    this.idFournisseur,
    required this.code,
    required this.libelle,
    this.categorieFournisseur,
    this.detailFournisseur,
    this.secteurActivites,
  });

  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    List<String>? secteurs;
    if (json['secteurActivites'] != null) {
      print('DEBUG: secteurActivites raw data: ${json['secteurActivites']}');
      try {
        secteurs = (json['secteurActivites'] as List)
            .map((s) {
              print('DEBUG: Processing secteur: $s');
              return s['libelleSecteurActivite']?.toString() ?? '';
            })
            .where((s) => s.isNotEmpty)
            .toList();
        print('DEBUG: Final secteurs list: $secteurs');
      } catch (e) {
        print('DEBUG: Error parsing secteurs: $e');
      }
    } else {
      print('DEBUG: secteurActivites is null in JSON');
    }

    return Fournisseur(
      idFournisseur: json['idFournisseur'],
      code: json['code'] ?? '',
      libelle: json['libelle'] ?? '',
      categorieFournisseur: json['categorieFournisseur'],
      detailFournisseur: DetailFournisseur.fromJson(json['detailFournisseur']),
      secteurActivites: secteurs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idFournisseur": idFournisseur,
      "code": code,
      "libelle": libelle,
      "categorieFournisseur": categorieFournisseur,
      "detailFournisseur": detailFournisseur?.toJson(),
      // Don't send secteurActivites in toJson (handled separately via assign API)
    };
  }
}

