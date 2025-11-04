import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/exercise.dart';
import '../../services/workout_plan_service.dart';
import '../../services/client_daily_log_service.dart';
import '../../services/client_auth_service.dart';
import 'package:provider/provider.dart';

class ClientWorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> assignment;

  const ClientWorkoutDetailScreen({
    super.key,
    required this.assignment,
  });

  @override
  State<ClientWorkoutDetailScreen> createState() => _ClientWorkoutDetailScreenState();
}

class _ClientWorkoutDetailScreenState extends State<ClientWorkoutDetailScreen> {
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  final ClientDailyLogService _dailyLogService = ClientDailyLogService();
  
  WorkoutPlan? _workoutPlan;
  bool _isLoading = true;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
  }

  Future<void> _loadWorkoutPlan() async {
    setState(() => _isLoading = true);
    
    try {
      final planId = widget.assignment['planId'];
      final plan = await _workoutPlanService.getWorkoutPlanFromAnyTrainer(planId);
      
      setState(() {
        _workoutPlan = plan;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workout plan: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markExerciseComplete(WorkoutExercise exercise) async {
    final authService = Provider.of<ClientAuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    try {
      await _dailyLogService.logExercise(
        authService.client!.id,
        exercise.exerciseId,
        exercise.exerciseName,
        exercise.sets,
        exercise.reps,
        exercise.weight,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exercise.exerciseName} completed!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging exercise: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_workoutPlan?.name ?? 'Workout Plan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workoutPlan == null
              ? const Center(
                  child: Text(
                    'Workout plan not found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    // Plan Info Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.green.withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _workoutPlan!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _workoutPlan!.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text(_workoutPlan!.difficulty),
                                backgroundColor: _getDifficultyColor(_workoutPlan!.difficulty),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text('${_workoutPlan!.days.length} Days'),
                                backgroundColor: Colors.blue.withOpacity(0.2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Assigned: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(widget.assignment['createdAt']))}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Day Tabs
                    if (_workoutPlan!.days.isNotEmpty)
                      Container(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _workoutPlan!.days.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == _selectedDayIndex;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedDayIndex = index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.green : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _workoutPlan!.days[index].name,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    // Exercises List
                    Expanded(
                      child: _workoutPlan!.days.isEmpty
                          ? const Center(
                              child: Text('No workout days available'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _workoutPlan!.days[_selectedDayIndex].exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = _workoutPlan!.days[_selectedDayIndex].exercises[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                exercise.exerciseName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _markExerciseComplete(exercise),
                                              icon: const Icon(Icons.check_circle_outline),
                                              color: Colors.green,
                                              tooltip: 'Mark as completed',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _ExerciseDetailChip(
                                              icon: Icons.repeat,
                                              label: '${exercise.sets} sets',
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 8),
                                            _ExerciseDetailChip(
                                              icon: Icons.fitness_center,
                                              label: '${exercise.reps} reps',
                                              color: Colors.orange,
                                            ),
                                            if (exercise.weight != null) ...[
                                              const SizedBox(width: 8),
                                              _ExerciseDetailChip(
                                                icon: Icons.monitor_weight,
                                                label: '${exercise.weight}kg',
                                                color: Colors.purple,
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (exercise.restTime != null) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.timer, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Rest: ${exercise.restTime! ~/ 60}:${(exercise.restTime! % 60).toString().padLeft(2, '0')}',
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              exercise.notes!,
                                              style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green.withOpacity(0.2);
      case 'intermediate':
        return Colors.orange.withOpacity(0.2);
      case 'advanced':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}

class _ExerciseDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ExerciseDetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}