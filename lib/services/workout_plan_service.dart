import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/exercise.dart';
import 'package:uuid/uuid.dart';

class WorkoutPlanService {
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

  Future<List<WorkoutPlan>> getWorkoutPlans() async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('workout_plans_$currentUserId') ?? [];
    
    return plansJson
        .map((json) {
          final map = jsonDecode(json);
          return WorkoutPlan.fromMap(map, map['id']);
        })
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('workout_plans_$currentUserId') ?? [];
    
    final newPlan = WorkoutPlan(
      id: _uuid.v4(),
      name: plan.name,
      description: plan.description,
      difficulty: plan.difficulty,
      days: plan.days,
      createdBy: currentUserId,
      createdAt: DateTime.now(),
    );

    plansJson.add(json.encode(newPlan.toMap()..['id'] = newPlan.id));
    await prefs.setStringList('workout_plans_$currentUserId', plansJson);
  }

  Future<void> deleteWorkoutPlan(String planId) async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('workout_plans_$currentUserId') ?? [];
    
    final updatedPlansJson = plansJson
        .where((json) {
          final map = jsonDecode(json);
          return map['id'] != planId;
        })
        .toList();

    await prefs.setStringList('workout_plans_$currentUserId', updatedPlansJson);
  }

  Future<WorkoutPlan?> getWorkoutPlan(String planId) async {
    final plans = await getWorkoutPlans();
    try {
      return plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  // Assign workout plan to client
  Future<void> assignPlanToClient(String clientId, String planId, DateTime startDate, DateTime? endDate) async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final assignmentsJson = prefs.getStringList('plan_assignments_$currentUserId') ?? [];
    
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
    await prefs.setStringList('plan_assignments_$currentUserId', assignmentsJson);
  }

  Future<List<Map<String, dynamic>>> getClientAssignments(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Search across all trainers for assignments to this client
    final keys = prefs.getKeys().where((key) => key.startsWith('plan_assignments_')).toList();
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

  // Get workout plan from any trainer (for client access)
  Future<WorkoutPlan?> getWorkoutPlanFromAnyTrainer(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Search across all trainers for the plan
    final keys = prefs.getKeys().where((key) => key.startsWith('workout_plans_')).toList();
    
    for (String key in keys) {
      final plansJson = prefs.getStringList(key) ?? [];
      for (String planJson in plansJson) {
        final planMap = jsonDecode(planJson);
        if (planMap['id'] == planId) {
          return WorkoutPlan.fromMap(planMap, planId);
        }
      }
    }
    
    return null;
  }
}