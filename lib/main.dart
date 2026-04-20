import 'package:flutter/material.dart';
import 'babies/view_model/baby_view_model.dart';
import 'babies/widgets/babies_screen.dart';
import 'data/repositories/baby_repository.dart';
import 'data/repositories/meal_repository.dart';
import 'meals/view_model/meal_view_model.dart';
import 'meals/widgets/meals_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _babyViewModel = BabyViewModel(BabyRepository());
  late final _mealViewModel = MealViewModel(MealRepository());

  late final List<Widget> _screens;

  static const _labels = ['Babies', 'Refeições'];

  @override
  void initState() {
    super.initState();
    _screens = [
      BabiesScreen(viewModel: _babyViewModel, showAppBar: false),
      MealsScreen(mealViewModel: _mealViewModel, babyViewModel: _babyViewModel, showAppBar: false),
    ];
  }

  @override
  void dispose() {
    _babyViewModel.dispose();
    _mealViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: const Text('Baby Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _labels.length; i++) ...[
                if (i > 0)
                  Text(
                    ' | ',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                TextButton(
                  onPressed: () => setState(() => _currentIndex = i),
                  child: Text(
                    _labels[i],
                    style: TextStyle(
                      color: _currentIndex == i
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: _currentIndex == i ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
    );
  }
}
