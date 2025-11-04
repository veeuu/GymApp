import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/client_auth_service.dart';
import '../../services/workout_plan_service.dart';
import 'client_workout_detail_screen.dart';

class ClientWorkoutScreen extends StatefulWidget {
  const ClientWorkoutScreen({super.key});

  @override
  State<ClientWorkoutScreen> createState() => _ClientWorkoutScreenState();
}

class _ClientWorkoutScreenState extends State<ClientWorkoutScreen> {
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  List<Map<String, dynamic>> _workoutAssignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutAssignments();
  }

  Future<void> _loadWorkoutAssignments() async {
    final authService = Provider.of<ClientAuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    setState(() => _isLoading = true);
    
    try {
      final clientId = authService.client!.id;
      final assignments = await _workoutPlanService.getClientAssignments(clientId);
      
      setState(() {
        _workoutAssignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workout assignments: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadWorkoutAssignments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workoutAssignments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No workout plans assigned yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your trainer will assign workout plans for you',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWorkoutAssignments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _workoutAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = _workoutAssignments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.fitness_center, color: Colors.white),
                          ),
                          title: const Text(
                            'Workout Plan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigned: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(assignment['createdAt']))}',
                              ),
                              const SizedBox(height: 4),
                              if (assignment['startDate'] != null)
                                Text(
                                  'Start: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(assignment['startDate']))}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Chip(
                                label: Text(assignment['status'] ?? 'active'),
                                backgroundColor: Colors.green.withOpacity(0.2),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
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
                    },
                  ),
                ),
    );
  }
}