import 'package:flutter/material.dart';

import '../models/operateur.dart';
import '../services/operateurs_service.dart';
import '../session/user_session.dart';

class ChooseUserPage extends StatefulWidget {
  const ChooseUserPage({super.key});

  @override
  State<ChooseUserPage> createState() => _ChooseUserPageState();
}

class _ChooseUserPageState extends State<ChooseUserPage> {
  final OperateurService _service = OperateurService();
  List<Operateur> _ops = [];
  Operateur? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ops = await _service.getOperateurs();
      setState(() {
        _ops = ops;
        _selected = ops.isNotEmpty ? ops.first : null;
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
      appBar: AppBar(title: const Text('Choisir un utilisateur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Pour tester rapidement l'app, sélectionne un utilisateur (Operateur).",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Operateur>(
                        value: _selected,
                        items: _ops
                            .map(
                              (o) => DropdownMenuItem(
                                value: o,
                                child: Text('#${o.idOperateur} • ${o.prenom} ${o.nom}'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selected = v),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Utilisateur',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _selected == null
                            ? null
                            : () {
                                UserSession.currentOperateurId = _selected!.idOperateur;
                                Navigator.pop(context, true);
                              },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("Continuer"),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Astuce: tu peux créer des opérateurs via Swagger (/swagger-ui/) ou via l'écran existant si tu l'ajoutes.",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      )
                    ],
                  ),
      ),
    );
  }
}
