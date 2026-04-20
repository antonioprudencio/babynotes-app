import 'package:flutter/material.dart';
import '../view_model/baby_view_model.dart';
import '../domain/models/meal.dart';
import '../view_model/meal_view_model.dart';
import 'meal_form_dialog.dart';

class MealsScreen extends StatefulWidget {
  final MealViewModel mealViewModel;
  final BabyViewModel babyViewModel;
  final bool showAppBar;

  const MealsScreen({
    super.key,
    required this.mealViewModel,
    required this.babyViewModel,
    this.showAppBar = true,
  });

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  @override
  void initState() {
    super.initState();
    widget.mealViewModel.addListener(_onUpdate);
    widget.babyViewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.mealViewModel.removeListener(_onUpdate);
    widget.babyViewModel.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  String _babyName(String babyId) {
    final babies = widget.babyViewModel.babies;
    return babies.firstWhere((b) => b.id == babyId, orElse: () => throw Exception()).name;
  }

  Future<void> _openForm({Meal? meal}) async {
    final babies = widget.babyViewModel.babies;

    if (babies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um baby antes de registrar uma refeição.')),
      );
      return;
    }

    final result = await showDialog<Meal>(
      context: context,
      builder: (_) => MealFormDialog(babies: babies, initialMeal: meal),
    );

    if (result == null) return;

    if (meal == null) {
      widget.mealViewModel.add(result);
    } else {
      widget.mealViewModel.update(result);
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar refeição'),
        content: const Text('Deseja apagar esta refeição?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.mealViewModel.delete(id);
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meals = widget.mealViewModel.meals;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Refeições'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            )
          : null,
      body: meals.isEmpty
          ? const Center(child: Text('Nenhuma refeição cadastrada.'))
          : ListView.separated(
              itemCount: meals.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final meal = meals[index];
                final dateLabel =
                    '${meal.dateTime.day.toString().padLeft(2, '0')}/'
                    '${meal.dateTime.month.toString().padLeft(2, '0')}/'
                    '${meal.dateTime.year}  '
                    '${meal.dateTime.hour.toString().padLeft(2, '0')}:'
                    '${meal.dateTime.minute.toString().padLeft(2, '0')}';

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.local_dining)),
                  title: Text(_babyName(meal.babyId)),
                  subtitle: Text(
                    '$dateLabel · ${meal.type.label}'
                    '${meal.volume != null ? ' · ${meal.volume} ml' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar',
                        onPressed: () => _openForm(meal: meal),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        tooltip: 'Apagar',
                        onPressed: () => _confirmDelete(meal.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        tooltip: 'Registrar refeição',
        child: const Icon(Icons.add),
      ),
    );
  }
}
