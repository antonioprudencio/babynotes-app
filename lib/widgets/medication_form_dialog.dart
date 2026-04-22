import 'package:flutter/material.dart';
import '../domain/models/baby.dart';
import '../domain/models/medication.dart';

class MedicationFormDialog extends StatefulWidget {
  final List<Baby> babies;
  final Medication? initialMedication;

  const MedicationFormDialog({super.key, required this.babies, this.initialMedication});

  @override
  State<MedicationFormDialog> createState() => _MedicationFormDialogState();
}

class _MedicationFormDialogState extends State<MedicationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();

  late String? _selectedBabyId;
  late DateTime _selectedDateTime;
  late DoseUnit _selectedUnit;

  @override
  void initState() {
    super.initState();
    final med = widget.initialMedication;
    _selectedBabyId = med?.babyId ?? (widget.babies.isNotEmpty ? widget.babies.first.id : null);
    _selectedDateTime = med?.dateTime ?? DateTime.now();
    _selectedUnit = med?.unit ?? DoseUnit.ml;
    _nameController.text = med?.name ?? '';
    _doseController.text = med?.dose.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
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
      final medication = Medication(
        id: widget.initialMedication?.id ?? '',
        babyId: _selectedBabyId!,
        dateTime: _selectedDateTime,
        name: _nameController.text.trim(),
        dose: double.parse(_doseController.text.trim()),
        unit: _selectedUnit,
      );
      Navigator.of(context).pop(medication);
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
      title: Text(widget.initialMedication == null ? 'Registrar Medicamento' : 'Editar Medicamento'),
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicamento',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o medicamento' : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _doseController,
                      decoration: const InputDecoration(
                        labelText: 'Dose',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe a dose';
                        if (double.tryParse(v.trim()) == null) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    child: DropdownButtonFormField<DoseUnit>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: OutlineInputBorder(),
                      ),
                      items: DoseUnit.values
                          .map((u) => DropdownMenuItem(value: u, child: Text(u.label)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedUnit = v!),
                    ),
                  ),
                ],
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
