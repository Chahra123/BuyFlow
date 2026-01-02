import 'package:flutter/material.dart';

import '../models/commande.dart';
import '../services/commandes_service.dart';
import '../services/reclamations_service.dart';
import '../session/user_session.dart';

class CreateReclamationPage extends StatefulWidget {
  const CreateReclamationPage({super.key});

  @override
  State<CreateReclamationPage> createState() => _CreateReclamationPageState();
}

class _CreateReclamationPageState extends State<CreateReclamationPage> {
  final CommandeService _commandeService = CommandeService();
  final ReclamationService _service = ReclamationService();

  List<Commande> _commandes = [];
  Commande? _selected;
  final TextEditingController _objetCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;

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
      final cmds = await _commandeService.getMesCommandes(operateurId: userId);
      setState(() {
        _commandes = cmds;
        _selected = cmds.isNotEmpty ? cmds.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final userId = UserSession.currentOperateurId;
    if (userId == null) return;
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisir une commande')));
      return;
    }
    if (_objetCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Objet et description requis')));
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.create(
        operateurId: userId,
        commandeId: _selected!.idCommande,
        objet: _objetCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    _objetCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle réclamation')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    DropdownButtonFormField<Commande>(
                      value: _selected,
                      items: _commandes
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text('#${c.idCommande} • ${c.produit.libelleProduit}'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selected = v),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Commande concernée',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _objetCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Objet',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descCtrl,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check),
                      label: const Text('Envoyer'),
                    )
                  ],
                ),
    );
  }
}
