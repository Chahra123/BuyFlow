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
import '../providers/cart_provider.dart';
import '../../../../l10n/app_localizations.dart';

final _ordersServiceProvider = Provider((ref) => OrdersService());

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  LatLng _selected = const LatLng(36.8065, 10.1815); // Tunis default
  bool _loading = false;
  String? _error;

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
          // Nominatim usage policy: set a valid UA
          'User-Agent': 'BuyFlowFlutter/1.0 (contact: dev@buyflow.local)'
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
      setState(() => _error = AppLocalizations.of(context)!.veuillezSaisirAdresse);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final req = CreateOrderRequest(
        items: cart.lines
            .map((l) => OrderItemDto(produitId: l.produit.idProduit ?? 0, quantity: l.quantity))
            .toList(),
        address: OrderAddressDto(
          addressLine: addr,
          lat: _selected.latitude,
          lng: _selected.longitude,
          instructions: _instructionsController.text.trim().isEmpty ? null : _instructionsController.text.trim(),
        ),
      );
      final order = await ref.read(_ordersServiceProvider).createOrder(req);
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      context.go('/orders/${order.id}');
    } catch (e) {
      setState(() => _error = '${AppLocalizations.of(context)!.erreurCommande}: $e');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.livraisonPaiement)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _selected,
                  initialZoom: 13,
                  onTap: (tapPosition, point) async {
                    setState(() => _selected = point);
                    await _reverseGeocode(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'tn.esprit.buy_flow',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: _selected,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, size: 40, color: AppColors.primary),
                    )
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.adresseLivraison,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _instructionsController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.instructions,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.total}: ${cart.total.toStringAsFixed(2)} ${AppLocalizations.of(context)!.tnd}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
                        label: Text(AppLocalizations.of(context)!.commander),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
