class Reglement {
  final int? idReglement;
  final double montantPaye;
  final double montantRestant;
  final bool? payee;
  final String? dateReglement; // on garde en String pour éviter les soucis de format "dd/MM/yyyy"
  final int? factureId; // on envoie seulement l'id côté front

  Reglement({
    this.idReglement,
    required this.montantPaye,
    required this.montantRestant,
    this.payee,
    this.dateReglement,
    this.factureId,
  });

  factory Reglement.fromJson(Map<String, dynamic> json) {
    return Reglement(
      idReglement: json['idReglement'],
      montantPaye: (json['montantPaye'] as num?)?.toDouble() ?? 0.0,
      montantRestant: (json['montantRestant'] as num?)?.toDouble() ?? 0.0,
      payee: json['payee'],
      dateReglement: json['dateReglement'],
      // souvent facture est ignorée côté backend, donc on reste safe
      factureId: (json['facture'] != null) ? json['facture']['idFacture'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idReglement": idReglement,
      "montantPaye": montantPaye,
      "montantRestant": montantRestant,
      "payee": payee,
      "dateReglement": dateReglement,
      // si ton backend attend un objet Facture minimal
      if (factureId != null) "facture": {"idFacture": factureId},
    };
  }
}
