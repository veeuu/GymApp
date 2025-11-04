import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/exercise.dart';

class ExerciseService {
  static const List<Map<String, dynamic>> _defaultExercises = [
    {
      'name': 'Push-ups',
      'category': 'Strength',
      'muscleGroup': 'Chest, Triceps, Shoulders',
      'equipment': 'Bodyweight',
      'instructions': 'Start in plank position, lower body until chest nearly touches floor, push back up.',
      'isCardio': false,
    },
    {
      'name': 'Squats',
      'category': 'Strength',
      'muscleGroup': 'Legs, Glutes',
      'equipment': 'Bodyweight',
      'instructions': 'Stand with feet shoulder-width apart, lower body as if sitting back into chair, return to standing.',
      'isCardio': false,
    },
    {
      'name': 'Plank',
      'category': 'Core',
      'muscleGroup': 'Core, Shoulders',
      'equipment': 'Bodyweight',
      'instructions': 'Hold body in straight line from head to heels, engage core muscles.',
      'isCardio': false,
    },
    {
      'name': 'Burpees',
      'category': 'Cardio',
      'muscleGroup': 'Full Body',
      'equipment': 'Bodyweight',
      'instructions': 'Squat down, jump back to plank, do push-up, jump feet to hands, jump up with arms overhead.',
      'isCardio': true,
    },
    {
      'name': 'Lunges',
      'category': 'Strength',
      'muscleGroup': 'Legs, Glutes',
      'equipment': 'Bodyweight',
      'instructions': 'Step forward into lunge position, lower back knee toward ground, return to standing.',
      'isCardio': false,
    },
    {
      'name': 'Mountain Climbers',
      'category': 'Cardio',
      'muscleGroup': 'Core, Cardio',
      'equipment': 'Bodyweight',
      'instructions': 'Start in plank position, alternate bringing knees to chest in running motion.',
      'isCardio': true,
    },
    {
      'name': 'Deadlifts',
      'category': 'Strength',
      'muscleGroup': 'Back, Legs, Glutes',
      'equipment': 'Barbell/Dumbbells',
      'instructions': 'Stand with feet hip-width apart, hinge at hips to lower weight, return to standing.',
      'isCardio': false,
    },
    {
      'name': 'Bench Press',
      'category': 'Strength',
      'muscleGroup': 'Chest, Triceps, Shoulders',
      'equipment': 'Barbell/Dumbbells',
      'instructions': 'Lie on bench, lower weight to chest, press back up to starting position.',
      'isCardio': false,
    },
    {
      'name': 'Pull-ups',
      'category': 'Strength',
      'muscleGroup': 'Back, Biceps',
      'equipment': 'Pull-up Bar',
      'instructions': 'Hang from bar with overhand grip, pull body up until chin clears bar, lower with control.',
      'isCardio': false,
    },
    {
      'name': 'Jumping Jacks',
      'category': 'Cardio',
      'muscleGroup': 'Full Body',
      'equipment': 'Bodyweight',
      'instructions': 'Jump feet apart while raising arms overhead, jump back to starting position.',
      'isCardio': true,
    },
  ];

  Future<void> _initializeDefaultExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesInitialized = prefs.getBool('exercises_initialized') ?? false;
    
    if (!exercisesInitialized) {
      final exercisesJson = prefs.getStringList('exercises') ?? [];
      
      for (int i = 0; i < _defaultExercises.length; i++) {
        final exercise = Map<String, dynamic>.from(_defaultExercises[i]);
        exercise['id'] = 'default_$i';
        exercisesJson.add(json.encode(exercise));
      }
      
      await prefs.setStringList('exercises', exercisesJson);
      await prefs.setBool('exercises_initialized', true);
    }
  }

  Future<List<Exercise>> getAllExercises() async {
    await _initializeDefaultExercises();
    
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = prefs.getStringList('exercises') ?? [];
    
    return exercisesJson.map((json) {
      final map = jsonDecode(json);
      return Exercise.fromMap(map, map['id']);
    }).toList();
  }

  Future<List<Exercise>> getExercisesByCategory(String category) async {
    final exercises = await getAllExercises();
    return exercises.where((exercise) => exercise.category == category).toList();
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    final exercises = await getAllExercises();
    return exercises.where((exercise) => 
      exercise.muscleGroup.toLowerCase().contains(muscleGroup.toLowerCase())
    ).toList();
  }

  Future<void> addCustomExercise(Exercise exercise) async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = prefs.getStringList('exercises') ?? [];
    
    exercisesJson.add(json.encode(exercise.toMap()..['id'] = exercise.id));
    await prefs.setStringList('exercises', exercisesJson);
  }

  Future<Exercise?> getExerciseById(String id) async {
    final exercises = await getAllExercises();
    try {
      return exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  List<String> getCategories() {
    return ['Strength', 'Cardio', 'Core', 'Flexibility', 'Sports'];
  }

  List<String> getMuscleGroups() {
    return [
      'Chest',
      'Back',
      'Shoulders',
      'Arms',
      'Legs',
      'Glutes',
      'Core',
      'Full Body'
    ];
  }

  List<String> getEquipment() {
    return [
      'Bodyweight',
      'Dumbbells',
      'Barbell',
      'Resistance Bands',
      'Pull-up Bar',
      'Kettlebell',
      'Medicine Ball',
      'Cable Machine',
      'Cardio Machine'
    ];
  }
}