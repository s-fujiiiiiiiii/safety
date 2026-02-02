import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'config_env.dart';
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

    _currentLatLng = LatLng(pos.latitude, pos.longitude);

    _markers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: _currentLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
        infoWindow: const InfoWindow(title: '現在地'),
      ),
    );

    setState(() {});

    if (_controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLatLng!, 15),
      );
    }
  }

  // =========================
  // 避難所取得
  // =========================
  Future<void> _fetchShelters() async {
    try {
      final res = await http.get(
        Uri.parse('${Env.apiBaseUrl}/api/shelters/'),
      );

      if (res.statusCode != 200) return;

      final List list = json.decode(res.body);

      for (final e in list) {
        final shelter = Shelter.fromJson(e);

        _markers.add(
          Marker(
            markerId: MarkerId('shelter_${shelter.id}'),
            position: LatLng(shelter.lat, shelter.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(
              title: shelter.name,
            ),
          ),
        );
      }

      setState(() {});
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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLatLng!,
          zoom: 15,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          _controller = controller;

          _controller!.animateCamera(
            CameraUpdate.newLatLngZoom(_currentLatLng!, 15),
          );
        },
      ),
    );
  }
}
