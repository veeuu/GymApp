class ClientDailyLog {
  final String id;
  final String clientId;
  final DateTime date;
  final int waterIntake; // in ml
  final int steps;
  final List<CompletedExercise> completedExercises;
  final List<ConsumedMeal> consumedMeals;
  final double? weight;
  final String? notes;
  final DateTime createdAt;

  ClientDailyLog({
    required this.id,
    required this.clientId,
    required this.date,
    required this.waterIntake,
    required this.steps,
    required this.completedExercises,
    required this.consumedMeals,
    this.weight,
    this.notes,
    required this.createdAt,
  });

  factory ClientDailyLog.fromMap(Map<String, dynamic> map, String id) {
    return ClientDailyLog(
      id: id,
      clientId: map['clientId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      waterIntake: map['waterIntake'] ?? 0,
      steps: map['steps'] ?? 0,
      completedExercises: (map['completedExercises'] as List<dynamic>?)
          ?.map((e) => CompletedExercise.fromMap(e))
          .toList() ?? [],
      consumedMeals: (map['consumedMeals'] as List<dynamic>?)
          ?.map((e) => ConsumedMeal.fromMap(e))
          .toList() ?? [],
      weight: map['weight']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'date': date.millisecondsSinceEpoch,
      'waterIntake': waterIntake,
      'steps': steps,
      'completedExercises': completedExercises.map((e) => e.toMap()).toList(),
      'consumedMeals': consumedMeals.map((e) => e.toMap()).toList(),
      'weight': weight,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class CompletedExercise {
  final String exerciseId;
  final String exerciseName;
  final int setsCompleted;
  final int repsCompleted;
  final double? weightUsed;
  final int durationMinutes;
  final DateTime completedAt;

  CompletedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.setsCompleted,
    required this.repsCompleted,
    this.weightUsed,
    required this.durationMinutes,
    required this.completedAt,
  });

  factory CompletedExercise.fromMap(Map<String, dynamic> map) {
    return CompletedExercise(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      setsCompleted: map['setsCompleted'] ?? 0,
      repsCompleted: map['repsCompleted'] ?? 0,
      weightUsed: map['weightUsed']?.toDouble(),
      durationMinutes: map['durationMinutes'] ?? 0,
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setsCompleted': setsCompleted,
      'repsCompleted': repsCompleted,
      'weightUsed': weightUsed,
      'durationMinutes': durationMinutes,
      'completedAt': completedAt.millisecondsSinceEpoch,
    };
  }
}

class ConsumedMeal {
  final String mealName;
  final List<ConsumedFood> foods;
  final int totalCalories;
  final DateTime consumedAt;

  ConsumedMeal({
    required this.mealName,
    required this.foods,
    required this.totalCalories,
    required this.consumedAt,
  });

  factory ConsumedMeal.fromMap(Map<String, dynamic> map) {
    return ConsumedMeal(
      mealName: map['mealName'] ?? '',
      foods: (map['foods'] as List<dynamic>?)
          ?.map((e) => ConsumedFood.fromMap(e))
          .toList() ?? [],
      totalCalories: map['totalCalories'] ?? 0,
      consumedAt: DateTime.fromMillisecondsSinceEpoch(map['consumedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealName': mealName,
      'foods': foods.map((e) => e.toMap()).toList(),
      'totalCalories': totalCalories,
      'consumedAt': consumedAt.millisecondsSinceEpoch,
    };
  }
}

class ConsumedFood {
  final String name;
  final double quantity;
  final String unit;
  final int calories;

  ConsumedFood({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
  });

  factory ConsumedFood.fromMap(Map<String, dynamic> map) {
    return ConsumedFood(
      name: map['name'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      calories: map['calories'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
    };
  }
}