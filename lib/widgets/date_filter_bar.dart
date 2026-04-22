import 'package:flutter/material.dart';

enum DateFilter { hoje, semana, mes, todos }

extension DateFilterX on DateFilter {
  String get label => switch (this) {
        DateFilter.hoje => 'Hoje',
        DateFilter.semana => 'Semana',
        DateFilter.mes => 'Mês',
        DateFilter.todos => 'Todos',
      };

  bool matches(DateTime dateTime) {
    final now = DateTime.now();
    return switch (this) {
      DateFilter.hoje =>
        dateTime.year == now.year &&
            dateTime.month == now.month &&
            dateTime.day == now.day,
      DateFilter.semana =>
        dateTime.isAfter(now.subtract(const Duration(days: 7))),
      DateFilter.mes =>
        dateTime.year == now.year && dateTime.month == now.month,
      DateFilter.todos => true,
    };
  }
}

class DateFilterBar extends StatelessWidget {
  final DateFilter selected;
  final ValueChanged<DateFilter> onChanged;

  const DateFilterBar({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: DateFilter.values
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f.label),
                  selected: selected == f,
                  onSelected: (_) => onChanged(f),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
