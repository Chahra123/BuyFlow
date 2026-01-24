import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/order_models.dart';
import '../../data/services/orders_service.dart';
import '../../../../services/reglements_service.dart';
import '../../../../models/reglement.dart';
import '../providers/cart_provider.dart';

final _ordersServiceProvider = Provider((ref) => OrdersService());

enum PaymentMethod { livraison, carte }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cardNumberController = TextEditingController();

  LatLng _selected = const LatLng(36.8065, 10.1815); // Tunis default
  bool _loading = false;
  String? _error;

  PaymentMethod? _paymentMethod;

  Future<void> _reverseGeocode(LatLng p) async {
    try {
      final dio = Dio();
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': p.latitude,
          'lon': p.longitude,
        },
        options: Options(headers: {
          'User-Agent': 'BuyFlowFlutter/1.0 (contact: dev@buyflow.local)',
        }),
      );
      final display = res.data['display_name']?.toString();
      if (display != null && mounted) {
        _addressController.text = display;
      }
    } catch (_) {
      // silent
    }
  }

  Future<void> _submit() async {
    final cart = ref.read(cartProvider);
    if (cart.lines.isEmpty) return;

    final addr = _addressController.text.trim();
    if (addr.isEmpty) {
      setState(() => _error = 'Veuillez saisir une adresse.');
      return;
    }

    if (_paymentMethod == PaymentMethod.carte &&
        _cardNumberController.text.trim().isEmpty) {
      setState(() => _error = 'Veuillez saisir un numéro de carte.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1️⃣ Création de la commande (inchangé)
      final req = CreateOrderRequest(
        items: cart.lines
            .map((l) => OrderItemDto(
          produitId: l.produit.idProduit ?? 0,
          quantity: l.quantity,
        ))
            .toList(),
        address: OrderAddressDto(
          addressLine: addr,
          lat: _selected.latitude,
          lng: _selected.longitude,
          instructions: _instructionsController.text.trim().isEmpty
              ? null
              : _instructionsController.text.trim(),
        ),
      );

      final order =
      await ref.read(_ordersServiceProvider).createOrder(req);

      // 2️⃣ Paiement automatique UNIQUEMENT si carte
      if (_paymentMethod == PaymentMethod.carte) {
        final reglementService = ReglementService();

        await reglementService.addReglement(
          Reglement(
            dateReglement:
            '${DateTime.now().day.toString().padLeft(2, '0')}/'
                '${DateTime.now().month.toString().padLeft(2, '0')}/'
                '${DateTime.now().year}',
            montantPaye: cart.total,
            montantRestant: 0,
            payee: true,
          ),
        );
      }

      // 3️⃣ Nettoyage + redirection (inchangé)
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      context.go('/orders/${order.id}');
    } catch (e) {
      setState(() => _error = 'Erreur lors de la commande: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() => _reverseGeocode(_selected));
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Livraison & Paiement')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _selected,
                  initialZoom: 13,
                  onTap: (_, point) async {
                    setState(() => _selected = point);
                    await _reverseGeocode(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'tn.esprit.buy_flow',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse de livraison',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instructions (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔵 Paiement
                  RadioListTile<PaymentMethod>(
                    title: const Text('Paiement à la livraison'),
                    value: PaymentMethod.livraison,
                    groupValue: _paymentMethod,
                    onChanged: (v) =>
                        setState(() => _paymentMethod = v),
                  ),
                  RadioListTile<PaymentMethod>(
                    title: const Text('Paiement par carte'),
                    value: PaymentMethod.carte,
                    groupValue: _paymentMethod,
                    onChanged: (v) =>
                        setState(() => _paymentMethod = v),
                  ),
                  TextField(
                    controller: _cardNumberController,
                    enabled: _paymentMethod == PaymentMethod.carte,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de carte (fictif)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total: ${cart.total.toStringAsFixed(2)} TND',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                            : const Icon(Icons.check),
                        label: const Text('Commander'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
