import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/exercise.dart';
import '../../services/workout_plan_service.dart';
import 'create_workout_plan_screen.dart';

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  List<WorkoutPlan> _workoutPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlans();
  }

  Future<void> _loadWorkoutPlans() async {
    setState(() => _isLoading = true);
    try {
      final plans = await _workoutPlanService.getWorkoutPlans();
      setState(() {
        _workoutPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading workout plans: $e')),
        );
      }
    }
  }

  Future<void> _deleteWorkoutPlan(WorkoutPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout Plan'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
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
        await _workoutPlanService.deleteWorkoutPlan(plan.id);
        _loadWorkoutPlans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout plan deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting workout plan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plans'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkoutPlans,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workoutPlans.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No workout plans created yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first workout plan to get started',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWorkoutPlans,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _workoutPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _workoutPlans[index];
                      return WorkoutPlanCard(
                        plan: plan,
                        onDelete: () => _deleteWorkoutPlan(plan),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateWorkoutPlanScreen()),
          );
          _loadWorkoutPlans();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Workout Plan'),
      ),
    );
  }
}

class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onDelete;

  const WorkoutPlanCard({
    super.key,
    required this.plan,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColor(plan.difficulty),
          child: const Icon(Icons.fitness_center, color: Colors.white),
        ),
        title: Text(
          plan.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Difficulty: ${plan.difficulty}'),
            Text('Days: ${plan.days.length}'),
            Text('Created: ${DateFormat('MMM dd, yyyy').format(plan.createdAt)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.description.isNotEmpty) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(plan.description),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Workout Days:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...plan.days.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${index + 1}: ${day.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (day.exercises.isEmpty)
                          const Text(
                            'No exercises added',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          ...day.exercises.map((exercise) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 16, top: 2),
                              child: Text(
                                '• ${exercise.exerciseName} - ${exercise.sets} sets × ${exercise.reps} reps'
                                '${exercise.weight != null ? ' @ ${exercise.weight}kg' : ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                        if (day.notes != null && day.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Notes: ${day.notes}',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}