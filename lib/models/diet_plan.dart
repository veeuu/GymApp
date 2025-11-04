class DietPlan {
  final String id;
  final String name;
  final String description;
  final String goal; // Weight Loss, Muscle Gain, Maintenance
  final int totalCalories;
  final List<Meal> meals;
  final String createdBy;
  final DateTime createdAt;

  DietPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.totalCalories,
    required this.meals,
    required this.createdBy,
    required this.createdAt,
  });

  factory DietPlan.fromMap(Map<String, dynamic> map, String id) {
    return DietPlan(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      goal: map['goal'] ?? '',
      totalCalories: map['totalCalories'] ?? 0,
      meals: (map['meals'] as List<dynamic>?)
          ?.map((meal) => Meal.fromMap(meal))
          .toList() ?? [],
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'goal': goal,
      'totalCalories': totalCalories,
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class Meal {
  final String name;
  final String time;
  final List<FoodItem> items;
  final int calories;

  Meal({
    required this.name,
    required this.time,
    required this.items,
    required this.calories,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] ?? '',
      time: map['time'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => FoodItem.fromMap(item))
          .toList() ?? [],
      calories: map['calories'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'time': time,
      'items': items.map((item) => item.toMap()).toList(),
      'calories': calories,
    };
  }
}

class FoodItem {
  final String name;
  final double quantity;
  final String unit;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      calories: map['calories'] ?? 0,
      protein: map['protein']?.toDouble() ?? 0.0,
      carbs: map['carbs']?.toDouble() ?? 0.0,
      fat: map['fat']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}