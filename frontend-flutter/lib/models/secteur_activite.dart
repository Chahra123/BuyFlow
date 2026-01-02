class SecteurActivite {
  final int? idSecteurActivite;
  final String codeSecteurActivite;
  final String libelleSecteurActivite;

  SecteurActivite({
    this.idSecteurActivite,
    required this.codeSecteurActivite,
    required this.libelleSecteurActivite,
  });

  factory SecteurActivite.fromJson(Map<String, dynamic> json) {
    return SecteurActivite(
      idSecteurActivite: json['idSecteurActivite'],
      codeSecteurActivite: json['codeSecteurActivite'] ?? '',
      libelleSecteurActivite: json['libelleSecteurActivite'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idSecteurActivite": idSecteurActivite,
      "codeSecteurActivite": codeSecteurActivite,
      "libelleSecteurActivite": libelleSecteurActivite,
    };
  }
}



