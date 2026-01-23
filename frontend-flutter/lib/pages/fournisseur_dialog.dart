import 'package:flutter/material.dart';
import '../models/fournisseur.dart';
import '../models/secteur_activite.dart';
import '../services/fournisseur_service.dart';
import '../services/secteur_activite_service.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class FournisseurDialog extends StatefulWidget {
  final Fournisseur? fournisseur;
  final Function onSave;

  const FournisseurDialog({super.key, this.fournisseur, required this.onSave});

  @override
  State<FournisseurDialog> createState() => _FournisseurDialogState();
}

class _FournisseurDialogState extends State<FournisseurDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic Info
  final _codeCtrl = TextEditingController();
  final _libelleCtrl = TextEditingController();
  CategorieFournisseur _categorie = CategorieFournisseur.ORDINAIRE;
  
  // Details
  final _emailCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _matriculeCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  
  // Sectors
  List<SecteurActivite> _allSecteurs = [];
  final List<int> _selectedSecteurIds = [];
  bool _isLoading = false;

  final SecteurActiviteService _secteurService = SecteurActiviteService();
  final FournisseurService _fournisseurService = FournisseurService();

  @override
  void initState() {
    super.initState();
    _loadSecteurs();
    if (widget.fournisseur != null) {
      _initFormData();
    } else {
      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  void _initFormData() {
    final f = widget.fournisseur!;
    _codeCtrl.text = f.code;
    _libelleCtrl.text = f.libelle;
    _categorie = f.categorieFournisseur;
    
    _emailCtrl.text = f.detailFournisseur.email;
    _adresseCtrl.text = f.detailFournisseur.adresse;
    _matriculeCtrl.text = f.detailFournisseur.matricule;
    _dateCtrl.text = f.detailFournisseur.dateDebutCollaboration;

    // Load selected sectors
    _selectedSecteurIds.addAll(f.secteurActivites.map((s) => s.idSecteurActivite!).toList());
  }

  Future<void> _loadSecteurs() async {
    try {
      final list = await _secteurService.getSecteurs();
      setState(() {
        _allSecteurs = list;
      });
    } catch (e) {
      // Handle error cleanly
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSecteurIds.isEmpty) {
      AppSnackBar.showWarning(context, "Veuillez sélectionner au moins un secteur");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final detail = DetailFournisseur(
        idDetailFournisseur: widget.fournisseur?.detailFournisseur.idDetailFournisseur,
        email: _emailCtrl.text,
        adresse: _adresseCtrl.text,
        matricule: _matriculeCtrl.text,
        dateDebutCollaboration: _dateCtrl.text,
      );

      final fournisseur = Fournisseur(
        idFournisseur: widget.fournisseur?.idFournisseur,
        code: _codeCtrl.text,
        libelle: _libelleCtrl.text,
        categorieFournisseur: _categorie,
        detailFournisseur: detail,
      );

      late Fournisseur savedFournisseur;
      if (widget.fournisseur != null) {
        savedFournisseur = await _fournisseurService.updateFournisseur(fournisseur);
      } else {
        savedFournisseur = await _fournisseurService.addFournisseur(fournisseur);
      }

      // Assign Sectors
      // Wait for all assignments to complete
      await Future.wait(
        _selectedSecteurIds.map((secteurId) => 
          _fournisseurService.assignSecteurActivite(secteurId, savedFournisseur.idFournisseur!)
        )
      );

      widget.onSave();
      Navigator.of(context).pop(true);
    } catch (e) {
      AppSnackBar.showError(context, "Erreur: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        widget.fournisseur != null ? "Modifier Fournisseur" : "Ajouter Fournisseur",
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Informations Générales", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(labelText: "Code", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _libelleCtrl,
                  decoration: const InputDecoration(labelText: "Libellé", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<CategorieFournisseur>(
                  value: _categorie,
                  decoration: const InputDecoration(labelText: "Catégorie", border: OutlineInputBorder()),
                  items: CategorieFournisseur.values.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.toString().split('.').last));
                  }).toList(),
                  onChanged: (v) => setState(() => _categorie = v!),
                ),
                const SizedBox(height: 16),
                
                Text("Détails", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _adresseCtrl,
                  decoration: const InputDecoration(labelText: "Adresse", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _matriculeCtrl,
                  decoration: const InputDecoration(labelText: "Matricule", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dateCtrl,
                  decoration: const InputDecoration(labelText: "Date Début (YYYY-MM-DD)", border: OutlineInputBorder()),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),

                 const SizedBox(height: 16),
                Text("Secteurs d'activité", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                if (_allSecteurs.isEmpty)
                  const Text("Chargement des secteurs...")
                else
                  Wrap(
                    spacing: 8,
                    children: _allSecteurs.map((sector) {
                      final isSelected = _selectedSecteurIds.contains(sector.idSecteurActivite);
                      return FilterChip(
                        label: Text(sector.libelleSecteurActivite),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSecteurIds.add(sector.idSecteurActivite!);
                            } else {
                              _selectedSecteurIds.remove(sector.idSecteurActivite!);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Enregistrer", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
