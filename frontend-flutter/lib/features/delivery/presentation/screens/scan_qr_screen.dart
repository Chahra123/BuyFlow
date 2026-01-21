import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/services/delivery_service.dart';

final _deliveryServiceProvider = Provider((ref) => DeliveryService());

class ScanQrScreen extends ConsumerStatefulWidget {
  final int orderId;
  const ScanQrScreen({super.key, required this.orderId});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final service = ref.read(_deliveryServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scanner QR')),
      body: MobileScanner(
        onDetect: (capture) async {
          if (_busy) return;
          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;
          final value = barcodes.first.rawValue;
          if (value == null || value.isEmpty) return;

          setState(() => _busy = true);
          try {
            await service.scanAndDeliver(orderId: widget.orderId, qrData: value);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commande livrée ✅')));
            context.pop();
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
            setState(() => _busy = false);
          }
        },
      ),
    );
  }
}
