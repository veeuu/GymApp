import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/client.dart';

class ClientAuthService extends ChangeNotifier {
  Client? _client;
  bool _isLoading = false;

  Client? get client => _client;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _client != null;

  ClientAuthService() {
    _loadClientFromStorage();
  }

  Future<void> _loadClientFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final clientJson = prefs.getString('current_client');
    
    if (clientJson != null) {
      final clientMap = json.decode(clientJson);
      _client = Client.fromMap(clientMap, clientMap['id']);
      notifyListeners();
    }
  }

  Future<String?> clientLogin(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      
      // Find client by email across all trainers
      final keys = prefs.getKeys().where((key) => key.startsWith('clients_')).toList();
      
      for (String key in keys) {
        final clientsJson = prefs.getStringList(key) ?? [];
        
        for (String clientJson in clientsJson) {
          final clientMap = jsonDecode(clientJson);
          if (clientMap['email'] == email) {
            // Check if client has set up password
            final clientPassword = prefs.getString('client_password_$email');
            
            if (clientPassword == null) {
              // First time login - set password
              await prefs.setString('client_password_$email', password);
              _client = Client.fromMap(clientMap, clientMap['id']);
              await prefs.setString('current_client', json.encode(_client!.toMap()..['id'] = _client!.id));
              return null;
            } else if (clientPassword == password) {
              // Correct password
              _client = Client.fromMap(clientMap, clientMap['id']);
              await prefs.setString('current_client', json.encode(_client!.toMap()..['id'] = _client!.id));
              return null;
            } else {
              return 'Incorrect password';
            }
          }
        }
      }
      
      return 'No client found with this email. Please contact your trainer.';
    } catch (e) {
      return 'An error occurred during login: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> clientSignup(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      
      // Check if client exists in any trainer's client list
      final keys = prefs.getKeys().where((key) => key.startsWith('clients_')).toList();
      
      for (String key in keys) {
        final clientsJson = prefs.getStringList(key) ?? [];
        
        for (String clientJson in clientsJson) {
          final clientMap = jsonDecode(clientJson);
          if (clientMap['email'] == email) {
            // Client exists, check if already has password
            final existingPassword = prefs.getString('client_password_$email');
            
            if (existingPassword != null) {
              return 'Account already exists. Please login instead.';
            } else {
              // Set up password for existing client
              await prefs.setString('client_password_$email', password);
              _client = Client.fromMap(clientMap, clientMap['id']);
              await prefs.setString('current_client', json.encode(_client!.toMap()..['id'] = _client!.id));
              return null;
            }
          }
        }
      }
      
      return 'No client profile found with this email. Please contact your trainer to add you as a client first.';
    } catch (e) {
      return 'An error occurred during signup: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clientLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_client');
    _client = null;
    notifyListeners();
  }

  Future<String?> resetClientPassword(String email) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      
      // Check if client exists
      final keys = prefs.getKeys().where((key) => key.startsWith('clients_')).toList();
      bool clientExists = false;
      
      for (String key in keys) {
        final clientsJson = prefs.getStringList(key) ?? [];
        
        for (String clientJson in clientsJson) {
          final clientMap = jsonDecode(clientJson);
          if (clientMap['email'] == email) {
            clientExists = true;
            break;
          }
        }
        if (clientExists) break;
      }
      
      if (!clientExists) {
        return 'No client found with this email';
      }

      // Reset password to default
      await prefs.setString('client_password_$email', 'newpassword123');
      
      return null;
    } catch (e) {
      return 'An error occurred while resetting password: $e';
    }
  }
}