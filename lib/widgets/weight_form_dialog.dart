import 'package:flutter/material.dart';
import '../domain/models/baby.dart';
import '../domain/models/weight_record.dart';

class WeightFormDialog extends StatefulWidget {
  final List<Baby> babies;
  final WeightRecord? initialRecord;

  const WeightFormDialog({super.key, required this.babies, this.initialRecord});

  @override
  State<WeightFormDialog> createState() => _WeightFormDialogState();
}

class _WeightFormDialogState extends State<WeightFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  late String? _selectedBabyId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRecord;
    _selectedBabyId = r?.babyId ?? (widget.babies.isNotEmpty ? widget.babies.first.id : null);
    _selectedDate = r?.date ?? DateTime.now();
    _weightController.text = r?.weightKg.toString() ?? '';
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(
        WeightRecord(
          id: widget.initialRecord?.id ?? '',
          babyId: _selectedBabyId!,
          date: _selectedDate,
          weightKg: double.parse(_weightController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';

    return AlertDialog(
      title: Text(widget.initialRecord == null ? 'Registrar Peso' : 'Editar Peso'),
      content: Form(
        key: _formKey,
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
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(dateLabel),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o peso';
                if (double.tryParse(v.trim()) == null) return 'Valor inválido';
                return null;
              },
            ),
          ],
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
