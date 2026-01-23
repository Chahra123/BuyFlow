import 'secteur_activite.dart';

class DetailFournisseur {
  final int? idDetailFournisseur;
  final String dateDebutCollaboration; // Sending as String (YYYY-MM-DD)
  final String adresse;
  final String matricule;
  final String email;

  DetailFournisseur({
    this.idDetailFournisseur,
    required this.dateDebutCollaboration,
    required this.adresse,
    required this.matricule,
    required this.email,
  });

  factory DetailFournisseur.fromJson(Map<String, dynamic> json) {
    return DetailFournisseur(
      idDetailFournisseur: json['idDetailFournisseur'],
      dateDebutCollaboration: json['dateDebutCollaboration'] ?? '',
      adresse: json['adresse'] ?? '',
      matricule: json['matricule'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idDetailFournisseur != null) "idDetailFournisseur": idDetailFournisseur,
      "dateDebutCollaboration": dateDebutCollaboration,
      "adresse": adresse,
      "matricule": matricule,
      "email": email,
    };
  }
}

enum CategorieFournisseur { ORDINAIRE, CONVENTIONNE }

class Fournisseur {
  final int? idFournisseur;
  final String code;
  final String libelle;
  final CategorieFournisseur categorieFournisseur;
  final DetailFournisseur detailFournisseur;
  final List<SecteurActivite> secteurActivites;

  Fournisseur({
    this.idFournisseur,
    required this.code,
    required this.libelle,
    required this.categorieFournisseur,
    required this.detailFournisseur,
    this.secteurActivites = const [],
  });

  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      idFournisseur: json['idFournisseur'],
      code: json['code'] ?? '',
      libelle: json['libelle'] ?? '',
      categorieFournisseur: CategorieFournisseur.values.firstWhere(
        (e) => e.toString().split('.').last == (json['categorieFournisseur'] ?? 'ORDINAIRE'),
        orElse: () => CategorieFournisseur.ORDINAIRE,
      ),
      detailFournisseur: DetailFournisseur.fromJson(json['detailFournisseur'] ?? {}),
      secteurActivites: (json['secteurActivites'] as List<dynamic>?)
              ?.map((e) => SecteurActivite.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idFournisseur": idFournisseur,
      "code": code,
      "libelle": libelle,
      "categorieFournisseur": categorieFournisseur.toString().split('.').last,
      "detailFournisseur": detailFournisseur.toJson(),
      "secteurActivites": secteurActivites.map((s) => s.toJson()).toList(),
    };
  }
}
