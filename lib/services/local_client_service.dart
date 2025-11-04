import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/client.dart';
import 'package:uuid/uuid.dart';

class LocalClientService {
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

  Stream<List<Client>> getClients() async* {
    // Initial load
    final clients = await _getClientsFromStorage();
    yield clients;
    
    // Listen for changes (simplified approach)
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      final updatedClients = await _getClientsFromStorage();
      yield updatedClients;
    }
  }

  Future<List<Client>> _getClientsFromStorage() async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final clientsJson = prefs.getStringList('clients_$currentUserId') ?? [];
    
    return clientsJson
        .map((json) {
          final map = jsonDecode(json);
          return Client.fromMap(map, map['id']);
        })
        .toList()
        ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  Future<void> addClient(Client client) async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final clientsJson = prefs.getStringList('clients_$currentUserId') ?? [];
    
    final newClient = Client(
      id: _uuid.v4(),
      name: client.name,
      phone: client.phone,
      email: client.email,
      gender: client.gender,
      goal: client.goal,
      dob: client.dob,
      trainerId: currentUserId,
      createdAt: client.createdAt,
      lastUpdated: client.lastUpdated,
    );

    clientsJson.add(json.encode(newClient.toMap()..['id'] = newClient.id));
    await prefs.setStringList('clients_$currentUserId', clientsJson);
  }

  Future<void> updateClient(Client client) async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final clientsJson = prefs.getStringList('clients_$currentUserId') ?? [];
    
    final updatedClientsJson = clientsJson.map((json) {
      final map = jsonDecode(json);
      if (map['id'] == client.id) {
        return jsonEncode(client.toMap()..['id'] = client.id);
      }
      return json;
    }).toList();

    await prefs.setStringList('clients_$currentUserId', updatedClientsJson);
  }

  Future<void> deleteClient(String clientId) async {
    final currentUserId = await _currentUserId;
    if (currentUserId == null) throw Exception('User not authenticated');

    final prefs = await SharedPreferences.getInstance();
    final clientsJson = prefs.getStringList('clients_$currentUserId') ?? [];
    
    final updatedClientsJson = clientsJson
        .where((json) {
          final map = jsonDecode(json);
          return map['id'] != clientId;
        })
        .toList();

    await prefs.setStringList('clients_$currentUserId', updatedClientsJson);
  }

  Future<Client?> getClient(String clientId) async {
    final clients = await _getClientsFromStorage();
    try {
      return clients.firstWhere((client) => client.id == clientId);
    } catch (e) {
      return null;
    }
  }
}