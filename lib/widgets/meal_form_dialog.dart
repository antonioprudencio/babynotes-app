import 'package:flutter/material.dart';
import '../domain/models/baby.dart';
import '../domain/models/meal.dart';
import '../domain/models/sync_status.dart';

class MealFormDialog extends StatefulWidget {
  final List<Baby> babies;
  final Meal? initialMeal;

  const MealFormDialog({super.key, required this.babies, this.initialMeal});

  @override
  State<MealFormDialog> createState() => _MealFormDialogState();
}

class _MealFormDialogState extends State<MealFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _volumeController = TextEditingController();

  late String? _selectedBabyId;
  late DateTime _selectedDateTime;
  late MealType _selectedType;

  @override
  void initState() {
    super.initState();
    final meal = widget.initialMeal;
    _selectedBabyId = meal?.babyId ?? (widget.babies.isNotEmpty ? widget.babies.first.id : null);
    _selectedDateTime = meal?.dateTime ?? DateTime.now();
    _selectedType = meal?.type ?? MealType.mamadeira;
    _volumeController.text = meal?.volume?.toString() ?? '';
  }

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final meal = Meal(
        id: widget.initialMeal?.id ?? '',
        babyId: _selectedBabyId!,
        dateTime: _selectedDateTime,
        type: _selectedType,
        volume: _selectedType == MealType.mamadeira
            ? double.tryParse(_volumeController.text.trim())
            : null,
        updatedAt: widget.initialMeal?.updatedAt ?? DateTime.now(),
        syncStatus: widget.initialMeal?.syncStatus ?? SyncStatus.pendingCreate,
      );
      Navigator.of(context).pop(meal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_selectedDateTime.day.toString().padLeft(2, '0')}/'
        '${_selectedDateTime.month.toString().padLeft(2, '0')}/'
        '${_selectedDateTime.year}  '
        '${_selectedDateTime.hour.toString().padLeft(2, '0')}:'
        '${_selectedDateTime.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      title: Text(widget.initialMeal == null ? 'Cadastrar Refeição' : 'Editar Refeição'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedBabyId,
                decoration: const InputDecoration(
                  labelText: 'Baby',
                  border: OutlineInputBorder(),
                ),
                items: widget.babies
                    .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBabyId = v),
                validator: (v) => v == null ? 'Selecione um baby' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data e hora',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(dateLabel),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MealType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: MealType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              if (_selectedType == MealType.mamadeira) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _volumeController,
                  decoration: const InputDecoration(
                    labelText: 'Volume (ml)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o volume';
                    if (double.tryParse(v.trim()) == null) return 'Valor inválido';
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
