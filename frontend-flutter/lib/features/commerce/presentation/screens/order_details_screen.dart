import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/order_models.dart';
import '../../data/services/orders_service.dart';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';

  
final _ordersServiceProvider = Provider((ref) => OrdersService());

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  late Future<CustomerOrderDto> _future;
  String? _qrData;

  @override
  void initState() {
    super.initState();
    _future = ref.read(_ordersServiceProvider).getOrder(widget.orderId);
    _loadQr();
  }

  Future<void> _loadQr() async {
    try {
      final qr = await ref.read(_ordersServiceProvider).getQrData(widget.orderId);
      if (mounted) setState(() => _qrData = qr);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Commande #${widget.orderId}')),
      body: FutureBuilder<CustomerOrderDto>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoTile(title: 'Statut', value: order.status),
              if (order.deliveryAddress != null) _InfoTile(title: 'Adresse', value: order.deliveryAddress!),
              const SizedBox(height: 12),
              Text('Articles', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...order.items.map((i) => ListTile(
                    title: Text(i.produitLabel ?? 'Produit #${i.produitId}'),
                    subtitle: Text('Quantité: ${i.quantity}'),
                    trailing: i.unitPrice != null ? Text('${i.unitPrice!.toStringAsFixed(2)} TND') : null,
                  )),
              const Divider(),
              if (_qrData != null && _qrData!.isNotEmpty) ...[
                Text('QR de livraison', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Center(
                  child: QrImageView(
                    data: _qrData!,
                    size: 180,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
						final bytess = await ref.read(_ordersServiceProvider).downloadInvoicePdfBytes(widget.orderId);
						await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytess));
                      final bytes = await ref.read(_ordersServiceProvider).downloadInvoice(widget.orderId);
                      final dir = await getTemporaryDirectory();
                      final file = File('${dir.path}/invoice_${widget.orderId}.pdf');
                      await file.writeAsBytes(bytes, flush: true);
                      await OpenFilex.open(file.path);
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Facture PDF'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/complaints/create?orderId=${widget.orderId}'),
                    icon: const Icon(Icons.support_agent_outlined),
                    label: const Text('Réclamation'),
                  ),
                  OutlinedButton.icon(
                    onPressed: order.status == 'ASSIGNED' || order.status == 'OUT_FOR_DELIVERY' || order.status == 'DELIVERED'
                        ? null
                        : () async {
                            await ref.read(_ordersServiceProvider).cancelOrder(widget.orderId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commande annulée')));
                              setState(() {
                                _future = ref.read(_ordersServiceProvider).getOrder(widget.orderId);
                              });
                            }
                          },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Annuler'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
