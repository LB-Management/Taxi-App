// driver_app/lib/screens/driver_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_map.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Mode'),
        actions: [
          Switch(
            value: _isOnline,
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
              if (value) {
                driverProvider.goOnline();
              } else {
                driverProvider.goOffline();
              }
            },
            activeColor: Colors.yellow,
          ),
        ],
      ),
      body: Stack(
        children: [
          DriverMap(
            currentLocation: driverProvider.currentLocation,
            ride: driverProvider.currentRide,
          ),
          if (driverProvider.rideRequest != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: RideRequestCard(
                request: driverProvider.rideRequest!,
                onAccept: () => driverProvider.acceptRide(),
                onReject: () => driverProvider.rejectRide(),
              ),
            ),
        ],
      ),
    );
  }
}

class RideRequestCard extends StatelessWidget {
  final RideRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RideRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Ride Request',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.yellow,
              ),
            ),
            const SizedBox(height: 10),
            Text('Pickup: ${request.pickupAddress}'),
            Text('Dropoff: ${request.dropoffAddress}'),
            Text('Distance: ${request.distance.toStringAsFixed(1)} km'),
            Text('Fare: \$${request.fare.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}