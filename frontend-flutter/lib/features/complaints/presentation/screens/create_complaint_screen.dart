import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/complaints_service.dart';

final _complaintsServiceProvider = Provider((ref) => ComplaintsService());

class CreateComplaintScreen extends ConsumerStatefulWidget {
  final int? orderId;
  const CreateComplaintScreen({super.key, required this.orderId});

  @override
  ConsumerState<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends ConsumerState<CreateComplaintScreen> {
  String _category = 'OTHER';
  final _descriptionCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle réclamation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: const [
                DropdownMenuItem(value: 'DELIVERY_DELAY', child: Text('Retard')),
                DropdownMenuItem(value: 'DAMAGED_PRODUCT', child: Text('Produit abîmé')),
                DropdownMenuItem(value: 'MISSING_ITEM', child: Text('Produit manquant')),
				DropdownMenuItem(value: 'WRONG_ITEM', child: Text('Produit éronné')),
				DropdownMenuItem(value: 'PAYMENT_ISSUE', child: Text('Problème de paiement')),
                DropdownMenuItem(value: 'OTHER', child: Text('Autre')),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'OTHER'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : const Text('Envoyer'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (widget.orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OrderId manquant pour créer une réclamation.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final svc = ref.read(_complaintsServiceProvider);
      final complaint = await svc.createComplaint(
        orderId: widget.orderId!,
        category: _category,
        description: _descriptionCtrl.text.trim(),
      );
      if (!mounted) return;
      context.go('/complaints/${complaint.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
