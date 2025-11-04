import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/client_daily_log.dart';
import 'package:uuid/uuid.dart';

class ClientDailyLogService {
  final Uuid _uuid = const Uuid();

  Future<ClientDailyLog?> getTodayLog(String clientId) async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getStringList('daily_logs_$clientId') ?? [];
    
    for (String logJson in logsJson) {
      final logMap = jsonDecode(logJson);
      final logDate = DateTime.fromMillisecondsSinceEpoch(logMap['date']);
      final logKey = '${logDate.year}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}';
      
      if (logKey == todayKey) {
        return ClientDailyLog.fromMap(logMap, logMap['id']);
      }
    }
    
    return null;
  }

  Future<void> saveDailyLog(ClientDailyLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getStringList('daily_logs_${log.clientId}') ?? [];
    
    // Remove existing log for the same date if exists
    final dateKey = '${log.date.year}-${log.date.month.toString().padLeft(2, '0')}-${log.date.day.toString().padLeft(2, '0')}';
    logsJson.removeWhere((logJson) {
      final logMap = jsonDecode(logJson);
      final logDate = DateTime.fromMillisecondsSinceEpoch(logMap['date']);
      final logDateKey = '${logDate.year}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}';
      return logDateKey == dateKey;
    });
    
    // Add new log
    final newLog = ClientDailyLog(
      id: log.id.isEmpty ? _uuid.v4() : log.id,
      clientId: log.clientId,
      date: log.date,
      waterIntake: log.waterIntake,
      steps: log.steps,
      completedExercises: log.completedExercises,
      consumedMeals: log.consumedMeals,
      weight: log.weight,
      notes: log.notes,
      createdAt: log.createdAt,
    );
    
    logsJson.add(json.encode(newLog.toMap()..['id'] = newLog.id));
    await prefs.setStringList('daily_logs_${log.clientId}', logsJson);
  }

  Future<List<ClientDailyLog>> getWeeklyLogs(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getStringList('daily_logs_$clientId') ?? [];
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return logsJson
        .map((json) {
          final map = jsonDecode(json);
          return ClientDailyLog.fromMap(map, map['id']);
        })
        .where((log) {
          return log.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                 log.date.isBefore(weekEnd.add(const Duration(days: 1)));
        })
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateWaterIntake(String clientId, int waterIntake) async {
    final todayLog = await getTodayLog(clientId);
    final now = DateTime.now();
    
    if (todayLog != null) {
      final updatedLog = ClientDailyLog(
        id: todayLog.id,
        clientId: clientId,
        date: todayLog.date,
        waterIntake: waterIntake,
        steps: todayLog.steps,
        completedExercises: todayLog.completedExercises,
        consumedMeals: todayLog.consumedMeals,
        weight: todayLog.weight,
        notes: todayLog.notes,
        createdAt: todayLog.createdAt,
      );
      await saveDailyLog(updatedLog);
    } else {
      final newLog = ClientDailyLog(
        id: _uuid.v4(),
        clientId: clientId,
        date: now,
        waterIntake: waterIntake,
        steps: 0,
        completedExercises: [],
        consumedMeals: [],
        createdAt: now,
      );
      await saveDailyLog(newLog);
    }
  }

  Future<void> updateSteps(String clientId, int steps) async {
    final todayLog = await getTodayLog(clientId);
    final now = DateTime.now();
    
    if (todayLog != null) {
      final updatedLog = ClientDailyLog(
        id: todayLog.id,
        clientId: clientId,
        date: todayLog.date,
        waterIntake: todayLog.waterIntake,
        steps: steps,
        completedExercises: todayLog.completedExercises,
        consumedMeals: todayLog.consumedMeals,
        weight: todayLog.weight,
        notes: todayLog.notes,
        createdAt: todayLog.createdAt,
      );
      await saveDailyLog(updatedLog);
    } else {
      final newLog = ClientDailyLog(
        id: _uuid.v4(),
        clientId: clientId,
        date: now,
        waterIntake: 0,
        steps: steps,
        completedExercises: [],
        consumedMeals: [],
        createdAt: now,
      );
      await saveDailyLog(newLog);
    }
  }

  Future<void> addCompletedExercise(String clientId, CompletedExercise exercise) async {
    final todayLog = await getTodayLog(clientId);
    final now = DateTime.now();
    
    if (todayLog != null) {
      final updatedExercises = List<CompletedExercise>.from(todayLog.completedExercises);
      updatedExercises.add(exercise);
      
      final updatedLog = ClientDailyLog(
        id: todayLog.id,
        clientId: clientId,
        date: todayLog.date,
        waterIntake: todayLog.waterIntake,
        steps: todayLog.steps,
        completedExercises: updatedExercises,
        consumedMeals: todayLog.consumedMeals,
        weight: todayLog.weight,
        notes: todayLog.notes,
        createdAt: todayLog.createdAt,
      );
      await saveDailyLog(updatedLog);
    } else {
      final newLog = ClientDailyLog(
        id: _uuid.v4(),
        clientId: clientId,
        date: now,
        waterIntake: 0,
        steps: 0,
        completedExercises: [exercise],
        consumedMeals: [],
        createdAt: now,
      );
      await saveDailyLog(newLog);
    }
  }

  Future<void> addConsumedMeal(String clientId, ConsumedMeal meal) async {
    final todayLog = await getTodayLog(clientId);
    final now = DateTime.now();
    
    if (todayLog != null) {
      final updatedMeals = List<ConsumedMeal>.from(todayLog.consumedMeals);
      updatedMeals.add(meal);
      
      final updatedLog = ClientDailyLog(
        id: todayLog.id,
        clientId: clientId,
        date: todayLog.date,
        waterIntake: todayLog.waterIntake,
        steps: todayLog.steps,
        completedExercises: todayLog.completedExercises,
        consumedMeals: updatedMeals,
        weight: todayLog.weight,
        notes: todayLog.notes,
        createdAt: todayLog.createdAt,
      );
      await saveDailyLog(updatedLog);
    } else {
      final newLog = ClientDailyLog(
        id: _uuid.v4(),
        clientId: clientId,
        date: now,
        waterIntake: 0,
        steps: 0,
        completedExercises: [],
        consumedMeals: [meal],
        createdAt: now,
      );
      await saveDailyLog(newLog);
    }
  }

  // Alias methods for compatibility with client screens
  Future<void> logExercise(String clientId, String exerciseId, String exerciseName, int sets, int reps, double? weight) async {
    final exercise = CompletedExercise(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      setsCompleted: sets,
      repsCompleted: reps,
      weightUsed: weight,
      durationMinutes: 0, // Default duration
      completedAt: DateTime.now(),
    );
    await addCompletedExercise(clientId, exercise);
  }

  Future<void> logMeal(String clientId, String mealId, String mealName, int calories, String mealType) async {
    final meal = ConsumedMeal(
      mealName: mealName,
      foods: [], // Empty foods list for now
      totalCalories: calories,
      consumedAt: DateTime.now(),
    );
    await addConsumedMeal(clientId, meal);
  }
}