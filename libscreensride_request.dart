// lib/screens/ride_request.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../widgets/ride_map.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  String? _selectedVehicleType;

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Ride'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RideMap(
              pickup: rideProvider.pickupLocation!,
              dropoff: rideProvider.dropoffLocation,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _pickupController,
                  decoration: const InputDecoration(
                    labelText: 'Pickup Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _dropoffController,
                  decoration: const InputDecoration(
                    labelText: 'Dropoff Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedVehicleType,
                  items: const [
                    DropdownMenuItem(
                      value: 'standard',
                      child: Text('Standard'),
                    ),
                    DropdownMenuItem(
                      value: 'premium',
                      child: Text('Premium'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicleType = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (_pickupController.text.isNotEmpty && 
                        _dropoffController.text.isNotEmpty &&
                        _selectedVehicleType != null) {
                      rideProvider.requestRide(
                        pickup: _pickupController.text,
                        dropoff: _dropoffController.text,
                        vehicleType: _selectedVehicleType!,
                      );
                    }
                  },
                  child: const Text('Request Ride'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }
}