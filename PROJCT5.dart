import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaxiHomePage extends StatefulWidget {
  @override
  _TaxiHomePageState createState() => _TaxiHomePageState();
}

class _TaxiHomePageState extends State<TaxiHomePage> {
  // Map & Location Variables
  late GoogleMapController _mapController;
  LatLng _currentLocation = LatLng(0, 0); // Default location
  LatLng? _destinationLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String _googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY";

  // UI State Variables
  String _selectedRideType = 'Car';
  bool _isLoading = false;
  String _searchQuery = '';
  double _fareEstimate = 0.0;
  String _eta = '';

  // Ride Types Data
  final List<Map<String, dynamic>> _rideTypes = [
    {'type': 'Bike', 'icon': Icons.electric_bike, 'multiplier': 0.7},
    {'type': 'Car', 'icon': Icons.directions_car, 'multiplier': 1.0},
    {'type': 'Premium', 'icon': Icons.directions_car_filled, 'multiplier': 1.5},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // 1. Location Services
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _showLocationServiceError();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _showLocationPermissionError();
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _addMarker(_currentLocation, 'current', 'Your Location');
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation, 15),
    );
  }

  void _showLocationServiceError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enable location services'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showLocationPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location permissions are denied'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 2. Map Markers & Routing
  void _addMarker(LatLng position, String markerId, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            markerId == 'current' 
              ? BitmapDescriptor.hueAzure
              : BitmapDescriptor.hueRed,
          ),
        ),
      );
    });
  }

  Future<void> _getRouteDirections() async {
    if (_destinationLocation == null) return;

    setState(() => _isLoading = true);

    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        _googleApiKey,
        PointLatLng(_currentLocation.latitude, _currentLocation.longitude),
        PointLatLng(_destinationLocation!.latitude, _destinationLocation!.longitude),
      );

      if (result.points.isEmpty) throw Exception('No route found');

      List<LatLng> routeCoords = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: routeCoords,
            color: Colors.yellow,
            width: 5,
          ),
        );
      });

      await _calculateFareAndETA(routeCoords);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching route: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. Fare Calculation & API Integration
  Future<void> _calculateFareAndETA(List<LatLng> route) async {
    // Calculate distance in meters
    double totalDistance = 0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        route[i].latitude,
        route[i].longitude,
        route[i+1].latitude,
        route[i+1].longitude,
      );
    }

    // Get current ride type multiplier
    double multiplier = _rideTypes.firstWhere(
      (type) => type['type'] == _selectedRideType,
    )['multiplier'];

    // Calculate fare (base + distance)
    double baseFare = 2.50;
    double distanceFare = (totalDistance / 1000) * 1.20; // $1.20 per km
    double totalFare = (baseFare + distanceFare) * multiplier;

    // Calculate ETA (assuming average speed of 30km/h)
    int etaMinutes = (totalDistance / 500).round(); // meters per minute

    setState(() {
      _fareEstimate = double.parse(totalFare.toStringAsFixed(2));
      _eta = '${etaMinutes} min';
    });

    // In a real app, you would call your backend API here
    // await _sendRideRequestToBackend(totalDistance, etaMinutes);
  }

  // 4. Search & Destination Handling
  Future<void> _searchDestination(String query) async {
    if (query.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey&location=${_currentLocation.latitude},${_currentLocation.longitude}&radius=50000',
        ),
      );

      final predictions = json.decode(response.body)['predictions'];
      // Show search results dialog
      _showSearchResults(predictions);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching destinations'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey',
        ),
      );

      final result = json.decode(response.body)['result'];
      final location = result['geometry']['location'];
      final destination = LatLng(location['lat'], location['lng']);

      setState(() {
        _destinationLocation = destination;
        _addMarker(destination, 'destination', result['name']);
      });

      await _getRouteDirections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting place details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSearchResults(List<dynamic> predictions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      builder: (context) {
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.location_on, color: Colors.yellow[600]),
              title: Text(
                predictions[index]['description'],
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _getPlaceDetails(predictions[index]['place_id']);
              },
            );
          },
        );
      },
    );
  }

  // 5. Ride Request Functionality
  Future<void> _requestRide() async {
    if (_destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a destination first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call to request ride
    await Future.delayed(Duration(seconds: 2));

    // In a real app, you would:
    // 1. Send ride request to your backend
    // 2. Handle driver matching
    // 3. Navigate to ride tracking screen

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ride requested successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to ride tracking screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => RideTrackingPage()));
  }

  // 6. UI Building Methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            polylines: _polylines,
          ),

          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // Current Location Button
          Positioned(
            right: 16,
            bottom: 180,
            child: FloatingActionButton(
              backgroundColor: Colors.grey[900]!.withOpacity(0.9),
              mini: true,
              onPressed: _getCurrentLocation,
              child: Icon(Icons.my_location, color: Colors.yellow[600]),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              children: [
                if (_destinationLocation != null) _buildFareInfo(),
                _buildRideTypeSelector(),
                SizedBox(height: 16),
                _buildRequestRideButton(),
              ],
            ),
          ),

          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Colors.yellow)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.yellow[600], size: 24),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter destination...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white, fontSize: 16),
              onChanged: (value) => _searchQuery = value,
              onSubmitted: (value) => _searchDestination(value),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchQuery = '';
                  _destinationLocation = null;
                  _markers.removeWhere((m) => m.markerId.value == 'destination');
                  _polylines.clear();
                });
              },
              child: Icon(Icons.close, color: Colors.grey[400], size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildRideTypeSelector() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _rideTypes.map((type) {
          bool isSelected = _selectedRideType == type['type'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedRideType = type['type']);
              if (_destinationLocation != null) _calculateFareAndETA(_polylines.first.points);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow[800]!.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: Colors.yellow[600]!, width: 1.5) : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(type['icon'], 
                    color: isSelected ? Colors.yellow[600] : Colors.grey[400], 
                    size: 24),
                  SizedBox(height: 4),
                  Text(
                    type['type'],
                    style: TextStyle(
                      color: isSelected ? Colors.yellow[600] : Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFareInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Fare',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              Text(
                '\$$_fareEstimate',
                style: TextStyle(
                  color: Colors.yellow[600],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ETA',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              Text(
                _eta,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestRideButton() {
    return GestureDetector(
      onTap: _requestRide,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.yellow[600],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow[800]!.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              )
            : Text(
                'REQUEST RIDE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
      ),
    );
  }
}