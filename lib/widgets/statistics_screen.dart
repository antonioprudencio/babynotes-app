import 'package:flutter/material.dart';
import '../domain/models/hygiene.dart';
import '../domain/models/meal.dart';
import '../domain/models/weight_record.dart';
import '../domain/models/medication.dart';
import '../view_model/baby_view_model.dart';
import '../view_model/meal_view_model.dart';
import '../view_model/medication_view_model.dart';
import '../view_model/hygiene_view_model.dart';
import '../view_model/weight_view_model.dart';

class StatisticsScreen extends StatefulWidget {
  final BabyViewModel babyViewModel;
  final MealViewModel mealViewModel;
  final MedicationViewModel medicationViewModel;
  final HygieneViewModel hygieneViewModel;
  final WeightViewModel weightViewModel;
  final bool showAppBar;

  const StatisticsScreen({
    super.key,
    required this.babyViewModel,
    required this.mealViewModel,
    required this.medicationViewModel,
    required this.hygieneViewModel,
    required this.weightViewModel,
    this.showAppBar = true,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    widget.babyViewModel.addListener(_onUpdate);
    widget.mealViewModel.addListener(_onUpdate);
    widget.medicationViewModel.addListener(_onUpdate);
    widget.hygieneViewModel.addListener(_onUpdate);
    widget.weightViewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.babyViewModel.removeListener(_onUpdate);
    widget.mealViewModel.removeListener(_onUpdate);
    widget.medicationViewModel.removeListener(_onUpdate);
    widget.hygieneViewModel.removeListener(_onUpdate);
    widget.weightViewModel.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays == 1) return 'ontem';
    return 'há ${diff.inDays} dias';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final babies = widget.babyViewModel.babies;

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentMeals = widget.mealViewModel.meals.where((m) => m.dateTime.isAfter(weekAgo)).toList();
    final recentHygiene = widget.hygieneViewModel.hygienes.where((h) => h.dateTime.isAfter(weekAgo)).toList();
    final recentMeds = widget.medicationViewModel.medications.where((m) => m.dateTime.isAfter(weekAgo)).toList();

    final mamadeiraCount = recentMeals.where((m) => m.type == MealType.mamadeira).length;
    final peitoCount = recentMeals.where((m) => m.type == MealType.peito).length;
    final volumeTotal = recentMeals
        .where((m) => m.volume != null)
        .fold<double>(0, (sum, m) => sum + m.volume!);

    final hygieneByType = <HygieneType, int>{};
    for (final h in recentHygiene) {
      hygieneByType[h.type] = (hygieneByType[h.type] ?? 0) + 1;
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: colorScheme.inversePrimary,
              title: const Text('Estatísticas'),
            )
          : null,
      body: babies.isEmpty
          ? const Center(child: Text('Nenhum bebê cadastrado'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _SectionTitle('Últimos 7 dias'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatTile(icon: Icons.local_dining, label: 'Refeições', value: recentMeals.length, color: Colors.orange),
                    const SizedBox(width: 8),
                    _StatTile(icon: Icons.water_drop_outlined, label: 'Higiene', value: recentHygiene.length, color: Colors.blue),
                    const SizedBox(width: 8),
                    _StatTile(icon: Icons.medication, label: 'Medicamentos', value: recentMeds.length, color: Colors.purple),
                  ],
                ),
                if (recentMeals.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionTitle('Refeições por tipo'),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MealTypeRow(
                            label: 'Mamadeira',
                            count: mamadeiraCount,
                            total: recentMeals.length,
                            color: Colors.orange,
                            icon: Icons.local_cafe,
                          ),
                          const SizedBox(height: 12),
                          _MealTypeRow(
                            label: 'Peito',
                            count: peitoCount,
                            total: recentMeals.length,
                            color: Colors.pink,
                            icon: Icons.favorite,
                          ),
                          if (volumeTotal > 0) ...[
                            const Divider(height: 24),
                            Row(
                              children: [
                                Icon(Icons.water, size: 16, color: Colors.orange.shade700),
                                const SizedBox(width: 6),
                                Text(
                                  'Volume total (mamadeira): ${volumeTotal.toStringAsFixed(0)} ml',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                if (recentHygiene.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionTitle('Higiene por tipo'),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: HygieneType.values
                          .where((t) => hygieneByType.containsKey(t))
                          .map(
                            (t) => ListTile(
                              dense: true,
                              leading: Icon(Icons.water_drop_outlined, size: 20, color: Colors.blue),
                              title: Text(t.label),
                              trailing: Chip(
                                label: Text('${hygieneByType[t]}x'),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _SectionTitle('Por bebê'),
                const SizedBox(height: 10),
                for (final baby in babies) ...[
                  _BabyCard(
                    babyName: baby.name,
                    lastMeal: widget.mealViewModel.meals
                        .where((m) => m.babyId == baby.id)
                        .fold<Meal?>(null, (prev, m) => prev == null || m.dateTime.isAfter(prev.dateTime) ? m : prev),
                    lastHygiene: widget.hygieneViewModel.hygienes
                        .where((h) => h.babyId == baby.id)
                        .fold<Hygiene?>(null, (prev, h) => prev == null || h.dateTime.isAfter(prev.dateTime) ? h : prev),
                    lastMedication: widget.medicationViewModel.medications
                        .where((m) => m.babyId == baby.id)
                        .fold<Medication?>(null, (prev, m) => prev == null || m.dateTime.isAfter(prev.dateTime) ? m : prev),
                    lastWeight: widget.weightViewModel.getByBaby(baby.id).lastOrNull,
                    timeAgo: _timeAgo,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealTypeRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _MealTypeRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Text(
              '$count (${(pct * 100).toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
          ),
        ),
      ],
    );
  }
}

class _BabyCard extends StatelessWidget {
  final String babyName;
  final Meal? lastMeal;
  final Hygiene? lastHygiene;
  final Medication? lastMedication;
  final WeightRecord? lastWeight;
  final String Function(DateTime) timeAgo;

  const _BabyCard({
    required this.babyName,
    required this.lastMeal,
    required this.lastHygiene,
    required this.lastMedication,
    required this.lastWeight,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(babyName[0].toUpperCase(), style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Text(
                  babyName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _LastEventTile(
            icon: Icons.local_dining,
            label: 'Última refeição',
            value: lastMeal != null ? '${lastMeal!.type.label} · ${timeAgo(lastMeal!.dateTime)}' : null,
            color: Colors.orange,
          ),
          _LastEventTile(
            icon: Icons.water_drop_outlined,
            label: 'Última higiene',
            value: lastHygiene != null ? '${lastHygiene!.type.label} · ${timeAgo(lastHygiene!.dateTime)}' : null,
            color: Colors.blue,
          ),
          _LastEventTile(
            icon: Icons.medication,
            label: 'Último medicamento',
            value: lastMedication != null ? '${lastMedication!.name} · ${timeAgo(lastMedication!.dateTime)}' : null,
            color: Colors.purple,
          ),
          _LastEventTile(
            icon: Icons.monitor_weight_outlined,
            label: 'Último peso',
            value: lastWeight != null ? '${lastWeight!.weightKg.toStringAsFixed(2)} kg · ${timeAgo(lastWeight!.date)}' : null,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
}

class _LastEventTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color color;

  const _LastEventTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: value != null ? color : Colors.grey),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      subtitle: Text(
        value ?? 'Sem registros',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: value != null ? null : Colors.grey,
              fontStyle: value != null ? null : FontStyle.italic,
            ),
      ),
    );
  }
}
