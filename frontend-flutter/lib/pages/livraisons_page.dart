import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/livraison.dart';
import '../services/livraisons_service.dart';
import '../session/user_session.dart';
import 'qr_scan_page.dart';

class LivraisonsPage extends StatefulWidget {
  const LivraisonsPage({super.key});

  @override
  State<LivraisonsPage> createState() => _LivraisonsPageState();
}

class _LivraisonsPageState extends State<LivraisonsPage> {
  final LivraisonService _service = LivraisonService();
  bool _loading = true;
  String? _error;
  List<Livraison> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.listAll();
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

  String _nextStatus(String current) {
    switch (current) {
      case 'EN_ATTENTE':
        return 'EN_COURS';
      case 'EN_COURS':
        return 'LIVREE';
      default:
        return 'LIVREE';
    }
  }

  Future<void> _scanAndUpdate() async {
    final userId = UserSession.currentOperateurId;
    if (userId == null) return;

    final token = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (token is! String) return;

    // Try to find it in current list to compute next status
    final match = _items.where((e) => e.qrToken == token).toList();
    final current = match.isNotEmpty ? match.first.status : 'EN_ATTENTE';
    final next = _nextStatus(current);

    try {
      await _service.updateStatusByQr(
        qrToken: token,
        status: next,
        updatedByOperateurId: userId,
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour: $current ➜ $next')),
      );
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
        title: const Text('Livraisons'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanAndUpdate,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scanner & MAJ'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? const Center(child: Text('Aucune livraison'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final l = _items[i];
                        final c = l.commande;
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
                                        'Commande #${c.idCommande} • ${c.produit.libelleProduit} x${c.quantite}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Chip(label: Text(l.status)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c.adresseLivraison ?? '',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Client: ${c.operateur.prenom} ${c.operateur.nom}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          if (l.lastUpdatedBy != null)
                                            Text(
                                              'MAJ par: ${l.lastUpdatedBy!.prenom} ${l.lastUpdatedBy!.nom}',
                                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                                            ),
                                        ],
                                      ),
                                    ),
                                    QrImageView(
                                      data: l.qrToken,
                                      version: QrVersions.auto,
                                      size: 90,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'QR: ${l.qrToken}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: Colors.black45),
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
