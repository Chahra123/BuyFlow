import 'package:flutter/material.dart';

import '../models/produit.dart';
import '../services/commandes_service.dart';
import '../services/produits_service.dart';
import '../session/user_session.dart';
import 'map_picker_page.dart';

class CreateCommandePage extends StatefulWidget {
  const CreateCommandePage({super.key});

  @override
  State<CreateCommandePage> createState() => _CreateCommandePageState();
}

class _CreateCommandePageState extends State<CreateCommandePage> {
  final ProduitService _produitService = ProduitService();
  final CommandeService _commandeService = CommandeService();

  List<Produit> _produits = [];
  Produit? _selectedProduit;
  int _quantite = 1;
  final TextEditingController _adresseCtrl = TextEditingController();
  double? _lat;
  double? _lng;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduits();
  }

  Future<void> _loadProduits() async {
    try {
      final p = await _produitService.getProduits();
      setState(() {
        _produits = p;
        _selectedProduit = p.isNotEmpty ? p.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (result is Map<String, dynamic>) {
      setState(() {
        _adresseCtrl.text = (result['address'] ?? '') as String;
        _lat = (result['lat'] as num?)?.toDouble();
        _lng = (result['lng'] as num?)?.toDouble();
      });
    }
  }

  Future<void> _save() async {
    final userId = UserSession.currentOperateurId;
    if (userId == null) return;
    if (_selectedProduit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun produit sélectionné')),
      );
      return;
    }
    if (_adresseCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adresse de livraison requise')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _commandeService.createCommande(
        operateurId: userId,
        produitId: _selectedProduit!.idProduit!,
        quantite: _quantite,
        adresse: _adresseCtrl.text.trim(),
        latitude: _lat,
        longitude: _lng,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    _adresseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle commande')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    DropdownButtonFormField<Produit>(
                      value: _selectedProduit,
                      items: _produits
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text('${p.libelleProduit} (ID ${p.idProduit})'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedProduit = v),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Produit',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Quantité', style: TextStyle(fontSize: 16)),
                        const Spacer(),
                        IconButton(
                          onPressed: _quantite > 1 ? () => setState(() => _quantite--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_quantite', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        IconButton(
                          onPressed: () => setState(() => _quantite++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _adresseCtrl,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Adresse de livraison',
                        hintText: 'Saisir l\'adresse ou choisir sur la carte',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickOnMap,
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Choisir sur Maps'),
                          ),
                        ),
                      ],
                    ),
                    if (_lat != null && _lng != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Coordonnées: $_lat, $_lng', style: const TextStyle(color: Colors.black54)),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check),
                      label: const Text('Créer la commande'),
                    ),
                  ],
                ),
    );
  }
}
