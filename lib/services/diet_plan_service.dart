import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/diet_plan.dart';
import 'package:uuid/uuid.dart';

class DietPlanService {
  final Uuid _uuid = const Uuid();

  Future<String?> get _currentUserId async {
    final prefs = await SharedPreferences.getInstance();
    final trainerJson = prefs.getString('current_trainer');
    if (trainerJson != null) {
      final trainerMap = json.decode(trainerJson);
      return trainerMap['uid'];
    }
    return null;
  }

  Future<List<DietPlan>> getDietPlans() async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('diet_plans_$currentUserId') ?? [];
    
    return plansJson
        .map((json) {
          final map = jsonDecode(json);
          return DietPlan.fromMap(map, map['id']);
        })
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveDietPlan(DietPlan plan) async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('diet_plans_$currentUserId') ?? [];
    
    final newPlan = DietPlan(
      id: _uuid.v4(),
      name: plan.name,
      description: plan.description,
      goal: plan.goal,
      totalCalories: plan.totalCalories,
      meals: plan.meals,
      createdBy: currentUserId,
      createdAt: DateTime.now(),
    );

    plansJson.add(json.encode(newPlan.toMap()..['id'] = newPlan.id));
    await prefs.setStringList('diet_plans_$currentUserId', plansJson);
  }

  Future<void> deleteDietPlan(String planId) async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('diet_plans_$currentUserId') ?? [];
    
    final updatedPlansJson = plansJson
        .where((json) {
          final map = jsonDecode(json);
          return map['id'] != planId;
        })
        .toList();

    await prefs.setStringList('diet_plans_$currentUserId', updatedPlansJson);
  }

  Future<DietPlan?> getDietPlan(String planId) async {
    final plans = await getDietPlans();
    try {
      return plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  // Assign diet plan to client
  Future<void> assignDietPlanToClient(String clientId, String planId, DateTime startDate, DateTime? endDate) async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final assignmentsJson = prefs.getStringList('diet_assignments_$currentUserId') ?? [];
    
    final assignment = {
      'id': _uuid.v4(),
      'clientId': clientId,
      'planId': planId,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'status': 'active',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    assignmentsJson.add(json.encode(assignment));
    await prefs.setStringList('diet_assignments_$currentUserId', assignmentsJson);
  }

  Future<List<Map<String, dynamic>>> getClientDietAssignments(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Search across all trainers for diet assignments to this client
    final keys = prefs.getKeys().where((key) => key.startsWith('diet_assignments_')).toList();
    List<Map<String, dynamic>> allAssignments = [];
    
    for (String key in keys) {
      final assignmentsJson = prefs.getStringList(key) ?? [];
      final assignments = assignmentsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .where((assignment) => assignment['clientId'] == clientId)
          .toList();
      allAssignments.addAll(assignments);
    }
    
    return allAssignments;
  }

  // Get diet plan from any trainer (for client access)
  Future<DietPlan?> getDietPlanFromAnyTrainer(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Search across all trainers for the plan
    final keys = prefs.getKeys().where((key) => key.startsWith('diet_plans_')).toList();
    
    for (String key in keys) {
      final plansJson = prefs.getStringList(key) ?? [];
      for (String planJson in plansJson) {
        final planMap = jsonDecode(planJson);
        if (planMap['id'] == planId) {
          return DietPlan.fromMap(planMap, planId);
        }
      }
    }
    
    return null;
  }

  // Common food database
  List<Map<String, dynamic>> getCommonFoods() {
    return [
      {'name': 'Chicken Breast (100g)', 'calories': 165, 'protein': 31.0, 'carbs': 0.0, 'fat': 3.6},
      {'name': 'Brown Rice (100g)', 'calories': 111, 'protein': 2.6, 'carbs': 22.0, 'fat': 0.9},
      {'name': 'Broccoli (100g)', 'calories': 34, 'protein': 2.8, 'carbs': 7.0, 'fat': 0.4},
      {'name': 'Salmon (100g)', 'calories': 208, 'protein': 25.4, 'carbs': 0.0, 'fat': 12.4},
      {'name': 'Sweet Potato (100g)', 'calories': 86, 'protein': 1.6, 'carbs': 20.0, 'fat': 0.1},
      {'name': 'Eggs (1 large)', 'calories': 70, 'protein': 6.0, 'carbs': 0.6, 'fat': 5.0},
      {'name': 'Oats (100g)', 'calories': 389, 'protein': 16.9, 'carbs': 66.0, 'fat': 6.9},
      {'name': 'Banana (1 medium)', 'calories': 105, 'protein': 1.3, 'carbs': 27.0, 'fat': 0.4},
      {'name': 'Greek Yogurt (100g)', 'calories': 59, 'protein': 10.0, 'carbs': 3.6, 'fat': 0.4},
      {'name': 'Almonds (30g)', 'calories': 173, 'protein': 6.0, 'carbs': 6.0, 'fat': 15.0},
      {'name': 'Spinach (100g)', 'calories': 23, 'protein': 2.9, 'carbs': 3.6, 'fat': 0.4},
      {'name': 'Quinoa (100g)', 'calories': 120, 'protein': 4.4, 'carbs': 22.0, 'fat': 1.9},
    ];
  }

  List<String> getDietGoals() {
    return [
      'Weight Loss',
      'Muscle Gain',
      'Maintenance',
      'Athletic Performance',
      'General Health'
    ];
  }

  List<String> getMealTypes() {
    return [
      'Breakfast',
      'Mid-Morning Snack',
      'Lunch',
      'Afternoon Snack',
      'Dinner',
      'Evening Snack'
    ];
  }
}