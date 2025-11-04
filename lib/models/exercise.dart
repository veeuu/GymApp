class Exercise {
  final String id;
  final String name;
  final String category;
  final String muscleGroup;
  final String equipment;
  final String instructions;
  final String? imageUrl;
  final int? duration; // in seconds for cardio
  final bool isCardio;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.equipment,
    required this.instructions,
    this.imageUrl,
    this.duration,
    this.isCardio = false,
  });

  factory Exercise.fromMap(Map<String, dynamic> map, String id) {
    return Exercise(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      equipment: map['equipment'] ?? '',
      instructions: map['instructions'] ?? '',
      imageUrl: map['imageUrl'],
      duration: map['duration'],
      isCardio: map['isCardio'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'duration': duration,
      'isCardio': isCardio,
    };
  }
}

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double? weight;
  final int? restTime; // in seconds
  final String? notes;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weight,
    this.restTime,
    this.notes,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
      weight: map['weight']?.toDouble(),
      restTime: map['restTime'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restTime': restTime,
      'notes': notes,
    };
  }
}

class WorkoutPlan {
  final String id;
  final String name;
  final String description;
  final String difficulty;
  final List<WorkoutDay> days;
  final String createdBy;
  final DateTime createdAt;

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.days,
    required this.createdBy,
    required this.createdAt,
  });

  factory WorkoutPlan.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutPlan(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? '',
      days: (map['days'] as List<dynamic>?)
          ?.map((day) => WorkoutDay.fromMap(day))
          .toList() ?? [],
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'days': days.map((day) => day.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class WorkoutDay {
  final String name;
  final List<WorkoutExercise> exercises;
  final String? notes;

  WorkoutDay({
    required this.name,
    required this.exercises,
    this.notes,
  });

  factory WorkoutDay.fromMap(Map<String, dynamic> map) {
    return WorkoutDay(
      name: map['name'] ?? '',
      exercises: (map['exercises'] as List<dynamic>?)
          ?.map((exercise) => WorkoutExercise.fromMap(exercise))
          .toList() ?? [],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'notes': notes,
    };
  }
}