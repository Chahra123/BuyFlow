import 'package:flutter/material.dart';
import '../services/fournisseur_service.dart';
import '../models/fournisseur.dart';
import '../services/secteur_activite_service.dart';
import '../models/secteur_activite.dart';

class FournisseurPage extends StatefulWidget {
  const FournisseurPage({super.key});

  @override
  State<FournisseurPage> createState() => _FournisseurPageState();
}

class _FournisseurPageState extends State<FournisseurPage> {
  final FournisseurService service = FournisseurService();
  final SecteurActiviteService secteurService = SecteurActiviteService();
  late Future<List<Fournisseur>> fournisseurs;
  late Future<List<SecteurActivite>> secteursFuture;

  @override
  void initState() {
    super.initState();
    secteursFuture = secteurService.getSecteurs();
    _refreshFournisseurs();
  }

  void _refreshFournisseurs() {
    setState(() {
      fournisseurs = service.getFournisseurs();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF0074D9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showFournisseurDialog({Fournisseur? fournisseur}) {
    final isEdit = fournisseur != null;

    final codeCtrl = TextEditingController(text: fournisseur?.code ?? '');
    final libelleCtrl = TextEditingController(text: fournisseur?.libelle ?? '');
    final emailCtrl = TextEditingController(
        text: fournisseur?.detailFournisseur?.email ?? '');
    final adresseCtrl = TextEditingController(
        text: fournisseur?.detailFournisseur?.adresse ?? '');
    final matriculeCtrl = TextEditingController(
        text: fournisseur?.detailFournisseur?.matricule ?? '');

    String? selectedCategorie = fournisseur?.categorieFournisseur;

    showDialog(
      context: context,
      builder: (context) {
        // Pre-populate selectedSecteurIds if editing (will be matched against secteur names)
        final Set<int> selectedSecteurIds = <int>{};
        bool hasInitializedSecteurs = false; // Flag to ensure pre-selection only happens once

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              isEdit ? "Modifier le fournisseur" : "Nouveau fournisseur",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF00509E)),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  TextField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(
                      labelText: "Code fournisseur",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: libelleCtrl,
                    decoration: const InputDecoration(
                      labelText: "Libellé fournisseur",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategorie,
                    decoration: const InputDecoration(
                      labelText: "Catégorie",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "ORDINAIRE", child: Text("Ordinaire")),
                      DropdownMenuItem(
                          value: "CONVENTIONNE",
                          child: Text("Conventionné")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategorie = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Détails (optionnel)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00509E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: adresseCtrl,
                    decoration: const InputDecoration(
                      labelText: "Adresse",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: matriculeCtrl,
                    decoration: const InputDecoration(
                      labelText: "Matricule",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Secteurs d'activité",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00509E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<SecteurActivite>>(
                    future: secteursFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text("Erreur : ${snapshot.error}");
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                            "Aucun secteur d'activité disponible");
                      }
                      
                      // Pre-select secteurs if editing (only once)
                      if (!hasInitializedSecteurs && isEdit && fournisseur.secteurActivites != null) {
                        for (var secteur in snapshot.data!) {
                          if (fournisseur.secteurActivites!
                              .contains(secteur.libelleSecteurActivite)) {
                            selectedSecteurIds.add(secteur.idSecteurActivite!);
                          }
                        }
                        hasInitializedSecteurs = true;
                      }
                      
                      return Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final secteur = snapshot.data![index];
                            return CheckboxListTile(
                              title: Text(secteur.libelleSecteurActivite),
                              subtitle:
                                  Text("Code: ${secteur.codeSecteurActivite}"),
                              value: selectedSecteurIds
                                  .contains(secteur.idSecteurActivite),
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked == true) {
                                    selectedSecteurIds
                                        .add(secteur.idSecteurActivite!);
                                  } else {
                                    selectedSecteurIds
                                        .remove(secteur.idSecteurActivite);
                                  }
                                });
                              },
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0074D9),
                ),
                onPressed: () async {
                  final code = codeCtrl.text.trim();
                  final libelle = libelleCtrl.text.trim();

                  if (code.isEmpty || libelle.isEmpty) {
                    _showSnackBar("Code et libellé sont obligatoires",
                        isError: true);
                    return;
                  }

                  // Always create DetailFournisseur object (backend requires it for update)
                  final detailFournisseur = DetailFournisseur(
                    idDetailFournisseur:
                        fournisseur?.detailFournisseur?.idDetailFournisseur,
                    email: emailCtrl.text.trim().isEmpty
                        ? null
                        : emailCtrl.text.trim(),
                    adresse: adresseCtrl.text.trim().isEmpty
                        ? null
                        : adresseCtrl.text.trim(),
                    matricule: matriculeCtrl.text.trim().isEmpty
                        ? null
                        : matriculeCtrl.text.trim(),
                    dateDebutCollaboration:
                        fournisseur?.detailFournisseur?.dateDebutCollaboration,
                  );

                  final newFournisseur = Fournisseur(
                    idFournisseur: fournisseur?.idFournisseur,
                    code: code,
                    libelle: libelle,
                    categorieFournisseur: selectedCategorie,
                    detailFournisseur: detailFournisseur,
                  );

                  try {
                    Fournisseur result;
                    if (isEdit) {
                      result = await service.updateFournisseur(newFournisseur);
                      _showSnackBar("Fournisseur modifié avec succès !");
                    } else {
                      result = await service.addFournisseur(newFournisseur);
                      _showSnackBar("Fournisseur ajouté avec succès !");
                    }

                    // Assign selected secteurs d'activité
                    if (selectedSecteurIds.isNotEmpty &&
                        result.idFournisseur != null) {
                      for (int secteurId in selectedSecteurIds) {
                        try {
                          await service.assignSecteurActiviteToFournisseur(
                              secteurId, result.idFournisseur!);
                        } catch (e) {
                          // Continue assigning others even if one fails
                        }
                      }
                      if (selectedSecteurIds.isNotEmpty) {
                        _showSnackBar(
                            "${selectedSecteurIds.length} secteur(s) d'activité assigné(s) avec succès !");
                      }
                    }

                    Navigator.pop(context);
                    _refreshFournisseurs();
                  } catch (e) {
                    _showSnackBar("Erreur lors de l'opération",
                        isError: true);
                  }
                },
                child: Text(
                  isEdit ? "Modifier" : "Ajouter",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAssignSecteurDialog(Fournisseur fournisseur) {
    int? selectedSecteurId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Assigner secteur d'activité\n${fournisseur.libelle}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF00509E)),
        ),
        content: FutureBuilder<List<SecteurActivite>>(
          future: secteursFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Aucun secteur d'activité disponible");
            }
            return DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: "Secteur d'activité",
                border: OutlineInputBorder(),
              ),
              items: snapshot.data!
                  .map((s) => DropdownMenuItem(
                        value: s.idSecteurActivite,
                        child: Text(s.libelleSecteurActivite),
                      ))
                  .toList(),
              onChanged: (value) => selectedSecteurId = value,
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0074D9),
            ),
            onPressed: () async {
              if (selectedSecteurId == null) {
                _showSnackBar("Veuillez sélectionner un secteur d'activité",
                    isError: true);
                return;
              }

              try {
                await service.assignSecteurActiviteToFournisseur(
                    selectedSecteurId!, fournisseur.idFournisseur!);
                Navigator.pop(context);
                _showSnackBar("Secteur d'activité assigné avec succès !");
                _refreshFournisseurs();
              } catch (e) {
                _showSnackBar("Erreur lors de l'assignation", isError: true);
              }
            },
            child: const Text(
              "Assigner",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fournisseurs")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0074D9),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFournisseurDialog(),
      ),
      body: FutureBuilder<List<Fournisseur>>(
        future: fournisseurs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0074D9)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Aucun fournisseur",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            );
          }

          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final f = list[i];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.local_shipping,
                    size: 36,
                    color: Color(0xFF0074D9),
                  ),
                  title: Text(
                    f.libelle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Code : ${f.code}"),
                      if (f.categorieFournisseur != null)
                        Text(
                          "Catégorie : ${f.categorieFournisseur == 'ORDINAIRE' ? 'Ordinaire' : 'Conventionné'}",
                        ),
                      if (f.detailFournisseur?.email != null)
                        Text("Email : ${f.detailFournisseur!.email}"),
                      if (f.detailFournisseur?.adresse != null)
                        Text("Adresse : ${f.detailFournisseur!.adresse}"),
                      Text(
                        f.secteurActivites != null && f.secteurActivites!.isNotEmpty
                            ? "Secteurs : ${f.secteurActivites!.join(', ')}"
                            : "Secteurs : Non assigné",
                        style: TextStyle(
                          color: f.secteurActivites != null && f.secteurActivites!.isNotEmpty
                              ? const Color(0xFF0074D9)
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "edit", child: Text("Modifier")),
                      PopupMenuItem(
                        value: "delete",
                        child: Text(
                          "Supprimer",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == "edit") {
                        _showFournisseurDialog(fournisseur: f);
                      } else if (value == "delete" &&
                          f.idFournisseur != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Supprimer ?"),
                            content: Text(
                              "Voulez-vous vraiment supprimer « ${f.libelle} » ?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text("Non"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text(
                                  "Oui",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await service.deleteFournisseur(f.idFournisseur!);
                            _showSnackBar("Fournisseur supprimé avec succès !");
                            _refreshFournisseurs();
                          } catch (e) {
                            _showSnackBar("Échec de la suppression",
                                isError: true);
                          }
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

