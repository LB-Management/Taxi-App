import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:admin_panel/src/blocs/dashboard/dashboard_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(Logout());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is DashboardLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatsRow(context, state),
                  const SizedBox(height: 20),
                  _buildChartsRow(context, state),
                  const SizedBox(height: 20),
                  _buildRecentRidesTable(context, state),
                ],
              ),
            );
          }
          
          return const Center(child: Text('Error loading dashboard'));
        },
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, DashboardLoaded state) {
    return Row(
      children: [
        _buildStatCard(
          context,
          title: 'Total Rides',
          value: state.stats.totalRides.toString(),
          icon: Icons.directions_car,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          context,
          title: 'Active Drivers',
          value: state.stats.activeDrivers.toString(),
          icon: Icons.people,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          context,
          title: 'Total Revenue',
          value: '\$${state.stats.totalRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          context,
          title: 'New Users',
          value: state.stats.newUsers.toString(),
          icon: Icons.person_add,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.yellow),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsRow(BuildContext context, DashboardLoaded state) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Card(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rides Per Day',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: CategoryAxis(
                        labelStyle: const TextStyle(color: Colors.white70),
                        majorGridLines: const MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: const TextStyle(color: Colors.white70),
                        majorGridLines: const MajorGridLines(width: 0),
                      ),
                      series: <ColumnSeries<RideData, String>>[
                        ColumnSeries<RideData, String>(
                          dataSource: state.rideData,
                          xValueMapper: (RideData data, _) => data.day,
                          yValueMapper: (RideData data, _) => data.count,
                          color: Colors.yellow,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Card(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue Sources',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: SfCircularChart(
                      series: <PieSeries<RevenueData, String>>[
                        PieSeries<RevenueData, String>(
                          dataSource: state.revenueData,
                          xValueMapper: (RevenueData data, _) => data.source,
                          yValueMapper: (RevenueData data, _) => data.amount,
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          pointColorMapper: (RevenueData data, _) {
                            if (data.source == 'Standard') return Colors.yellow;
                            if (data.source == 'Premium') return Colors.yellow[700];
                            return Colors.yellow[900];
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRidesTable(BuildContext context, DashboardLoaded state) {
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Rides',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: state.recentRides.length,
                itemBuilder: (context, index) {
                  final ride = state.recentRides[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.yellow,
                      child: Text(
                        ride.id.substring(0, 2),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    title: Text(
                      'Ride #${ride.id.substring(0, 8)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${ride.riderName} → ${ride.driverName}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${ride.fare.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ride.status,
                          style: TextStyle(
                            color: ride.status == 'completed'
                                ? Colors.green
                                : ride.status == 'cancelled'
                                    ? Colors.red
                                    : Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}