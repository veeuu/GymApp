import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/diet_plan.dart';
import '../../services/diet_plan_service.dart';
import '../../services/client_daily_log_service.dart';
import '../../services/client_auth_service.dart';
import 'package:provider/provider.dart';

class ClientDietDetailScreen extends StatefulWidget {
  final Map<String, dynamic> assignment;

  const ClientDietDetailScreen({
    super.key,
    required this.assignment,
  });

  @override
  State<ClientDietDetailScreen> createState() => _ClientDietDetailScreenState();
}

class _ClientDietDetailScreenState extends State<ClientDietDetailScreen> {
  final DietPlanService _dietPlanService = DietPlanService();
  final ClientDailyLogService _dailyLogService = ClientDailyLogService();
  
  DietPlan? _dietPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDietPlan();
  }

  Future<void> _loadDietPlan() async {
    setState(() => _isLoading = true);
    
    try {
      final planId = widget.assignment['planId'];
      final plan = await _dietPlanService.getDietPlanFromAnyTrainer(planId);
      
      setState(() {
        _dietPlan = plan;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading diet plan: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markMealComplete(Meal meal) async {
    final authService = Provider.of<ClientAuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    try {
      await _dailyLogService.logMeal(
        authService.client!.id,
        meal.name, // Use meal name as ID
        meal.name,
        meal.calories,
        meal.items.map((item) => item.name).join(', '),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${meal.name} logged!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging meal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dietPlan?.name ?? 'Diet Plan'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dietPlan == null
              ? const Center(
                  child: Text(
                    'Diet plan not found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    // Plan Info Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.purple.withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dietPlan!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _dietPlan!.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text(_dietPlan!.goal),
                                backgroundColor: _getGoalColor(_dietPlan!.goal),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text('${_dietPlan!.totalCalories} cal/day'),
                                backgroundColor: Colors.orange.withOpacity(0.2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Assigned: ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(widget.assignment['createdAt']))}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Meals List
                    Expanded(
                      child: _dietPlan!.meals.isEmpty
                          ? const Center(
                              child: Text('No meals available'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _dietPlan!.meals.length,
                              itemBuilder: (context, index) {
                                final meal = _dietPlan!.meals[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    meal.name,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    meal.time,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () => _markMealComplete(meal),
                                                  icon: const Icon(Icons.check_circle_outline),
                                                  color: Colors.green,
                                                  tooltip: 'Mark as consumed',
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${meal.calories} cal',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 16),
                                        
                                        // Food Items
                                        const Text(
                                          'Food Items:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        
                                        ...meal.items.map((item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey.withOpacity(0.2),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${item.quantity} ${item.unit}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    _NutrientChip(
                                                      label: '${item.calories} cal',
                                                      color: Colors.orange,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _NutrientChip(
                                                      label: '${item.protein.toStringAsFixed(1)}g protein',
                                                      color: Colors.red,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _NutrientChip(
                                                      label: '${item.carbs.toStringAsFixed(1)}g carbs',
                                                      color: Colors.blue,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    _NutrientChip(
                                                      label: '${item.fat.toStringAsFixed(1)}g fat',
                                                      color: Colors.green,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )).toList(),
                                        
                                        // Meal Totals
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.purple.withOpacity(0.2),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              _MealTotalItem(
                                                label: 'Calories',
                                                value: '${meal.calories}',
                                                color: Colors.orange,
                                              ),
                                              _MealTotalItem(
                                                label: 'Protein',
                                                value: '${meal.items.fold(0.0, (sum, item) => sum + item.protein).toStringAsFixed(1)}g',
                                                color: Colors.red,
                                              ),
                                              _MealTotalItem(
                                                label: 'Carbs',
                                                value: '${meal.items.fold(0.0, (sum, item) => sum + item.carbs).toStringAsFixed(1)}g',
                                                color: Colors.blue,
                                              ),
                                              _MealTotalItem(
                                                label: 'Fat',
                                                value: '${meal.items.fold(0.0, (sum, item) => sum + item.fat).toStringAsFixed(1)}g',
                                                color: Colors.green,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Color _getGoalColor(String goal) {
    switch (goal.toLowerCase()) {
      case 'weight loss':
        return Colors.red.withOpacity(0.2);
      case 'muscle gain':
        return Colors.green.withOpacity(0.2);
      case 'maintenance':
        return Colors.blue.withOpacity(0.2);
      case 'athletic performance':
        return Colors.orange.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final Color color;

  const _NutrientChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MealTotalItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MealTotalItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}