import 'package:flutter/material.dart';
import '../models/fournisseur.dart';
import '../services/fournisseur_service.dart';
import 'fournisseur_dialog.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class FournisseurPage extends StatefulWidget {
  const FournisseurPage({super.key});

  @override
  State<FournisseurPage> createState() => _FournisseurPageState();
}

class _FournisseurPageState extends State<FournisseurPage> {
  final FournisseurService _service = FournisseurService();
  late Future<List<Fournisseur>> _fournisseurs;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _fournisseurs = _service.getFournisseurs();
    });
  }

  void _openDialog({Fournisseur? fournisseur}) async {
    await showDialog(
      context: context,
      builder: (context) => FournisseurDialog(
        fournisseur: fournisseur,
        onSave: _refresh,
      ),
    );
  }

  void _delete(Fournisseur f) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer suppression"),
        content: Text("Supprimer ${f.libelle} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Non")),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Oui", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && f.idFournisseur != null) {
      try {
        await _service.deleteFournisseur(f.idFournisseur!);
        _refresh();
        AppSnackBar.showSuccess(context, "Supprimé avec succès");
      } catch (e) {
        AppSnackBar.showError(context, "Erreur: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Fournisseurs",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Fournisseur>>(
        future: _fournisseurs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}", style: const TextStyle(color: AppColors.error)));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucun fournisseur", style: TextStyle(color: AppColors.textSecondary)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final f = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(f.code.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.primary)),
                  ),
                  title: Text(f.libelle, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text("${f.categorieFournisseur.toString().split('.').last} - ${f.detailFournisseur.adresse}", style: const TextStyle(color: AppColors.textSecondary)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDetailRow("Email", f.detailFournisseur.email),
                          _buildDetailRow("Matricule", f.detailFournisseur.matricule),
                          _buildDetailRow("Depuis le", f.detailFournisseur.dateDebutCollaboration),
                          const Divider(),
                          const Text("Secteurs d'activité:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          f.secteurActivites.isEmpty 
                              ? const Text("Aucun secteur", style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary))
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: f.secteurActivites.map((s) => Chip(
                                    label: Text(s.libelleSecteurActivite, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                                    backgroundColor: AppColors.primaryLight,
                                    side: BorderSide.none,
                                  )).toList(),
                                ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                label: const Text("Modifier", style: TextStyle(color: Colors.orange)),
                                onPressed: () => _openDialog(fournisseur: f),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                                onPressed: () => _delete(f),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
