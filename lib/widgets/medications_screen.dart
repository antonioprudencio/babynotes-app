import 'package:flutter/material.dart';
import '../view_model/baby_view_model.dart';
import '../view_model/medication_view_model.dart';
import '../domain/models/medication.dart';
import 'date_filter_bar.dart';
import 'medication_form_dialog.dart';

class MedicationsScreen extends StatefulWidget {
  final MedicationViewModel medicationViewModel;
  final BabyViewModel babyViewModel;
  final bool showAppBar;

  const MedicationsScreen({
    super.key,
    required this.medicationViewModel,
    required this.babyViewModel,
    this.showAppBar = true,
  });

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  DateFilter _filter = DateFilter.hoje;

  @override
  void initState() {
    super.initState();
    widget.medicationViewModel.addListener(_onUpdate);
    widget.babyViewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.medicationViewModel.removeListener(_onUpdate);
    widget.babyViewModel.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  String _babyName(String babyId) {
    final babies = widget.babyViewModel.babies;
    return babies.firstWhere((b) => b.id == babyId, orElse: () => throw Exception()).name;
  }

  Future<void> _openForm({Medication? medication}) async {
    final babies = widget.babyViewModel.babies;

    if (babies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um baby antes de registrar um medicamento.')),
      );
      return;
    }

    final result = await showDialog<Medication>(
      context: context,
      builder: (_) => MedicationFormDialog(babies: babies, initialMedication: medication),
    );

    if (result == null) return;

    if (medication == null) {
      widget.medicationViewModel.add(result);
    } else {
      widget.medicationViewModel.update(result);
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar medicamento'),
        content: const Text('Deseja apagar este medicamento?'),
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
              widget.medicationViewModel.delete(id);
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medications = widget.medicationViewModel.medications
        .where((m) => _filter.matches(m.dateTime))
        .toList();

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Medicamentos'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            )
          : null,
      body: Column(
        children: [
          DateFilterBar(
            selected: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: medications.isEmpty
                ? const Center(child: Text('Nenhum medicamento registrado.'))
                : ListView.separated(
                    itemCount: medications.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final med = medications[index];
                      final dateLabel =
                          '${med.dateTime.day.toString().padLeft(2, '0')}/'
                          '${med.dateTime.month.toString().padLeft(2, '0')}/'
                          '${med.dateTime.year}  '
                          '${med.dateTime.hour.toString().padLeft(2, '0')}:'
                          '${med.dateTime.minute.toString().padLeft(2, '0')}';
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.medication)),
                        title: Text(med.name),
                        subtitle: Text(
                          '${_babyName(med.babyId)} · $dateLabel · ${med.dose} ${med.unit.label}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Editar',
                              onPressed: () => _openForm(medication: med),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              tooltip: 'Apagar',
                              onPressed: () => _confirmDelete(med.id),
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
        tooltip: 'Registrar medicamento',
        child: const Icon(Icons.add),
      ),
    );
  }
}
