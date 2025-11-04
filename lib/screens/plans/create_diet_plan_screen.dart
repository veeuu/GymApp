import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/diet_plan.dart';
import '../../services/diet_plan_service.dart';
import '../../services/local_auth_service.dart';

class CreateDietPlanScreen extends StatefulWidget {
  const CreateDietPlanScreen({super.key});

  @override
  State<CreateDietPlanScreen> createState() => _CreateDietPlanScreenState();
}

class _CreateDietPlanScreenState extends State<CreateDietPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedGoal = 'Weight Loss';
  int _totalCalories = 0;
  List<Meal> _meals = [];
  final DietPlanService _dietPlanService = DietPlanService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addMeal();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addMeal() {
    setState(() {
      _meals.add(Meal(
        name: 'Meal ${_meals.length + 1}',
        time: '08:00',
        items: [],
        calories: 0,
      ));
    });
  }

  void _removeMeal(int index) {
    if (_meals.length > 1) {
      setState(() {
        _totalCalories -= _meals[index].calories;
        _meals.removeAt(index);
      });
    }
  }

  void _addFoodToMeal(int mealIndex) {
    showDialog(
      context: context,
      builder: (context) => _FoodSelectionDialog(
        onFoodSelected: (foodItem) {
          setState(() {
            _meals[mealIndex].items.add(foodItem);
            _meals[mealIndex] = Meal(
              name: _meals[mealIndex].name,
              time: _meals[mealIndex].time,
              items: _meals[mealIndex].items,
              calories: _meals[mealIndex].items.fold(0, (sum, item) => sum + item.calories),
            );
            _calculateTotalCalories();
          });
        },
      ),
    );
  }

  void _calculateTotalCalories() {
    _totalCalories = _meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  Future<void> _saveDietPlan() async {
    if (!_formKey.currentState!.validate() || _meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and add at least one meal')),
      );
      return;
    }

    final authService = Provider.of<LocalAuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final dietPlan = DietPlan(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        goal: _selectedGoal,
        totalCalories: _totalCalories,
        meals: _meals,
        createdBy: authService.trainer!.uid,
        createdAt: DateTime.now(),
      );

      await _dietPlanService.saveDietPlan(dietPlan);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diet plan created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating diet plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Diet Plan'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDietPlan,
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
            // Basic Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Name *',
                        hintText: 'e.g., Weight Loss Diet',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a plan name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Brief description of the diet plan',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGoal,
                      decoration: const InputDecoration(labelText: 'Diet Goal'),
                      items: _dietPlanService.getDietGoals().map((goal) {
                        return DropdownMenuItem(
                          value: goal,
                          child: Text(goal),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedGoal = value!),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Calories:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$_totalCalories kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Meals
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Meals',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addMeal,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Meal'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ..._meals.asMap().entries.map((entry) {
                      final index = entry.key;
                      final meal = entry.value;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: meal.name,
                                      decoration: const InputDecoration(
                                        labelText: 'Meal Name',
                                        isDense: true,
                                      ),
                                      onChanged: (value) {
                                        _meals[index] = Meal(
                                          name: value,
                                          time: meal.time,
                                          items: meal.items,
                                          calories: meal.calories,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      initialValue: meal.time,
                                      decoration: const InputDecoration(
                                        labelText: 'Time',
                                        isDense: true,
                                      ),
                                      onChanged: (value) {
                                        _meals[index] = Meal(
                                          name: meal.name,
                                          time: value,
                                          items: meal.items,
                                          calories: meal.calories,
                                        );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _addFoodToMeal(index),
                                    icon: const Icon(Icons.add_circle, color: Colors.green),
                                  ),
                                  if (_meals.length > 1)
                                    IconButton(
                                      onPressed: () => _removeMeal(index),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                    ),
                                ],
                              ),
                              
                              if (meal.items.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'No food items added yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                ...meal.items.map((item) {
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.restaurant),
                                    title: Text(item.name),
                                    subtitle: Text(
                                      '${item.quantity}${item.unit} • ${item.calories} kcal • P:${item.protein}g C:${item.carbs}g F:${item.fat}g',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          meal.items.remove(item);
                                          _meals[index] = Meal(
                                            name: meal.name,
                                            time: meal.time,
                                            items: meal.items,
                                            calories: meal.items.fold(0, (sum, item) => sum + item.calories),
                                          );
                                          _calculateTotalCalories();
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Meal Total: ${meal.calories} kcal',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodSelectionDialog extends StatefulWidget {
  final Function(FoodItem) onFoodSelected;

  const _FoodSelectionDialog({required this.onFoodSelected});

  @override
  State<_FoodSelectionDialog> createState() => _FoodSelectionDialogState();
}

class _FoodSelectionDialogState extends State<_FoodSelectionDialog> {
  final DietPlanService _dietPlanService = DietPlanService();
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredFoods {
    final foods = _dietPlanService.getCommonFoods();
    if (_searchQuery.isEmpty) return foods;
    return foods.where((food) =>
      food['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Select Food Item',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFoods.length,
                itemBuilder: (context, index) {
                  final food = _filteredFoods[index];
                  return ListTile(
                    title: Text(food['name']),
                    subtitle: Text(
                      '${food['calories']} kcal • P:${food['protein']}g C:${food['carbs']}g F:${food['fat']}g',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showQuantityDialog(food);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(Map<String, dynamic> food) {
    final quantityController = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${food['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'e.g., 1, 0.5, 2',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text) ?? 1.0;
              
              final foodItem = FoodItem(
                name: food['name'],
                quantity: quantity,
                unit: 'serving',
                calories: (food['calories'] * quantity).round(),
                protein: food['protein'] * quantity,
                carbs: food['carbs'] * quantity,
                fat: food['fat'] * quantity,
              );
              
              Navigator.pop(context);
              widget.onFoodSelected(foodItem);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}