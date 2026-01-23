import 'package:flutter/material.dart';
import '../services/secteur_activite_service.dart';
import '../models/secteur_activite.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class SecteurActivitePage extends StatefulWidget {
  const SecteurActivitePage({super.key});

  @override
  State<SecteurActivitePage> createState() => _SecteurActivitePageState();
}

class _SecteurActivitePageState extends State<SecteurActivitePage> {
  final SecteurActiviteService service = SecteurActiviteService();
  late Future<List<SecteurActivite>> secteurs;

  @override
  void initState() {
    super.initState();
    _refreshSecteurs();
  }

  void _refreshSecteurs() {
    setState(() {
      secteurs = service.getSecteurs();
    });
  }



  void _showSecteurDialog({SecteurActivite? secteur}) {
    final isEdit = secteur != null;

    final codeCtrl = TextEditingController(text: secteur?.codeSecteurActivite ?? '');
    final libelleCtrl = TextEditingController(text: secteur?.libelleSecteurActivite ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? "Modifier le secteur" : "Nouveau secteur",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: "Code secteur",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: libelleCtrl,
              decoration: const InputDecoration(
                labelText: "Libellé secteur",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final code = codeCtrl.text.trim();
              final libelle = libelleCtrl.text.trim();

              if (code.isEmpty || libelle.isEmpty) {
                AppSnackBar.showError(context, "Code et libellé sont obligatoires");
                return;
              }

              final newSecteur = SecteurActivite(
                idSecteurActivite: secteur?.idSecteurActivite,
                codeSecteurActivite: code,
                libelleSecteurActivite: libelle,
              );

              try {
                if (isEdit) {
                  await service.updateSecteur(newSecteur);
                  AppSnackBar.showSuccess(context, "Secteur modifié avec succès !");
                } else {
                  await service.addSecteur(newSecteur);
                  AppSnackBar.showSuccess(context, "Secteur ajouté avec succès !");
                }
                Navigator.pop(context);
                _refreshSecteurs();
              } catch (e) {
                AppSnackBar.showError(context, "Erreur lors de l'opération");
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Secteurs d'activité",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showSecteurDialog(),
      ),
      body: FutureBuilder<List<SecteurActivite>>(
        future: secteurs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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
                "Aucun secteur d'activité",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            );
          }

          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final s = list[i];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.business,
                    size: 36,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    s.libelleSecteurActivite,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text("Code : ${s.codeSecteurActivite}"),
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
                        _showSecteurDialog(secteur: s);
                      } else if (value == "delete" && s.idSecteurActivite != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text("Supprimer ?"),
                            content: Text(
                              "Voulez-vous vraiment supprimer « ${s.libelleSecteurActivite} » ?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text("Non"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, true),
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
                            await service.deleteSecteur(s.idSecteurActivite!);
                            AppSnackBar.showSuccess(context, "Secteur supprimé avec succès !");
                            _refreshSecteurs();
                          } catch (e) {
                            AppSnackBar.showError(context, "Échec de la suppression");
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
