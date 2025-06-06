import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/blocs/driver/driver_bloc.dart';
import 'package:driver_app/src/widgets/driver_map.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(LoadDriverData());
  }

  @override
  Widget build(BuildContext context) {
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
                context.read<DriverBloc>().add(GoOnline());
              } else {
                context.read<DriverBloc>().add(GoOffline());
              }
            },
            activeColor: Colors.yellow,
          ),
        ],
      ),
      body: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
          if (state is DriverInitial || state is DriverLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is DriverDataLoaded) {
            return Stack(
              children: [
                DriverMap(
                  currentLocation: state.currentLocation,
                  ride: state.currentRide,
                ),
                if (state.rideRequest != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: _buildRideRequestCard(context, state.rideRequest!),
                  ),
                if (state.currentRide != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: _buildRideControlCard(context, state.currentRide!),
                  ),
              ],
            );
          }
          
          return const Center(child: Text('Error loading driver data'));
        },
      ),
    );
  }

  Widget _buildRideRequestCard(BuildContext context, RideRequest request) {
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
                    onPressed: () {
                      context.read<DriverBloc>().add(RejectRide(request.id));
                    },
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
                    onPressed: () {
                      context.read<DriverBloc>().add(AcceptRide(request.id));
                    },
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

  Widget _buildRideControlCard(BuildContext context, CurrentRide ride) {
    return Card(
      color: Colors.black,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.yellow,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.riderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ride.pickupAddress,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (ride.status == 'accepted')
              AppButton(
                text: 'Arrived at Pickup',
                onPressed: () {
                  context.read<DriverBloc>().add(ArrivedAtPickup(ride.id));
                },
              ),
            if (ride.status == 'arrived')
              AppButton(
                text: 'Start Trip',
                onPressed: () {
                  context.read<DriverBloc>().add(StartTrip(ride.id));
                },
              ),
            if (ride.status == 'in_progress')
              AppButton(
                text: 'Complete Trip',
                onPressed: () {
                  context.read<DriverBloc>().add(CompleteTrip(ride.id));
                },
              ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Cancel Trip',
              onPressed: () {
                context.read<DriverBloc>().add(CancelTrip(ride.id));
              },
              color: Colors.red,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}