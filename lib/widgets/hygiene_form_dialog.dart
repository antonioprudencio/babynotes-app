import 'package:flutter/material.dart';
import '../domain/models/baby.dart';
import '../domain/models/hygiene.dart';

class HygieneFormDialog extends StatefulWidget {
  final List<Baby> babies;
  final Hygiene? initialHygiene;

  const HygieneFormDialog({super.key, required this.babies, this.initialHygiene});

  @override
  State<HygieneFormDialog> createState() => _HygieneFormDialogState();
}

class _HygieneFormDialogState extends State<HygieneFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _observationController = TextEditingController();

  late String? _selectedBabyId;
  late DateTime _selectedDateTime;
  late HygieneType _selectedType;

  @override
  void initState() {
    super.initState();
    final h = widget.initialHygiene;
    _selectedBabyId = h?.babyId ?? (widget.babies.isNotEmpty ? widget.babies.first.id : null);
    _selectedDateTime = h?.dateTime ?? DateTime.now();
    _selectedType = h?.type ?? HygieneType.banho;
    _observationController.text = h?.observation ?? '';
  }

  @override
  void dispose() {
    _observationController.dispose();
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
      final observation = _observationController.text.trim();
      Navigator.of(context).pop(
        Hygiene(
          id: widget.initialHygiene?.id ?? '',
          babyId: _selectedBabyId!,
          dateTime: _selectedDateTime,
          type: _selectedType,
          observation: observation.isEmpty ? null : observation,
        ),
      );
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
      title: Text(widget.initialHygiene == null ? 'Registrar Higiene' : 'Editar Higiene'),
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
              DropdownButtonFormField<HygieneType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: HygieneType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observationController,
                decoration: const InputDecoration(
                  labelText: 'Observação (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
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
