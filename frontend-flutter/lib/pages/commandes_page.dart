import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';

import '../models/commande.dart';
import '../services/commandes_service.dart';
import '../session/user_session.dart';
import 'create_commande_page.dart';

class CommandesPage extends StatefulWidget {
  const CommandesPage({super.key});

  @override
  State<CommandesPage> createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> {
  final CommandeService _service = CommandeService();
  bool _loading = true;
  String? _error;
  List<Commande> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = UserSession.currentOperateurId;
    if (userId == null) {
      setState(() {
        _error = 'Aucun utilisateur sélectionné';
        _loading = false;
      });
      return;
    }
    try {
      final items = await _service.getMesCommandes(operateurId: userId);
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _confirm(Commande c) async {
    try {
      await _service.confirmCommande(c.idCommande);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande confirmée ✅ Livraison créée.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _invoice(Commande c) async {
    try {
      final bytes = await _service.downloadInvoicePdfBytes(c.idCommande);
      await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytes));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCommandePage()),
          );
          if (changed == true) _load();
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nouvelle'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? const Center(child: Text('Aucune commande'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final c = _items[i];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${c.produit.libelleProduit}  x${c.quantite}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Chip(label: Text(c.status)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c.adresseLivraison ?? 'Adresse: -',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (c.status == 'EN_ATTENTE_CONFIRMATION')
                                      ElevatedButton.icon(
                                        onPressed: () => _confirm(c),
                                        icon: const Icon(Icons.verified),
                                        label: const Text('Confirmer'),
                                      ),
                                    if (c.status == 'CONFIRMEE')
                                      OutlinedButton.icon(
                                        onPressed: () => _invoice(c),
                                        icon: const Icon(Icons.picture_as_pdf),
                                        label: const Text('Facture PDF'),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
