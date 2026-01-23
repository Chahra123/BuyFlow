import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/reglement.dart';
import '../services/reglements_service.dart';
import '../core/theme/app_colors.dart';

class ReglementsPage extends StatefulWidget {
  const ReglementsPage({super.key});

  @override
  State<ReglementsPage> createState() => _ReglementsPageState();
}

class _ReglementsPageState extends State<ReglementsPage> {
  final ReglementService service = ReglementService();
  late Future<List<Reglement>> reglements;

  @override
  void initState() {
    super.initState();
    _refreshReglements();
  }

  void _refreshReglements() {
    setState(() {
      reglements = service.getReglements();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle,
                color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.outfit(fontSize: 16)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showReglementDialog({Reglement? reglement}) {
    final montantPayeCtrl = TextEditingController(
        text: reglement?.montantPaye.toString() ?? '');
    final montantRestantCtrl = TextEditingController(
        text: reglement?.montantRestant.toString() ?? '');
    final payeeCtrl = ValueNotifier<bool>(reglement?.payee ?? false);
    final dateCtrl =
    TextEditingController(text: reglement?.dateReglement ?? '');
    final factureIdCtrl = TextEditingController(
        text: reglement?.factureId?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Nouveau paiement",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montantPayeCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Montant payé",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: montantRestantCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Montant restant",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(
                  labelText: "Date règlement (dd/MM/yyyy)",
                  border: OutlineInputBorder(),
                  hintText: "Ex: 23/01/2026",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: factureIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Facture ID (optionnel)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: payeeCtrl,
                builder: (_, v, __) => SwitchListTile(
                  title: Text("Payée ?", style: GoogleFonts.outfit()),
                  value: v,
                  activeColor: AppColors.primary,
                  onChanged: (val) => payeeCtrl.value = val,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final montantPaye = double.tryParse(montantPayeCtrl.text) ?? 0.0;
              final montantRestant =
                  double.tryParse(montantRestantCtrl.text) ?? 0.0;
              final date = dateCtrl.text.trim();
              final factureId = int.tryParse(factureIdCtrl.text.trim());
              final payee = payeeCtrl.value;

              if (montantPaye <= 0 && montantRestant <= 0) {
                _showSnackBar("Saisis au moins un montant", isError: true);
                return;
              }

              final newReglement = Reglement(
                montantPaye: montantPaye,
                montantRestant: montantRestant,
                payee: payee,
                dateReglement: date.isEmpty ? null : date,
                factureId: factureId,
              );

              try {
                await service.addReglement(newReglement);
                _showSnackBar("Paiement ajouté avec succès !");
                if (mounted) Navigator.pop(context);
                _refreshReglements();
              } catch (e) {
                _showSnackBar("Erreur lors de l'ajout", isError: true);
              }
            },
            child: Text("Ajouter", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: Text("Paiements", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Nouveau Paiement", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showReglementDialog(),
      ),
      body: FutureBuilder<List<Reglement>>(
        future: reglements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                   const SizedBox(height: 16),
                   Text("Erreur : ${snapshot.error}", style: GoogleFonts.outfit(color: AppColors.error)),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.payments_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                   const SizedBox(height: 16),
                   Text("Aucun paiement", style: GoogleFonts.outfit(fontSize: 18, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final r = list[i];
              final isPaid = r.payee == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isPaid ? AppColors.success : AppColors.secondary).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPaid ? Icons.check_circle : Icons.pending,
                        color: isPaid ? AppColors.success : AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payé: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'TND').format(r.montantPaye)}",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Restant: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'TND').format(r.montantRestant)}",
                            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                         Text(
                            r.dateReglement ?? "-",
                            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          if(r.factureId != null)
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                               decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4)),
                               child: Text("Facture #${r.factureId}", style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                             ),
                      ],
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
}
