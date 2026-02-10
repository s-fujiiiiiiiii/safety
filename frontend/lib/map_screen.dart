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

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ok = await _getCurrentLocation();
    if (!ok) return;

    await _fetchShelters();

    setState(() {
      _loading = false;
    });
  }

  // =========================
  // 現在地取得
  // =========================
  Future<bool> _getCurrentLocation() async {
    // ① 位置情報サービス確認
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ Location service disabled');
      return false;
    }

    // ② 権限確認
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('❌ Location permission denied');
      return false;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentLatLng = LatLng(pos.latitude, pos.longitude);
    return true;
  }

  // =========================
  // 避難所取得
  // =========================
  Future<void> _fetchShelters() async {
    try {
      final shelters = await fetchNearbyShelters();

      final Set<Marker> newMarkers = shelters.map((shelter) {
        return Marker(
          markerId: MarkerId('shelter_${shelter.id}'),
          position: LatLng(shelter.latitude, shelter.longitude),
          infoWindow: InfoWindow(
            title: shelter.name,
            snippet: shelter.address,
          ),
        );
      }).toSet();

      _shelters = shelters;
      _markers
        ..clear()
        ..addAll(newMarkers);
    } catch (e) {
      debugPrint('❌ shelter error: $e');
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    if (_loading || _currentLatLng == null) {
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
            },
            compassEnabled: true,
            zoomControlsEnabled: false,
          ),

          // ===== 下リスト =====
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: _shelters.isEmpty
                  ? const Center(child: Text('近くに避難所がありません'))
                  : ListView.builder(
                      itemCount: _shelters.length,
                      itemBuilder: (context, index) {
                        final shelter = _shelters[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.red),
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
