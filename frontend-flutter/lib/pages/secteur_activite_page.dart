import 'package:flutter/material.dart';
import '../services/secteur_activite_service.dart';
import '../models/secteur_activite.dart';

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

  void _showSecteurDialog({SecteurActivite? secteur}) {
    final isEdit = secteur != null;

    final codeCtrl =
        TextEditingController(text: secteur?.codeSecteurActivite ?? '');
    final libelleCtrl =
        TextEditingController(text: secteur?.libelleSecteurActivite ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? "Modifier le secteur d'activité" : "Nouveau secteur d'activité",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF00509E)),
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
              backgroundColor: const Color(0xFF0074D9),
            ),
            onPressed: () async {
              final code = codeCtrl.text.trim();
              final libelle = libelleCtrl.text.trim();

              if (code.isEmpty || libelle.isEmpty) {
                _showSnackBar("Code et libellé sont obligatoires", isError: true);
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
                  _showSnackBar("Secteur d'activité modifié avec succès !");
                } else {
                  await service.addSecteur(newSecteur);
                  _showSnackBar("Secteur d'activité ajouté avec succès !");
                }
                Navigator.pop(context);
                _refreshSecteurs();
              } catch (e) {
                _showSnackBar("Erreur lors de l'opération", isError: true);
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
      appBar: AppBar(title: const Text("Secteurs d'activité")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0074D9),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showSecteurDialog(),
      ),
      body: FutureBuilder<List<SecteurActivite>>(
        future: secteurs,
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
                    color: Color(0xFF0074D9),
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
                      } else if (value == "delete" &&
                          s.idSecteurActivite != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Supprimer ?"),
                            content: Text(
                              "Voulez-vous vraiment supprimer « ${s.libelleSecteurActivite} » ?",
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
                            await service.deleteSecteur(s.idSecteurActivite!);
                            _showSnackBar("Secteur d'activité supprimé avec succès !");
                            _refreshSecteurs();
                          } catch (e) {
                            _showSnackBar("Échec de la suppression", isError: true);
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



