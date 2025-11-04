import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DebugService {
  static Future<void> debugClientData(String clientEmail) async {
    final prefs = await SharedPreferences.getInstance();
    
    print('=== DEBUG CLIENT DATA ===');
    print('Looking for client email: $clientEmail');
    
    // Find client in all trainer lists
    final clientKeys = prefs.getKeys().where((key) => key.startsWith('clients_')).toList();
    print('Found ${clientKeys.length} trainer client lists');
    
    for (String key in clientKeys) {
      print('Checking $key');
      final clientsJson = prefs.getStringList(key) ?? [];
      
      for (String clientJson in clientsJson) {
        final clientMap = jsonDecode(clientJson);
        if (clientMap['email'] == clientEmail) {
          print('FOUND CLIENT:');
          print('  ID: ${clientMap['id']}');
          print('  Name: ${clientMap['name']}');
          print('  Email: ${clientMap['email']}');
          print('  Trainer ID: ${clientMap['trainerId']}');
        }
      }
    }
    
    // Check workout assignments
    final workoutKeys = prefs.getKeys().where((key) => key.startsWith('plan_assignments_')).toList();
    print('Found ${workoutKeys.length} workout assignment lists');
    
    for (String key in workoutKeys) {
      final assignmentsJson = prefs.getStringList(key) ?? [];
      print('$key has ${assignmentsJson.length} assignments');
      
      for (String assignmentJson in assignmentsJson) {
        final assignment = jsonDecode(assignmentJson);
        print('  Assignment for client: ${assignment['clientId']}');
      }
    }
    
    // Check diet assignments
    final dietKeys = prefs.getKeys().where((key) => key.startsWith('diet_assignments_')).toList();
    print('Found ${dietKeys.length} diet assignment lists');
    
    for (String key in dietKeys) {
      final assignmentsJson = prefs.getStringList(key) ?? [];
      print('$key has ${assignmentsJson.length} assignments');
      
      for (String assignmentJson in assignmentsJson) {
        final assignment = jsonDecode(assignmentJson);
        print('  Diet assignment for client: ${assignment['clientId']}');
      }
    }
    
    print('=== END DEBUG ===');
  }
}