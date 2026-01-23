import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/complaint_models.dart';
import '../../data/services/complaints_service.dart';

final _complaintsServiceProvider = Provider((ref) => ComplaintsService());

class ComplaintsScreen extends ConsumerWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(_complaintsServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Réclamations')),
      body: FutureBuilder<List<ComplaintDto>>(
        future: service.myComplaints(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          final list = snap.data ?? const [];
          if (list.isEmpty) {
            return const Center(child: Text('Aucune réclamation'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final c = list[i];
              return ListTile(
                title: Text('Commande #${c.orderId} • ${c.category}'),
                subtitle: Text('${c.status} • ${c.description}', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/complaints/${c.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
