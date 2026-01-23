import 'package:flutter/material.dart';
import '../models/reglement.dart';
import '../services/reglements_service.dart';

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
        title: const Text(
          "Nouveau paiement",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF00509E)),
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
                  title: const Text("Payée ?"),
                  value: v,
                  onChanged: (val) => payeeCtrl.value = val,
                ),
              ),
            ],
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
                Navigator.pop(context);
                _refreshReglements();
              } catch (e) {
                _showSnackBar("Erreur lors de l'ajout", isError: true);
              }
            },
            child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiements")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0074D9),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showReglementDialog(),
      ),
      body: FutureBuilder<List<Reglement>>(
        future: reglements,
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
              child: Text("Aucun paiement",
                  style: TextStyle(color: Colors.grey, fontSize: 18)),
            );
          }

          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final r = list[i];
              final title = "Payé: ${r.montantPaye} | Restant: ${r.montantRestant}";
              final subtitle =
                  "Payée: ${r.payee == true ? "Oui" : "Non"} • Date: ${r.dateReglement ?? "-"}";

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.payments,
                      size: 36, color: Color(0xFF0074D9)),
                  title: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(subtitle),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
