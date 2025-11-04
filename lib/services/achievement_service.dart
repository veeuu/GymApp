import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/achievement.dart';
import 'client_daily_log_service.dart';

class AchievementService {
  final ClientDailyLogService _dailyLogService = ClientDailyLogService();

  // Default achievements
  static const List<Map<String, dynamic>> _defaultAchievements = [
    {
      'id': 'first_workout',
      'name': 'First Steps',
      'description': 'Complete your first workout',
      'iconName': 'fitness_center',
      'category': 'Workout',
      'targetValue': 1,
      'unit': 'workout',
    },
    {
      'id': 'workout_streak_7',
      'name': 'Week Warrior',
      'description': 'Complete workouts for 7 days straight',
      'iconName': 'local_fire_department',
      'category': 'Streak',
      'targetValue': 7,
      'unit': 'days',
    },
    {
      'id': 'workout_streak_30',
      'name': 'Monthly Master',
      'description': 'Complete workouts for 30 days straight',
      'iconName': 'emoji_events',
      'category': 'Streak',
      'targetValue': 30,
      'unit': 'days',
    },
    {
      'id': 'water_goal_7',
      'name': 'Hydration Hero',
      'description': 'Drink 2L+ water for 7 days straight',
      'iconName': 'water_drop',
      'category': 'Hydration',
      'targetValue': 7,
      'unit': 'days',
    },
    {
      'id': 'steps_10k',
      'name': '10K Steps',
      'description': 'Walk 10,000 steps in a day',
      'iconName': 'directions_walk',
      'category': 'Activity',
      'targetValue': 10000,
      'unit': 'steps',
    },
    {
      'id': 'weight_loss_5kg',
      'name': 'Weight Warrior',
      'description': 'Lose 5kg from starting weight',
      'iconName': 'trending_down',
      'category': 'Weight',
      'targetValue': 5,
      'unit': 'kg',
    },
    {
      'id': 'total_workouts_50',
      'name': 'Fitness Fanatic',
      'description': 'Complete 50 total workouts',
      'iconName': 'star',
      'category': 'Milestone',
      'targetValue': 50,
      'unit': 'workouts',
    },
    {
      'id': 'consistency_champion',
      'name': 'Consistency Champion',
      'description': 'Log activity for 90 days straight',
      'iconName': 'military_tech',
      'category': 'Consistency',
      'targetValue': 90,
      'unit': 'days',
    },
  ];

  Future<void> _initializeAchievements(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsInitialized = prefs.getBool('achievements_initialized_$clientId') ?? false;
    
    if (!achievementsInitialized) {
      final achievementsJson = prefs.getStringList('achievements_$clientId') ?? [];
      
      for (var achievementData in _defaultAchievements) {
        final achievement = Achievement.fromMap(achievementData);
        achievementsJson.add(json.encode(achievement.toMap()));
      }
      
      await prefs.setStringList('achievements_$clientId', achievementsJson);
      await prefs.setBool('achievements_initialized_$clientId', true);
    }
  }

  Future<List<Achievement>> getClientAchievements(String clientId) async {
    await _initializeAchievements(clientId);
    
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getStringList('achievements_$clientId') ?? [];
    
    return achievementsJson.map((json) {
      final map = jsonDecode(json);
      return Achievement.fromMap(map);
    }).toList();
  }

  Future<void> checkAndUnlockAchievements(String clientId) async {
    final achievements = await getClientAchievements(clientId);
    final todayLog = await _dailyLogService.getTodayLog(clientId);
    
    bool hasNewAchievements = false;
    List<Achievement> updatedAchievements = [];

    for (var achievement in achievements) {
      if (achievement.isUnlocked) {
        updatedAchievements.add(achievement);
        continue;
      }

      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_workout':
          if (todayLog?.completedExercises.isNotEmpty == true) {
            shouldUnlock = true;
          }
          break;
          
        case 'steps_10k':
          if (todayLog?.steps != null && todayLog!.steps >= 10000) {
            shouldUnlock = true;
          }
          break;
          
        case 'water_goal_7':
          final waterStreak = await _calculateWaterStreak(clientId);
          if (waterStreak >= 7) {
            shouldUnlock = true;
          }
          break;
          
        case 'workout_streak_7':
          final workoutStreak = await _calculateWorkoutStreak(clientId);
          if (workoutStreak >= 7) {
            shouldUnlock = true;
          }
          break;
          
        case 'workout_streak_30':
          final workoutStreak = await _calculateWorkoutStreak(clientId);
          if (workoutStreak >= 30) {
            shouldUnlock = true;
          }
          break;
      }

      if (shouldUnlock) {
        hasNewAchievements = true;
        updatedAchievements.add(Achievement(
          id: achievement.id,
          name: achievement.name,
          description: achievement.description,
          iconName: achievement.iconName,
          category: achievement.category,
          targetValue: achievement.targetValue,
          unit: achievement.unit,
          unlockedAt: DateTime.now(),
          isUnlocked: true,
        ));
      } else {
        updatedAchievements.add(achievement);
      }
    }

    if (hasNewAchievements) {
      await _saveAchievements(clientId, updatedAchievements);
    }
  }

  Future<void> _saveAchievements(String clientId, List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = achievements.map((a) => json.encode(a.toMap())).toList();
    await prefs.setStringList('achievements_$clientId', achievementsJson);
  }

  Future<int> _calculateWorkoutStreak(String clientId) async {
    final logs = await _dailyLogService.getWeeklyLogs(clientId);
    if (logs.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    // Check backwards from today
    for (int i = 0; i < 30; i++) {
      final checkDate = currentDate.subtract(Duration(days: i));
      final dayLog = logs.where((log) {
        return log.date.year == checkDate.year &&
               log.date.month == checkDate.month &&
               log.date.day == checkDate.day;
      }).firstOrNull;
      
      if (dayLog?.completedExercises.isNotEmpty == true) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  Future<int> _calculateWaterStreak(String clientId) async {
    final logs = await _dailyLogService.getWeeklyLogs(clientId);
    if (logs.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    // Check backwards from today
    for (int i = 0; i < 30; i++) {
      final checkDate = currentDate.subtract(Duration(days: i));
      final dayLog = logs.where((log) {
        return log.date.year == checkDate.year &&
               log.date.month == checkDate.month &&
               log.date.day == checkDate.day;
      }).firstOrNull;
      
      if (dayLog?.waterIntake != null && dayLog!.waterIntake >= 2000) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  Future<Map<String, int>> getClientStreaks(String clientId) async {
    final workoutStreak = await _calculateWorkoutStreak(clientId);
    final waterStreak = await _calculateWaterStreak(clientId);
    
    return {
      'workout': workoutStreak,
      'water': waterStreak,
    };
  }

  Future<List<Achievement>> getNewlyUnlockedAchievements(String clientId) async {
    final achievements = await getClientAchievements(clientId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return achievements.where((achievement) {
      if (!achievement.isUnlocked || achievement.unlockedAt == null) return false;
      final unlockedDate = DateTime(
        achievement.unlockedAt!.year,
        achievement.unlockedAt!.month,
        achievement.unlockedAt!.day,
      );
      return unlockedDate.isAtSameMomentAs(today);
    }).toList();
  }
}