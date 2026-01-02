import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final Location _loc = Location();
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(36.8065, 10.1815); // Tunis fallback
  LatLng? _picked;
  String _address = '';
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      bool enabled = await _loc.serviceEnabled();
      if (!enabled) enabled = await _loc.requestService();

      PermissionStatus perm = await _loc.hasPermission();
      if (perm == PermissionStatus.denied) {
        perm = await _loc.requestPermission();
      }

      if (enabled &&
          (perm == PermissionStatus.granted ||
              perm == PermissionStatus.grantedLimited)) {
        final data = await _loc.getLocation();
        final lat = data.latitude;
        final lng = data.longitude;
        if (lat != null && lng != null) {
          setState(() {
            _center = LatLng(lat, lng);
            _picked = _center;
          });
          // Move map after first frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(_center, 15);
          });
          await _reverseGeocode(_center);
        }
      } else {
        // fallback: still reverse geocode Tunis for UX
        _picked = _center;
        await _reverseGeocode(_center);
      }
    } catch (_) {
      // ignore: keep fallback
    }
  }

  Future<void> _reverseGeocode(LatLng p) async {
    setState(() => _loadingAddress = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${p.latitude}&lon=${p.longitude}',
      );

      // Nominatim requires a valid User-Agent. Keep it generic for a student project.
      final resp = await http.get(uri, headers: {
        'User-Agent': 'BuyFlow/1.0 (Flutter; OpenStreetMap Nominatim)',
        'Accept-Language': 'fr',
      });

      if (resp.statusCode == 200) {
        final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
        final displayName = (jsonBody['display_name'] ?? '') as String;
        setState(() => _address = displayName);
      } else {
        setState(() => _address = '');
      }
    } catch (_) {
      setState(() => _address = '');
    } finally {
      setState(() => _loadingAddress = false);
    }
  }

  Future<void> _onTap(LatLng p) async {
    setState(() => _picked = p);
    await _reverseGeocode(p);
  }

  void _confirm() {
    final picked = _picked ?? _center;
    Navigator.pop(context, {
      'lat': picked.latitude,
      'lng': picked.longitude,
      'address': _address,
    });
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked ?? _center;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une adresse'),
        actions: [
          IconButton(
            onPressed: _confirm,
            icon: const Icon(Icons.check),
            tooltip: 'Confirmer',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onTap: (tapPosition, point) => _onTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'buy_flow',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: picked,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _loadingAddress
                          ? const Text('Recherche de l’adresse...')
                          : Text(
                              _address.isEmpty ? 'Adresse non trouvée' : _address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _confirm,
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
