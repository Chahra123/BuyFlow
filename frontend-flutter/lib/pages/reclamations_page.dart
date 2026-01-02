import 'package:flutter/material.dart';

import '../models/reclamation.dart';
import '../services/reclamations_service.dart';
import '../session/user_session.dart';
import 'create_reclamation_page.dart';

class ReclamationsPage extends StatefulWidget {
  const ReclamationsPage({super.key});

  @override
  State<ReclamationsPage> createState() => _ReclamationsPageState();
}

class _ReclamationsPageState extends State<ReclamationsPage> {
  final ReclamationService _service = ReclamationService();
  bool _loading = true;
  String? _error;
  List<Reclamation> _items = [];

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
      final items = await _service.listByOperateur(userId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réclamations'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateReclamationPage()),
          );
          if (changed == true) _load();
        },
        icon: const Icon(Icons.add_comment),
        label: const Text('Nouvelle'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? const Center(child: Text('Aucune réclamation'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final r = _items[i];
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
                                        r.objet,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Chip(label: Text(r.status)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Commande #${r.commande.idCommande} • ${r.commande.produit.libelleProduit}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  r.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
