import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../view_model/baby_view_model.dart';
import '../view_model/weight_view_model.dart';
import '../domain/models/baby.dart';
import '../domain/models/weight_record.dart';
import 'weight_form_dialog.dart';

const _lineColors = [
  Color(0xFF6750A4),
  Color(0xFF2196F3),
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
  Color(0xFFE91E63),
  Color(0xFF00BCD4),
];

class WeightScreen extends StatefulWidget {
  final WeightViewModel weightViewModel;
  final BabyViewModel babyViewModel;
  final bool showAppBar;

  const WeightScreen({
    super.key,
    required this.weightViewModel,
    required this.babyViewModel,
    this.showAppBar = true,
  });

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  @override
  void initState() {
    super.initState();
    widget.weightViewModel.addListener(_onUpdate);
    widget.babyViewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.weightViewModel.removeListener(_onUpdate);
    widget.babyViewModel.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  Future<void> _openForm({WeightRecord? record}) async {
    final babies = widget.babyViewModel.babies;
    if (babies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um baby antes de registrar o peso.')),
      );
      return;
    }
    final result = await showDialog<WeightRecord>(
      context: context,
      builder: (_) => WeightFormDialog(babies: babies, initialRecord: record),
    );
    if (result == null) return;
    if (record == null) {
      widget.weightViewModel.add(result);
    } else {
      widget.weightViewModel.update(result);
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar registro'),
        content: const Text('Deseja apagar este registro de peso?'),
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
              widget.weightViewModel.delete(id);
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<Baby> babies, ColorScheme colors) {
    // Build per-baby sorted records
    final babiesWithRecords = babies
        .asMap()
        .entries
        .map((e) => (
              baby: e.value,
              color: _lineColors[e.key % _lineColors.length],
              records: widget.weightViewModel.getByBaby(e.value.id),
            ))
        .where((e) => e.records.isNotEmpty)
        .toList();

    final allRecords = babiesWithRecords.expand((e) => e.records).toList();

    if (allRecords.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Nenhum registro para exibir o gráfico.',
            style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    final hasEnoughData = babiesWithRecords.any((e) => e.records.length >= 2);
    if (!hasEnoughData) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Adicione pelo menos 2 registros por baby para ver o gráfico.',
            style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Use day-offset from earliest date as x value
    final minDate = allRecords
        .map((r) => r.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final minDateDay = DateTime(minDate.year, minDate.month, minDate.day);

    int dayOffset(DateTime d) =>
        DateTime(d.year, d.month, d.day).difference(minDateDay).inDays;

    final allWeights = allRecords.map((r) => r.weightKg);
    final minY = (allWeights.reduce((a, b) => a < b ? a : b) - 0.5).clamp(0.0, double.infinity);
    final maxY = allWeights.reduce((a, b) => a > b ? a : b) + 0.5;
    final maxX = allRecords.map((r) => dayOffset(r.date).toDouble()).reduce((a, b) => a > b ? a : b);

    final bars = babiesWithRecords
        .where((e) => e.records.length >= 2)
        .map((e) {
          final spots = e.records
              .map((r) => FlSpot(dayOffset(r.date).toDouble(), r.weightKg))
              .toList();
          return LineChartBarData(
            spots: spots,
            isCurved: true,
            color: e.color,
            barWidth: 2.5,
            dotData: FlDotData(
              getDotPainter: (_, __, _, _) => FlDotCirclePainter(
                radius: 4,
                color: e.color,
                strokeWidth: 2,
                strokeColor: colors.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: e.color.withValues(alpha: 0.08),
            ),
          );
        })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(
            spacing: 16,
            runSpacing: 4,
            children: babiesWithRecords
                .map((e) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: e.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(e.baby.name, style: const TextStyle(fontSize: 12)),
                      ],
                    ))
                .toList(),
          ),
        ),
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 24, 8),
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                minX: 0,
                maxX: maxX,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: colors.outlineVariant, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toStringAsFixed(1)}kg',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxX > 30 ? (maxX / 5).ceilToDouble() : (maxX > 6 ? (maxX / 4).ceilToDouble() : 1),
                      getTitlesWidget: (value, _) {
                        final date = minDateDay.add(Duration(days: value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: bars,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final babies = widget.babyViewModel.babies;
    final allRecords = widget.weightViewModel.allRecords;

    final babyMap = {for (final b in babies) b.id: b};

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Peso'),
              backgroundColor: colors.inversePrimary,
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildChart(babies, colors),
          const Divider(height: 1),
          Expanded(
            child: allRecords.isEmpty
                ? const Center(child: Text('Nenhum registro de peso.'))
                : ListView.separated(
                    itemCount: allRecords.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final r = allRecords[index];
                      final babyIndex = babies.indexWhere((b) => b.id == r.babyId);
                      final lineColor = babyIndex >= 0
                          ? _lineColors[babyIndex % _lineColors.length]
                          : colors.primary;
                      final dateLabel =
                          '${r.date.day.toString().padLeft(2, '0')}/'
                          '${r.date.month.toString().padLeft(2, '0')}/'
                          '${r.date.year}';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: lineColor.withValues(alpha: 0.2),
                          child: Icon(Icons.monitor_weight_outlined, color: lineColor),
                        ),
                        title: Text('${r.weightKg} kg'),
                        subtitle: Text('${babyMap[r.babyId]?.name ?? ''} · $dateLabel'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Editar',
                              onPressed: () => _openForm(record: r),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: colors.error),
                              tooltip: 'Apagar',
                              onPressed: () => _confirmDelete(r.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        tooltip: 'Registrar peso',
        child: const Icon(Icons.add),
      ),
    );
  }
}
