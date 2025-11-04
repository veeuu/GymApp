import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
import '../../models/exercise.dart';
import '../../models/diet_plan.dart';
import '../../models/client_daily_log.dart';
import '../../services/local_client_service.dart';
import '../../services/workout_plan_service.dart';
import '../../services/diet_plan_service.dart';
import '../../services/client_daily_log_service.dart';
import 'add_edit_client_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final LocalClientService _clientService = LocalClientService();

  Future<void> _deleteClient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete ${widget.client.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _clientService.deleteClient(widget.client.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Client deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting client: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditClientScreen(client: widget.client),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteClient,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: const TabBar(
                tabs: [
                  Tab(text: 'Overview', icon: Icon(Icons.person)),
                  Tab(text: 'Plans', icon: Icon(Icons.assignment)),
                  Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(client: widget.client),
                  _PlansTab(client: widget.client),
                  _ProgressTab(client: widget.client),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Client client;

  const _OverviewTab({required this.client});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            client.goal,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoRow(icon: Icons.phone, label: 'Phone', value: client.phone),
                if (client.email != null)
                  _InfoRow(icon: Icons.email, label: 'Email', value: client.email!),
                _InfoRow(
                  icon: client.gender == 'Male' ? Icons.male : Icons.female,
                  label: 'Gender',
                  value: client.gender,
                ),
                if (client.dob != null)
                  _InfoRow(
                    icon: Icons.cake,
                    label: 'Date of Birth',
                    value: DateFormat('MMM dd, yyyy').format(client.dob!),
                  ),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Joined',
                  value: DateFormat('MMM dd, yyyy').format(client.createdAt),
                ),
                _InfoRow(
                  icon: Icons.update,
                  label: 'Last Updated',
                  value: DateFormat('MMM dd, yyyy').format(client.lastUpdated),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansTab extends StatefulWidget {
  final Client client;

  const _PlansTab({required this.client});

  @override
  State<_PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends State<_PlansTab> {
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  final DietPlanService _dietPlanService = DietPlanService();
  List<Map<String, dynamic>> _workoutAssignments = [];
  List<Map<String, dynamic>> _dietAssignments = [];
  List<WorkoutPlan> _availableWorkoutPlans = [];
  List<DietPlan> _availableDietPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);
    try {
      final workoutAssignments = await _workoutPlanService.getClientAssignments(widget.client.id);
      final dietAssignments = await _dietPlanService.getClientDietAssignments(widget.client.id);
      final availableWorkoutPlans = await _workoutPlanService.getWorkoutPlans();
      final availableDietPlans = await _dietPlanService.getDietPlans();
      
      setState(() {
        _workoutAssignments = workoutAssignments;
        _dietAssignments = dietAssignments;
        _availableWorkoutPlans = availableWorkoutPlans;
        _availableDietPlans = availableDietPlans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignWorkoutPlan() async {
    if (_availableWorkoutPlans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No workout plans available. Create one first.')),
      );
      return;
    }

    final selectedPlan = await showDialog<WorkoutPlan>(
      context: context,
      builder: (context) => _PlanSelectionDialog<WorkoutPlan>(
        title: 'Select Workout Plan',
        plans: _availableWorkoutPlans,
        planName: (plan) => plan.name,
        planSubtitle: (plan) => '${plan.difficulty} • ${plan.days.length} days',
      ),
    );

    if (selectedPlan != null) {
      try {
        await _workoutPlanService.assignPlanToClient(
          widget.client.id,
          selectedPlan.id,
          DateTime.now(),
          null,
        );
        _loadAssignments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout plan assigned successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error assigning plan: $e')),
          );
        }
      }
    }
  }

  Future<void> _assignDietPlan() async {
    if (_availableDietPlans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No diet plans available. Create one first.')),
      );
      return;
    }

    final selectedPlan = await showDialog<DietPlan>(
      context: context,
      builder: (context) => _PlanSelectionDialog<DietPlan>(
        title: 'Select Diet Plan',
        plans: _availableDietPlans,
        planName: (plan) => plan.name,
        planSubtitle: (plan) => '${plan.goal} • ${plan.totalCalories} kcal',
      ),
    );

    if (selectedPlan != null) {
      try {
        await _dietPlanService.assignDietPlanToClient(
          widget.client.id,
          selectedPlan.id,
          DateTime.now(),
          null,
        );
        _loadAssignments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Diet plan assigned successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error assigning plan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _assignWorkoutPlan,
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Assign Workout'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _assignDietPlan,
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Assign Diet Plan'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Workout Plans
          const Text(
            'Assigned Workout Plans',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          if (_workoutAssignments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No workout plans assigned'),
              ),
            )
          else
            ..._workoutAssignments.map((assignment) {
              // Find the actual plan details
              final planId = assignment['planId'];
              final plan = _availableWorkoutPlans.firstWhere(
                (p) => p.id == planId,
                orElse: () => WorkoutPlan(
                  id: planId,
                  name: 'Unknown Plan',
                  description: '',
                  difficulty: 'Unknown',
                  days: [],
                  createdBy: '',
                  createdAt: DateTime.now(),
                ),
              );
              
              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.orange),
                  title: Text(plan.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Difficulty: ${plan.difficulty}'),
                      Text('Days: ${plan.days.length}'),
                      Text('Assigned: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(assignment['createdAt']))}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(assignment['status']),
                    backgroundColor: Colors.green.withOpacity(0.2),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (plan.description.isNotEmpty) ...[
                            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(plan.description),
                            const SizedBox(height: 8),
                          ],
                          const Text('Workout Days:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...plan.days.asMap().entries.map((entry) {
                            final index = entry.key;
                            final day = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('Day ${index + 1}: ${day.name} (${day.exercises.length} exercises)'),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          
          const SizedBox(height: 24),
          
          // Diet Plans
          const Text(
            'Assigned Diet Plans',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          if (_dietAssignments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No diet plans assigned'),
              ),
            )
          else
            ..._dietAssignments.map((assignment) {
              // Find the actual plan details
              final planId = assignment['planId'];
              final plan = _availableDietPlans.firstWhere(
                (p) => p.id == planId,
                orElse: () => DietPlan(
                  id: planId,
                  name: 'Unknown Plan',
                  description: '',
                  goal: 'Unknown',
                  totalCalories: 0,
                  meals: [],
                  createdBy: '',
                  createdAt: DateTime.now(),
                ),
              );
              
              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.restaurant, color: Colors.purple),
                  title: Text(plan.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Goal: ${plan.goal}'),
                      Text('Calories: ${plan.totalCalories} kcal'),
                      Text('Assigned: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(assignment['createdAt']))}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(assignment['status']),
                    backgroundColor: Colors.purple.withOpacity(0.2),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (plan.description.isNotEmpty) ...[
                            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(plan.description),
                            const SizedBox(height: 8),
                          ],
                          const Text('Meals:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...plan.meals.map((meal) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('${meal.name} (${meal.time}) - ${meal.calories} kcal'),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

class _PlanSelectionDialog<T> extends StatelessWidget {
  final String title;
  final List<T> plans;
  final String Function(T) planName;
  final String Function(T) planSubtitle;

  const _PlanSelectionDialog({
    required this.title,
    required this.plans,
    required this.planName,
    required this.planSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return ListTile(
              title: Text(planName(plan)),
              subtitle: Text(planSubtitle(plan)),
              onTap: () => Navigator.pop(context, plan),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _ProgressTab extends StatefulWidget {
  final Client client;

  const _ProgressTab({required this.client});

  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  List<ClientDailyLog> _weeklyLogs = [];
  ClientDailyLog? _todayLog;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    try {
      final dailyLogService = ClientDailyLogService();
      final weeklyLogs = await dailyLogService.getWeeklyLogs(widget.client.id);
      final todayLog = await dailyLogService.getTodayLog(widget.client.id);
      
      setState(() {
        _weeklyLogs = weeklyLogs;
        _todayLog = todayLog;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadProgress,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Summary
            if (_todayLog != null) ...[
              const Text(
                'Today\'s Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ProgressStatCard(
                              title: 'Water',
                              value: '${_todayLog!.waterIntake} ml',
                              icon: Icons.water_drop,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ProgressStatCard(
                              title: 'Steps',
                              value: '${_todayLog!.steps}',
                              icon: Icons.directions_walk,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ProgressStatCard(
                              title: 'Workouts',
                              value: '${_todayLog!.completedExercises.length}',
                              icon: Icons.fitness_center,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ProgressStatCard(
                              title: 'Meals',
                              value: '${_todayLog!.consumedMeals.length}',
                              icon: Icons.restaurant,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Weekly Progress
            const Text(
              'Weekly Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            if (_weeklyLogs.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No progress data recorded yet. Client needs to start logging their daily activities.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _weeklyLogs.length,
                  itemBuilder: (context, index) {
                    final log = _weeklyLogs[index];
                    return Card(
                      child: ExpansionTile(
                        title: Text(DateFormat('MMM dd, yyyy').format(log.date)),
                        subtitle: Text(
                          'Water: ${log.waterIntake}ml • Steps: ${log.steps} • Workouts: ${log.completedExercises.length}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (log.completedExercises.isNotEmpty) ...[
                                  const Text('Completed Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ...log.completedExercises.map((exercise) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16, top: 4),
                                      child: Text('• ${exercise.exerciseName} - ${exercise.setsCompleted} sets × ${exercise.repsCompleted} reps'),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 8),
                                ],
                                if (log.consumedMeals.isNotEmpty) ...[
                                  const Text('Meals Consumed:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ...log.consumedMeals.map((meal) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16, top: 4),
                                      child: Text('• ${meal.mealName} - ${meal.totalCalories} kcal'),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 8),
                                ],
                                if (log.weight != null) ...[
                                  Text('Weight: ${log.weight} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                ],
                                if (log.notes != null && log.notes!.isNotEmpty) ...[
                                  const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(log.notes!),
                                ],
                              ],
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

class _ProgressStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProgressStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}