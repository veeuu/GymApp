import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/trainer.dart';

class LocalAuthService extends ChangeNotifier {
  Trainer? _trainer;
  bool _isLoading = false;

  Trainer? get trainer => _trainer;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _trainer != null;

  LocalAuthService() {
    _loadTrainerFromStorage();
  }

  Future<void> _loadTrainerFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final trainerJson = prefs.getString('current_trainer');
    
    if (trainerJson != null) {
      final trainerMap = json.decode(trainerJson);
      _trainer = Trainer.fromMap(trainerMap);
      notifyListeners();
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user already exists
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('registered_users') ?? [];
      
      if (existingUsers.contains(email)) {
        return 'User with this email already exists';
      }

      // Create new trainer
      final trainer = Trainer(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      // Save trainer to current session
      await prefs.setString('current_trainer', json.encode(trainer.toMap()));
      
      // Add to registered users list
      existingUsers.add(email);
      await prefs.setStringList('registered_users', existingUsers);
      
      // Store password (in real app, this would be hashed)
      await prefs.setString('password_$email', password);
      
      // Store trainer data for future logins
      final allTrainers = prefs.getStringList('all_trainers') ?? [];
      allTrainers.add(json.encode(trainer.toMap()));
      await prefs.setStringList('all_trainers', allTrainers);

      _trainer = trainer;
      return null;
    } catch (e) {
      return 'An error occurred during sign up: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('registered_users') ?? [];
      
      if (!existingUsers.contains(email)) {
        return 'No user found with this email';
      }

      final storedPassword = prefs.getString('password_$email');
      if (storedPassword != password) {
        return 'Incorrect password';
      }

      // Load trainer data from stored trainers
      final allTrainers = prefs.getStringList('all_trainers') ?? [];
      bool trainerFound = false;
      
      for (String trainerJson in allTrainers) {
        final trainerMap = json.decode(trainerJson);
        if (trainerMap['email'] == email) {
          _trainer = Trainer.fromMap(trainerMap);
          await prefs.setString('current_trainer', trainerJson);
          trainerFound = true;
          break;
        }
      }

      // This should not happen if signup worked correctly
      if (!trainerFound) {
        return 'Account data not found. Please sign up again.';
      }

      return null;
    } catch (e) {
      return 'An error occurred during sign in: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_trainer');
    _trainer = null;
    notifyListeners();
  }

  Future<String?> resetPassword(String email) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('registered_users') ?? [];
      
      if (!existingUsers.contains(email)) {
        return 'No user found with this email';
      }

      // In a real app, this would send an email
      // For demo, we'll just reset to a default password
      await prefs.setString('password_$email', 'newpassword123');
      
      return null;
    } catch (e) {
      return 'An error occurred while sending reset email: $e';
    }
  }
}