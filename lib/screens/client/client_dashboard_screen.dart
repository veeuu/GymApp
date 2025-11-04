import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/client_auth_service.dart';
import '../../services/client_daily_log_service.dart';
import '../../services/workout_plan_service.dart';
import '../../services/diet_plan_service.dart';
import '../../services/debug_service.dart';
import '../../models/client_daily_log.dart';

import 'client_workout_screen.dart';
import 'client_nutrition_screen.dart';
import 'client_progress_screen.dart';
import 'client_workout_detail_screen.dart';
import 'client_diet_detail_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ClientHomeScreen(),
    const ClientWorkoutScreen(),
    const ClientNutritionScreen(),
    const ClientProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final ClientDailyLogService _dailyLogService = ClientDailyLogService();
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  final DietPlanService _dietPlanService = DietPlanService();
  
  ClientDailyLog? _todayLog;
  List<Map<String, dynamic>> _workoutAssignments = [];
  List<Map<String, dynamic>> _dietAssignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = Provider.of<ClientAuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    setState(() => _isLoading = true);
    
    try {
      final clientId = authService.client!.id;
      final clientEmail = authService.client!.email;
      
      print('DEBUG: Loading data for client ID: $clientId');
      print('DEBUG: Client email: $clientEmail');
      
      // Debug all client data
      await DebugService.debugClientData(clientEmail ?? '');
      
      final todayLog = await _dailyLogService.getTodayLog(clientId);
      final workoutAssignments = await _workoutPlanService.getClientAssignments(clientId);
      final dietAssignments = await _dietPlanService.getClientDietAssignments(clientId);
      
      print('DEBUG: Found ${workoutAssignments.length} workout assignments');
      print('DEBUG: Found ${dietAssignments.length} diet assignments');
      
      setState(() {
        _todayLog = todayLog;
        _workoutAssignments = workoutAssignments;
        _dietAssignments = dietAssignments;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateWaterIntake() async {
    final authService = Provider.of<ClientAuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    final controller = TextEditingController(
      text: (_todayLog?.waterIntake ?? 0).toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Water Intake'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Water (ml)',
            suffixText: 'ml',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final water = int.tryParse(controller.text) ?? 0;
              Navigator.pop(context, water);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _dailyLogService.updateWaterIntake(authService.client!.id, result);
      _loadData();
    }
  }

  Future<void> _updateSteps() async {
    final authService = Provider.of<ClientAuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    final controller = TextEditingController(
      text: (_todayLog?.steps ?? 0).toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Steps'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Steps',
            suffixText: 'steps',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(controller.text) ?? 0;
              Navigator.pop(context, steps);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _dailyLogService.updateSteps(authService.client!.id, result);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<ClientAuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${authService.client?.name ?? 'Client'}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authService.clientLogout();
              } else if (value == 'refresh') {
                _loadData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today - ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickStatCard(
                                    title: 'Water',
                                    value: '${_todayLog?.waterIntake ?? 0} ml',
                                    icon: Icons.water_drop,
                                    color: Colors.blue,
                                    onTap: _updateWaterIntake,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _QuickStatCard(
                                    title: 'Steps',
                                    value: '${_todayLog?.steps ?? 0}',
                                    icon: Icons.directions_walk,
                                    color: Colors.orange,
                                    onTap: _updateSteps,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickStatCard(
                                    title: 'Workouts',
                                    value: '${_todayLog?.completedExercises.length ?? 0}',
                                    icon: Icons.fitness_center,
                                    color: Colors.green,
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _QuickStatCard(
                                    title: 'Meals',
                                    value: '${_todayLog?.consumedMeals.length ?? 0}',
                                    icon: Icons.restaurant,
                                    color: Colors.purple,
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Assigned Plans
                    const Text(
                      'Your Plans',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    if (_workoutAssignments.isEmpty && _dietAssignments.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No plans assigned yet. Your trainer will assign workout and diet plans for you.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else ...[
                      if (_workoutAssignments.isNotEmpty)
                        ..._workoutAssignments.map((assignment) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.fitness_center, color: Colors.green),
                              title: const Text('Workout Plan Assigned'),
                              subtitle: Text('Assigned: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(assignment['createdAt']))}'),
                              trailing: Chip(
                                label: Text(assignment['status'] ?? 'active'),
                                backgroundColor: Colors.green.withOpacity(0.2),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClientWorkoutDetailScreen(
                                      assignment: assignment,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      
                      if (_dietAssignments.isNotEmpty)
                        ..._dietAssignments.map((assignment) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.restaurant, color: Colors.purple),
                              title: const Text('Diet Plan Assigned'),
                              subtitle: Text('Assigned: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(assignment['createdAt']))}'),
                              trailing: Chip(
                                label: Text(assignment['status'] ?? 'active'),
                                backgroundColor: Colors.purple.withOpacity(0.2),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClientDietDetailScreen(
                                      assignment: assignment,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2,
                      children: [
                        _ActionButton(
                          icon: Icons.fitness_center,
                          label: 'Log Workout',
                          color: Colors.green,
                          onPressed: () {
                            // Navigate to workout logging
                          },
                        ),
                        _ActionButton(
                          icon: Icons.restaurant,
                          label: 'Log Meal',
                          color: Colors.purple,
                          onPressed: () {
                            // Navigate to meal logging
                          },
                        ),
                        _ActionButton(
                          icon: Icons.monitor_weight,
                          label: 'Log Weight',
                          color: Colors.blue,
                          onPressed: () {
                            // Navigate to weight logging
                          },
                        ),
                        _ActionButton(
                          icon: Icons.trending_up,
                          label: 'View Progress',
                          color: Colors.orange,
                          onPressed: () {
                            // Navigate to progress screen
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}