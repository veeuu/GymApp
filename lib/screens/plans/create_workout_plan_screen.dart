import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../services/exercise_service.dart';
import '../../services/workout_plan_service.dart';
import '../../services/local_auth_service.dart';

class CreateWorkoutPlanScreen extends StatefulWidget {
  const CreateWorkoutPlanScreen({super.key});

  @override
  State<CreateWorkoutPlanScreen> createState() => _CreateWorkoutPlanScreenState();
}

class _CreateWorkoutPlanScreenState extends State<CreateWorkoutPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedDifficulty = 'Beginner';
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];
  
  List<WorkoutDay> _workoutDays = [];
  final ExerciseService _exerciseService = ExerciseService();
  final WorkoutPlanService _workoutPlanService = WorkoutPlanService();
  List<Exercise> _availableExercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _addWorkoutDay();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final exercises = await _exerciseService.getAllExercises();
    setState(() => _availableExercises = exercises);
  }

  void _addWorkoutDay() {
    setState(() {
      _workoutDays.add(WorkoutDay(
        name: 'Day ${_workoutDays.length + 1}',
        exercises: [],
      ));
    });
  }

  void _removeWorkoutDay(int index) {
    if (_workoutDays.length > 1) {
      setState(() => _workoutDays.removeAt(index));
    }
  }

  void _addExerciseToDay(int dayIndex) {
    showDialog(
      context: context,
      builder: (context) => _ExerciseSelectionDialog(
        exercises: _availableExercises,
        onExerciseSelected: (exercise) {
          showDialog(
            context: context,
            builder: (context) => _ExerciseDetailsDialog(
              exercise: exercise,
              onSave: (workoutExercise) {
                setState(() {
                  _workoutDays[dayIndex].exercises.add(workoutExercise);
                });
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveWorkoutPlan() async {
    if (!_formKey.currentState!.validate() || _workoutDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and add at least one exercise')),
      );
      return;
    }

    final authService = Provider.of<LocalAuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final workoutPlan = WorkoutPlan(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        difficulty: _selectedDifficulty,
        days: _workoutDays,
        createdBy: authService.trainer!.uid,
        createdAt: DateTime.now(),
      );

      await _workoutPlanService.saveWorkoutPlan(workoutPlan);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout plan created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating workout plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout Plan'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveWorkoutPlan,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Name *',
                        hintText: 'e.g., Upper Body Strength',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a plan name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Brief description of the workout plan',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      decoration: const InputDecoration(labelText: 'Difficulty Level'),
                      items: _difficulties.map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedDifficulty = value!),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Workout Days
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Workout Days',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addWorkoutDay,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Day'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ..._workoutDays.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    day.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _addExerciseToDay(index),
                                        icon: const Icon(Icons.add_circle),
                                        color: Colors.green,
                                      ),
                                      if (_workoutDays.length > 1)
                                        IconButton(
                                          onPressed: () => _removeWorkoutDay(index),
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              if (day.exercises.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'No exercises added yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                ...day.exercises.map((exercise) {
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.fitness_center),
                                    title: Text(exercise.exerciseName),
                                    subtitle: Text(
                                      '${exercise.sets} sets × ${exercise.reps} reps'
                                      '${exercise.weight != null ? ' @ ${exercise.weight}kg' : ''}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          day.exercises.remove(exercise);
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSelectionDialog extends StatefulWidget {
  final List<Exercise> exercises;
  final Function(Exercise) onExerciseSelected;

  const _ExerciseSelectionDialog({
    required this.exercises,
    required this.onExerciseSelected,
  });

  @override
  State<_ExerciseSelectionDialog> createState() => _ExerciseSelectionDialogState();
}

class _ExerciseSelectionDialogState extends State<_ExerciseSelectionDialog> {
  String _searchQuery = '';

  List<Exercise> get _filteredExercises {
    if (_searchQuery.isEmpty) return widget.exercises;
    return widget.exercises.where((exercise) =>
      exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      exercise.muscleGroup.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Select Exercise',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  return ListTile(
                    title: Text(exercise.name),
                    subtitle: Text('${exercise.category} • ${exercise.muscleGroup}'),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onExerciseSelected(exercise);
                    },
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

class _ExerciseDetailsDialog extends StatefulWidget {
  final Exercise exercise;
  final Function(WorkoutExercise) onSave;

  const _ExerciseDetailsDialog({
    required this.exercise,
    required this.onSave,
  });

  @override
  State<_ExerciseDetailsDialog> createState() => _ExerciseDetailsDialogState();
}

class _ExerciseDetailsDialogState extends State<_ExerciseDetailsDialog> {
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _weightController = TextEditingController();
  final _restController = TextEditingController(text: '60');

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.exercise.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setsController,
                  decoration: const InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _repsController,
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!widget.exercise.isCardio) ...[
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'Optional',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _restController,
            decoration: const InputDecoration(labelText: 'Rest Time (seconds)'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final workoutExercise = WorkoutExercise(
              exerciseId: widget.exercise.id,
              exerciseName: widget.exercise.name,
              sets: int.tryParse(_setsController.text) ?? 3,
              reps: int.tryParse(_repsController.text) ?? 10,
              weight: _weightController.text.isNotEmpty 
                  ? double.tryParse(_weightController.text) 
                  : null,
              restTime: int.tryParse(_restController.text) ?? 60,
            );
            
            Navigator.pop(context);
            widget.onSave(workoutExercise);
          },
          child: const Text('Add Exercise'),
        ),
      ],
    );
  }
}