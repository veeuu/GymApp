import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  // Clear all app data (useful for testing)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Get all stored data (for debugging)
  static Future<Map<String, dynamic>> getAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final data = <String, dynamic>{};
    
    for (String key in keys) {
      data[key] = prefs.get(key);
    }
    
    return data;
  }
}