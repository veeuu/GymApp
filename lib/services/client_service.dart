import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/client.dart';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Stream<List<Client>> getClients() {
    if (_currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('clients')
        .where('trainerId', isEqualTo: _currentUserId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Client.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addClient(Client client) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    
    await _firestore.collection('clients').add(client.toMap());
  }

  Future<void> updateClient(Client client) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    
    await _firestore
        .collection('clients')
        .doc(client.id)
        .update(client.toMap());
  }

  Future<void> deleteClient(String clientId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    
    await _firestore.collection('clients').doc(clientId).delete();
  }

  Future<Client?> getClient(String clientId) async {
    if (_currentUserId == null) return null;
    
    final doc = await _firestore.collection('clients').doc(clientId).get();
    if (doc.exists) {
      return Client.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}