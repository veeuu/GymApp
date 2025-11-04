import 'package:flutter/material.dart';
import '../../models/diet_plan.dart';
import '../../services/diet_plan_service.dart';
import 'create_diet_plan_screen.dart';

class DietPlansScreen extends StatefulWidget {
  const DietPlansScreen({super.key});

  @override
  State<DietPlansScreen> createState() => _DietPlansScreenState();
}

class _DietPlansScreenState extends State<DietPlansScreen> {
  final DietPlanService _dietPlanService = DietPlanService();
  List<DietPlan> _dietPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDietPlans();
  }

  Future<void> _loadDietPlans() async {
    setState(() => _isLoading = true);
    try {
      final plans = await _dietPlanService.getDietPlans();
      setState(() {
        _dietPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading diet plans: $e')),
        );
      }
    }
  }

  Future<void> _deleteDietPlan(DietPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diet Plan'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dietPlanService.deleteDietPlan(plan.id);
        _loadDietPlans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Diet plan deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting diet plan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plans'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDietPlans,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dietPlans.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No diet plans created yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first diet plan to get started',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDietPlans,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dietPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _dietPlans[index];
                      return DietPlanCard(
                        plan: plan,
                        onDelete: () => _deleteDietPlan(plan),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateDietPlanScreen()),
          );
          _loadDietPlans();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Diet Plan'),
      ),
    );
  }
}

class DietPlanCard extends StatelessWidget {
  final DietPlan plan;
  final VoidCallback onDelete;

  const DietPlanCard({
    super.key,
    required this.plan,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getGoalColor(plan.goal),
          child: const Icon(Icons.restaurant, color: Colors.white),
        ),
        title: Text(
          plan.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goal: ${plan.goal}'),
            Text('Total Calories: ${plan.totalCalories} kcal'),
            Text('Meals: ${plan.meals.length}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.description.isNotEmpty) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(plan.description),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Meals:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...plan.meals.map((meal) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              meal.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${meal.time} • ${meal.calories} kcal',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...meal.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16, top: 2),
                            child: Text(
                              '• ${item.name} (${item.quantity}${item.unit})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getGoalColor(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return Colors.red;
      case 'Muscle Gain':
        return Colors.green;
      case 'Maintenance':
        return Colors.blue;
      case 'Athletic Performance':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }
}