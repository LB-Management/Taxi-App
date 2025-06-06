// lib/widgets/ride_map.dart
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class RideMap extends StatefulWidget {
  final LatLng pickup;
  final LatLng? dropoff;
  final LatLng? driverLocation;
  
  const RideMap({
    super.key,
    required this.pickup,
    this.dropoff,
    this.driverLocation,
  });

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> {
  late MapboxMapController mapController;

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: 'YOUR_MAPBOX_ACCESS_TOKEN',
      initialCameraPosition: CameraPosition(
        target: widget.pickup,
        zoom: 14,
      ),
      onMapCreated: (controller) {
        mapController = controller;
        _addMarkers();
      },
    );
  }

  void _addMarkers() {
    // Add pickup marker
    mapController.addSymbol(
      SymbolOptions(
        geometry: widget.pickup,
        iconImage: 'car-15',
        iconSize: 1.5,
      ),
    );

    // Add dropoff marker if available
    if (widget.dropoff != null) {
      mapController.addSymbol(
        SymbolOptions(
          geometry: widget.dropoff!,
          iconImage: 'marker-15',
          iconSize: 1.5,
        ),
      );
    }

    // Add driver marker if available
    if (widget.driverLocation != null) {
      mapController.addSymbol(
        SymbolOptions(
          geometry: widget.driverLocation!,
          iconImage: 'car-15',
          iconSize: 1.5,
        ),
      );
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}