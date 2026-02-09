import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'shelters_api.dart';
import 'shelter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _currentLatLng;

  final Set<Marker> _markers = {};
  List<Shelter> _shelters = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _getCurrentLocation();
    await _fetchShelters();
  }

  // =========================
  // 現在地取得
  // =========================
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng = LatLng(pos.latitude, pos.longitude);
    });
  }

  // =========================
  // 避難所取得（全件）
  // =========================
  Future<void> _fetchShelters() async {
    try {
      debugPrint('📡 shelters API 呼び出し開始');

      final shelters = await fetchNearbyShelters();

      debugPrint('📦 shelters 件数: ${shelters.length}');

      final Set<Marker> newMarkers = {};

      for (final shelter in shelters) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('shelter_${shelter.id}'),
            position: LatLng(
              shelter.latitude,
              shelter.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: shelter.name,
              snippet: shelter.address,
            ),
          ),
        );
      }

      setState(() {
        _shelters = shelters;
        _markers
          ..clear()
          ..addAll(newMarkers);
      });
    } catch (e) {
      debugPrint('❌ shelter error: $e');
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    if (_currentLatLng == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('避難所マップ'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // ===== GoogleMap =====
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _controller = controller;
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(_currentLatLng!, 14),
              );
            },
          ),

          // ===== 下の避難所リスト =====
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: _shelters.isEmpty
                  ? const Center(
                      child: Text('近くに避難所がありません'),
                    )
                  : ListView.builder(
                      itemCount: _shelters.length,
                      itemBuilder: (context, index) {
                        final shelter = _shelters[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                          title: Text(shelter.name),
                          subtitle: Text(shelter.address ?? ''),
                          onTap: () {
                            _controller?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(
                                  shelter.latitude,
                                  shelter.longitude,
                                ),
                                16,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
