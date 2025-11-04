class ProgressEntry {
  final String id;
  final String clientId;
  final DateTime date;
  final double? weight;
  final double? bodyFat;
  final Map<String, double> measurements; // chest, waist, arms, etc.
  final List<String> photoUrls;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  ProgressEntry({
    required this.id,
    required this.clientId,
    required this.date,
    this.weight,
    this.bodyFat,
    required this.measurements,
    required this.photoUrls,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory ProgressEntry.fromMap(Map<String, dynamic> map, String id) {
    return ProgressEntry(
      id: id,
      clientId: map['clientId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      weight: map['weight']?.toDouble(),
      bodyFat: map['bodyFat']?.toDouble(),
      measurements: Map<String, double>.from(map['measurements'] ?? {}),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      notes: map['notes'],
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'date': date.millisecondsSinceEpoch,
      'weight': weight,
      'bodyFat': bodyFat,
      'measurements': measurements,
      'photoUrls': photoUrls,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class WorkoutSession {
  final String id;
  final String clientId;
  final String workoutPlanId;
  final DateTime date;
  final List<ExerciseSet> completedSets;
  final int duration; // in minutes
  final String? notes;
  final DateTime createdAt;

  WorkoutSession({
    required this.id,
    required this.clientId,
    required this.workoutPlanId,
    required this.date,
    required this.completedSets,
    required this.duration,
    this.notes,
    required this.createdAt,
  });

  factory WorkoutSession.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutSession(
      id: id,
      clientId: map['clientId'] ?? '',
      workoutPlanId: map['workoutPlanId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      completedSets: (map['completedSets'] as List<dynamic>?)
          ?.map((set) => ExerciseSet.fromMap(set))
          .toList() ?? [],
      duration: map['duration'] ?? 0,
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'workoutPlanId': workoutPlanId,
      'date': date.millisecondsSinceEpoch,
      'completedSets': completedSets.map((set) => set.toMap()).toList(),
      'duration': duration,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class ExerciseSet {
  final String exerciseId;
  final String exerciseName;
  final int setNumber;
  final int reps;
  final double? weight;
  final int? duration; // for cardio
  final bool completed;

  ExerciseSet({
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    this.weight,
    this.duration,
    required this.completed,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      setNumber: map['setNumber'] ?? 0,
      reps: map['reps'] ?? 0,
      weight: map['weight']?.toDouble(),
      duration: map['duration'],
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'completed': completed,
    };
  }
}