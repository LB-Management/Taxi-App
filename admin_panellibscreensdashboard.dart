// admin_panel/lib/screens/dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Cards
            Row(
              children: [
                _buildSummaryCard(
                  context,
                  title: 'Total Rides',
                  value: adminProvider.stats.totalRides.toString(),
                  icon: Icons.directions_car,
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  context,
                  title: 'Active Drivers',
                  value: adminProvider.stats.activeDrivers.toString(),
                  icon: Icons.people,
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  context,
                  title: 'Revenue',
                  value: '\$${adminProvider.stats.revenue.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Tabs for different sections
            DefaultTabController(
              length: 3,
              child: Expanded(
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Rides'),
                        Tab(text: 'Drivers'),
                        Tab(text: 'Users'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Rides Tab
                          ListView.builder(
                            itemCount: adminProvider.rides.length,
                            itemBuilder: (context, index) {
                              final ride = adminProvider.rides[index];
                              return ListTile(
                                title: Text('Ride #${ride.id}'),
                                subtitle: Text('${ride.status} - \$${ride.fare}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // Navigate to ride details
                                },
                              );
                            },
                          ),
                          // Drivers Tab
                          ListView.builder(
                            itemCount: adminProvider.drivers.length,
                            itemBuilder: (context, index) {
                              final driver = adminProvider.drivers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: driver.isApproved 
                                      ? Colors.green 
                                      : Colors.orange,
                                  child: Text(driver.name[0]),
                                ),
                                title: Text(driver.name),
                                subtitle: Text(driver.vehicleNumber),
                                trailing: Switch(
                                  value: driver.isApproved,
                                  onChanged: (value) {
                                    adminProvider.updateDriverApproval(
                                      driver.id, 
                                      value,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          // Users Tab
                          ListView.builder(
                            itemCount: adminProvider.users.length,
                            itemBuilder: (context, index) {
                              final user = adminProvider.users[index];
                              return ListTile(
                                title: Text(user.email),
                                subtitle: Text(user.role),
                                trailing: IconButton(
                                  icon: const Icon(Icons.warning),
                                  color: Colors.red,
                                  onPressed: () {
                                    // Suspend user
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
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
              Icon(icon, color: Colors.yellow),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.yellow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}