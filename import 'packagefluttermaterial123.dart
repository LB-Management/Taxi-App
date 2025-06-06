import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/src/blocs/ride/ride_bloc.dart';
import 'package:rider_app/src/widgets/ride_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RideBloc>().add(LoadUserLocation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yellow & Black Taxi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: BlocBuilder<RideBloc, RideState>(
        builder: (context, state) {
          if (state is RideInitial || state is RideLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RideLocationLoaded) {
            return RideMap(
              currentLocation: state.currentLocation,
              pickupLocation: state.pickupLocation,
              dropoffLocation: state.dropoffLocation,
              driverLocation: state.driverLocation,
              polylinePoints: state.polylinePoints,
            );
          }
          if (state is RideRequested) {
            return Stack(
              children: [
                RideMap(
                  currentLocation: state.currentLocation,
                  pickupLocation: state.pickupLocation,
                  dropoffLocation: state.dropoffLocation,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildRideRequestCard(context),
                ),
              ],
            );
          }
          if (state is RideAccepted) {
            return Stack(
              children: [
                RideMap(
                  currentLocation: state.currentLocation,
                  pickupLocation: state.pickupLocation,
                  dropoffLocation: state.dropoffLocation,
                  driverLocation: state.driverLocation,
                  polylinePoints: state.polylinePoints,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildDriverInfoCard(context, state),
                ),
              ],
            );
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: () {
          context.read<RideBloc>().add(RequestRide());
        },
        child: const Icon(Icons.directions_car, color: Colors.black),
      ),
    );
  }

  Widget _buildRideRequestCard(BuildContext context) {
    return Card(
      color: Colors.black,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Looking for drivers...',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              color: Colors.yellow,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Cancel Ride',
              onPressed: () {
                context.read<RideBloc>().add(CancelRide());
              },
              color: Colors.red,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard(BuildContext context, RideAccepted state) {
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
                      state.driverName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      state.vehicleNumber,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      'ETA: ${state.eta} min',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${state.distance} km away',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Call Driver',
                    onPressed: () {
                      // Implement call functionality
                    },
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'Cancel Ride',
                    onPressed: () {
                      context.read<RideBloc>().add(CancelRide());
                    },
                    color: Colors.red,
                    textColor: Colors.white,
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