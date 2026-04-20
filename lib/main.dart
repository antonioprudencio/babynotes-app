import 'package:flutter/material.dart';
import 'view_model/baby_view_model.dart';
import 'view_model/meal_view_model.dart';
import 'view_model/medication_view_model.dart';
import 'view_model/hygiene_view_model.dart';
import 'view_model/weight_view_model.dart';
import 'widgets/babies_screen.dart';
import 'widgets/meals_screen.dart';
import 'widgets/medications_screen.dart';
import 'widgets/hygiene_screen.dart';
import 'widgets/weight_screen.dart';
import 'data/repositories/baby_repository.dart';
import 'data/repositories/meal_repository.dart';
import 'data/repositories/medication_repository.dart';
import 'data/repositories/hygiene_repository.dart';
import 'data/repositories/weight_repository.dart';

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
  late final _medicationViewModel = MedicationViewModel(MedicationRepository());
  late final _hygieneViewModel = HygieneViewModel(HygieneRepository());
  late final _weightViewModel = WeightViewModel(WeightRepository());

  late final List<Widget> _screens;

  static const _icons = [
    Icons.child_care,
    Icons.local_dining,
    Icons.medication,
    Icons.water_drop_outlined,
    Icons.monitor_weight_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      BabiesScreen(viewModel: _babyViewModel, showAppBar: false),
      MealsScreen(mealViewModel: _mealViewModel, babyViewModel: _babyViewModel, showAppBar: false),
      MedicationsScreen(medicationViewModel: _medicationViewModel, babyViewModel: _babyViewModel, showAppBar: false),
      HygieneScreen(hygieneViewModel: _hygieneViewModel, babyViewModel: _babyViewModel, showAppBar: false),
      WeightScreen(weightViewModel: _weightViewModel, babyViewModel: _babyViewModel, showAppBar: false),
    ];
  }

  @override
  void dispose() {
    _babyViewModel.dispose();
    _mealViewModel.dispose();
    _medicationViewModel.dispose();
    _hygieneViewModel.dispose();
    _weightViewModel.dispose();
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
            children: [
              for (int i = 0; i < _icons.length; i++) ...[
                if (i > 0)
                  Text(
                    '|',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Expanded(
                  child: IconButton(
                    onPressed: () => setState(() => _currentIndex = i),
                    icon: Icon(
                      _icons[i],
                      color: _currentIndex == i
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
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
