import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/client_auth_service.dart';
import '../../services/diet_plan_service.dart';
import 'client_diet_detail_screen.dart';

class ClientNutritionScreen extends StatefulWidget {
  const ClientNutritionScreen({super.key});

  @override
  State<ClientNutritionScreen> createState() => _ClientNutritionScreenState();
}

class _ClientNutritionScreenState extends State<ClientNutritionScreen> {
  final DietPlanService _dietPlanService = DietPlanService();
  List<Map<String, dynamic>> _dietAssignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDietAssignments();
  }

  Future<void> _loadDietAssignments() async {
    final authService = Provider.of<ClientAuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    setState(() => _isLoading = true);
    
    try {
      final clientId = authService.client!.id;
      final assignments = await _dietPlanService.getClientDietAssignments(clientId);
      
      setState(() {
        _dietAssignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading diet assignments: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Nutrition'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadDietAssignments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dietAssignments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No diet plans assigned yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your trainer will assign diet plans for you',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDietAssignments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dietAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = _dietAssignments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.purple,
                            child: Icon(Icons.restaurant, color: Colors.white),
                          ),
                          title: const Text(
                            'Diet Plan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigned: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(assignment['createdAt']))}',
                              ),
                              const SizedBox(height: 4),
                              if (assignment['startDate'] != null)
                                Text(
                                  'Start: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(assignment['startDate']))}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Chip(
                                label: Text(assignment['status'] ?? 'active'),
                                backgroundColor: Colors.purple.withOpacity(0.2),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClientDietDetailScreen(
                                  assignment: assignment,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}