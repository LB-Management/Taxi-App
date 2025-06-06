import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class RideMap extends StatefulWidget {
  final LatLng currentLocation;
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;
  final LatLng? driverLocation;
  final List<LatLng>? polylinePoints;

  const RideMap({
    super.key,
    required this.currentLocation,
    this.pickupLocation,
    this.dropoffLocation,
    this.driverLocation,
    this.polylinePoints,
  });

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> {
  late MapboxMapController mapController;
  Symbol? _currentLocationSymbol;
  Symbol? _pickupSymbol;
  Symbol? _dropoffSymbol;
  Symbol? _driverSymbol;
  Polyline? _routePolyline;

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: 'YOUR_MAPBOX_ACCESS_TOKEN',
      initialCameraPosition: CameraPosition(
        target: widget.pickupLocation ?? widget.currentLocation,
        zoom: 14,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,
    );
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  void _onStyleLoaded() async {
    // Add current location marker
    _currentLocationSymbol = await mapController.addSymbol(
      SymbolOptions(
        geometry: widget.currentLocation,
        iconImage: 'car-15',
        iconSize: 1.5,
        iconColor: '#FFFFFF',
      ),
    );

    // Add pickup marker if available
    if (widget.pickupLocation != null) {
      _pickupSymbol = await mapController.addSymbol(
        SymbolOptions(
          geometry: widget.pickupLocation!,
          iconImage: 'marker-15',
          iconSize: 1.5,
          iconColor: '#FFD700',
        ),
      );
    }

    // Add dropoff marker if available
    if (widget.dropoffLocation != null) {
      _dropoffSymbol = await mapController.addSymbol(
        SymbolOptions(
          geometry: widget.dropoffLocation!,
          iconImage: 'marker-15',
          iconSize: 1.5,
          iconColor: '#FF0000',
        ),
      );
    }

    // Add driver marker if available
    if (widget.driverLocation != null) {
      _driverSymbol = await mapController.addSymbol(
        SymbolOptions(
          geometry: widget.driverLocation!,
          iconImage: 'car-15',
          iconSize: 1.5,
          iconColor: '#FFD700',
        ),
      );
    }

    // Add route polyline if available
    if (widget.polylinePoints != null && widget.polylinePoints!.isNotEmpty) {
      _routePolyline = await mapController.addPolyline(
        PolylineOptions(
          geometry: widget.polylinePoints!
              .map((point) => [point.longitude, point.latitude])
              .toList(),
          polylineColor: '#FFD700',
          polylineWidth: 5,
        ),
      );
    }

    // Fit camera to show all points
    final points = [
      widget.currentLocation,
      if (widget.pickupLocation != null) widget.pickupLocation!,
      if (widget.dropoffLocation != null) widget.dropoffLocation!,
      if (widget.driverLocation != null) widget.driverLocation!,
    ];

    if (points.length > 1) {
      final bounds = LatLngBounds.fromLatLngList(points);
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    } else {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: points.first,
            zoom: 14,
          ),
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