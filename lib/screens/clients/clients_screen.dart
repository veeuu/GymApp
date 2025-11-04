import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
import '../../services/local_client_service.dart';
import 'add_edit_client_screen.dart';
import 'client_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final LocalClientService _clientService = LocalClientService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGoal = 'All';

  final List<String> _goals = [
    'All',
    'Weight Loss',
    'Muscle Gain',
    'Strength Training',
    'Endurance',
    'General Fitness'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Client> _filterClients(List<Client> clients) {
    return clients.where((client) {
      final matchesSearch = client.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.phone.contains(_searchQuery);
      final matchesGoal = _selectedGoal == 'All' || client.goal == _selectedGoal;
      return matchesSearch && matchesGoal;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search clients...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGoal,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Goal',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: _goals.map((goal) {
                    return DropdownMenuItem(
                      value: goal,
                      child: Text(goal),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGoal = value!),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Client>>(
              stream: _clientService.getClients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final clients = snapshot.data ?? [];
                final filteredClients = _filterClients(clients);

                if (filteredClients.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No clients found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    return ClientCard(
                      client: client,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientDetailScreen(client: client),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditClientScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;

  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goal: ${client.goal}'),
            Text('Phone: ${client.phone}'),
            Text(
              'Last Updated: ${DateFormat('MMM dd, yyyy').format(client.lastUpdated)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Icon(
          client.gender == 'Male' ? Icons.male : Icons.female,
          color: client.gender == 'Male' ? Colors.blue : Colors.pink,
        ),
        onTap: onTap,
      ),
    );
  }
}