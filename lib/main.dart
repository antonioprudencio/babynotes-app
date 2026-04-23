import 'package:flutter/material.dart';
import 'data/repositories/baby_repository.dart';
import 'data/repositories/hygiene_repository.dart';
import 'data/repositories/meal_repository.dart';
import 'data/repositories/medication_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/weight_repository.dart';
import 'data/services/api_client.dart';
import 'data/services/baby_api_service.dart';
import 'data/services/hygiene_api_service.dart';
import 'data/services/meal_api_service.dart';
import 'data/services/medication_api_service.dart';
import 'data/services/sync_service.dart';
import 'data/services/weight_record_api_service.dart';
import 'view_model/baby_view_model.dart';
import 'view_model/hygiene_view_model.dart';
import 'view_model/meal_view_model.dart';
import 'view_model/medication_view_model.dart';
import 'view_model/weight_view_model.dart';
import 'widgets/babies_screen.dart';
import 'widgets/hygiene_screen.dart';
import 'widgets/meals_screen.dart';
import 'widgets/medications_screen.dart';
import 'widgets/statistics_screen.dart';
import 'widgets/weight_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 235, 236)),
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
  bool _isSyncing = false;

  // Repositories
  final _userRepo = UserRepository();
  final _babyRepo = BabyRepository();
  final _mealRepo = MealRepository();
  final _hygieneRepo = HygieneRepository();
  final _medicationRepo = MedicationRepository();
  final _weightRepo = WeightRepository();

  // API layer
  late final ApiClient _apiClient;
  late final SyncService _syncService;

  // ViewModels
  late final BabyViewModel _babyViewModel;
  late final MealViewModel _mealViewModel;
  late final MedicationViewModel _medicationViewModel;
  late final HygieneViewModel _hygieneViewModel;
  late final WeightViewModel _weightViewModel;

  late final List<Widget> _screens;

  static const _icons = [
    Icons.child_care,
    Icons.local_dining,
    Icons.medication,
    Icons.water_drop_outlined,
    Icons.monitor_weight_outlined,
    Icons.bar_chart,
  ];

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient();
    _syncService = SyncService(
      userRepo: _userRepo,
      babyRepo: _babyRepo,
      mealRepo: _mealRepo,
      hygieneRepo: _hygieneRepo,
      medicationRepo: _medicationRepo,
      weightRepo: _weightRepo,
      babyApi: BabyApiService(_apiClient),
      mealApi: MealApiService(_apiClient),
      hygieneApi: HygieneApiService(_apiClient),
      medicationApi: MedicationApiService(_apiClient),
      weightApi: WeightRecordApiService(_apiClient),
    );

    _babyViewModel = BabyViewModel(_babyRepo, _syncService);
    _mealViewModel = MealViewModel(_mealRepo, _syncService);
    _medicationViewModel = MedicationViewModel(_medicationRepo, _syncService);
    _hygieneViewModel = HygieneViewModel(_hygieneRepo, _syncService);
    _weightViewModel = WeightViewModel(_weightRepo, _syncService);

    _screens = [
      BabiesScreen(viewModel: _babyViewModel, showAppBar: false),
      MealsScreen(mealViewModel: _mealViewModel, babyViewModel: _babyViewModel, showAppBar: false),
      MedicationsScreen(medicationViewModel: _medicationViewModel, babyViewModel: _babyViewModel, showAppBar: false),
      HygieneScreen(hygieneViewModel: _hygieneViewModel, babyViewModel: _babyViewModel, showAppBar: false),
      WeightScreen(weightViewModel: _weightViewModel, babyViewModel: _babyViewModel, showAppBar: false),
      StatisticsScreen(
        babyViewModel: _babyViewModel,
        mealViewModel: _mealViewModel,
        medicationViewModel: _medicationViewModel,
        hygieneViewModel: _hygieneViewModel,
        weightViewModel: _weightViewModel,
        showAppBar: false,
      ),
    ];

    _userRepo.init();
  }

  Future<void> _forceSync() async {
    setState(() => _isSyncing = true);
    await _syncService.syncAll();
    if (!mounted) return;
    _babyViewModel.refresh();
    _mealViewModel.refresh();
    _hygieneViewModel.refresh();
    _medicationViewModel.refresh();
    _weightViewModel.refresh();
    setState(() => _isSyncing = false);
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
        actions: [
          _isSyncing
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Sincronizar com servidor',
                  onPressed: _forceSync,
                ),
        ],
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
