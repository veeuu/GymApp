import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../services/local_client_service.dart';
import '../../services/local_auth_service.dart';

class AddEditClientScreen extends StatefulWidget {
  final Client? client;

  const AddEditClientScreen({super.key, this.client});

  @override
  State<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends State<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final LocalClientService _clientService = LocalClientService();
  
  String _selectedGender = 'Male';
  String _selectedGoal = 'Weight Loss';
  DateTime? _selectedDob;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _goals = [
    'Weight Loss',
    'Muscle Gain',
    'Strength Training',
    'Endurance',
    'General Fitness'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nameController.text = widget.client!.name;
      _phoneController.text = widget.client!.phone;
      _emailController.text = widget.client!.email ?? '';
      _selectedGender = widget.client!.gender;
      _selectedGoal = widget.client!.goal;
      _selectedDob = widget.client!.dob;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDob = date);
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<LocalAuthService>(context, listen: false);
      if (!authService.isAuthenticated) throw Exception('User not authenticated');

      final now = DateTime.now();
      
      if (widget.client == null) {
        // Add new client
        final client = Client(
          id: '',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          gender: _selectedGender,
          goal: _selectedGoal,
          dob: _selectedDob,
          trainerId: authService.trainer!.uid,
          createdAt: now,
          lastUpdated: now,
        );
        await _clientService.addClient(client);
      } else {
        // Update existing client
        final updatedClient = widget.client!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          gender: _selectedGender,
          goal: _selectedGoal,
          dob: _selectedDob,
          lastUpdated: now,
        );
        await _clientService.updateClient(updatedClient);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.client == null ? 'Client added successfully' : 'Client updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Add Client' : 'Edit Client'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveClient,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter client name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc),
              ),
              items: _genders.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedGender = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGoal,
              decoration: const InputDecoration(
                labelText: 'Fitness Goal',
                prefixIcon: Icon(Icons.flag),
              ),
              items: _goals.map((goal) {
                return DropdownMenuItem(
                  value: goal,
                  child: Text(goal),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedGoal = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cake),
              title: Text(_selectedDob == null ? 'Date of Birth (Optional)' : 'Date of Birth'),
              subtitle: _selectedDob == null
                  ? const Text('Tap to select')
                  : Text('${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}'),
              onTap: _selectDate,
              trailing: _selectedDob == null
                  ? const Icon(Icons.arrow_forward_ios)
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedDob = null),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}