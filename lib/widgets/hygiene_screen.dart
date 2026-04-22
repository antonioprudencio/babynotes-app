import 'package:flutter/material.dart';
import '../view_model/baby_view_model.dart';
import '../view_model/hygiene_view_model.dart';
import '../domain/models/hygiene.dart';
import 'date_filter_bar.dart';
import 'hygiene_form_dialog.dart';

class HygieneScreen extends StatefulWidget {
  final HygieneViewModel hygieneViewModel;
  final BabyViewModel babyViewModel;
  final bool showAppBar;

  const HygieneScreen({
    super.key,
    required this.hygieneViewModel,
    required this.babyViewModel,
    this.showAppBar = true,
  });

  @override
  State<HygieneScreen> createState() => _HygieneScreenState();
}

class _HygieneScreenState extends State<HygieneScreen> {
  DateFilter _filter = DateFilter.hoje;

  @override
  void initState() {
    super.initState();
    widget.hygieneViewModel.addListener(_onUpdate);
    widget.babyViewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.hygieneViewModel.removeListener(_onUpdate);
    widget.babyViewModel.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  String _babyName(String babyId) {
    return widget.babyViewModel.babies
        .firstWhere((b) => b.id == babyId, orElse: () => throw Exception())
        .name;
  }

  Future<void> _openForm({Hygiene? hygiene}) async {
    final babies = widget.babyViewModel.babies;

    if (babies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um baby antes de registrar uma higiene.')),
      );
      return;
    }

    final result = await showDialog<Hygiene>(
      context: context,
      builder: (_) => HygieneFormDialog(babies: babies, initialHygiene: hygiene),
    );

    if (result == null) return;

    if (hygiene == null) {
      widget.hygieneViewModel.add(result);
    } else {
      widget.hygieneViewModel.update(result);
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar registro'),
        content: const Text('Deseja apagar este registro de higiene?'),
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
              widget.hygieneViewModel.delete(id);
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hygienes = widget.hygieneViewModel.hygienes
        .where((h) => _filter.matches(h.dateTime))
        .toList();

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Higiene'),
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
            child: hygienes.isEmpty
                ? const Center(child: Text('Nenhum registro de higiene.'))
                : ListView.separated(
                    itemCount: hygienes.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final h = hygienes[index];
                      final dateLabel =
                          '${h.dateTime.day.toString().padLeft(2, '0')}/'
                          '${h.dateTime.month.toString().padLeft(2, '0')}/'
                          '${h.dateTime.year}  '
                          '${h.dateTime.hour.toString().padLeft(2, '0')}:'
                          '${h.dateTime.minute.toString().padLeft(2, '0')}';
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.water_drop_outlined)),
                        title: Text(h.type.label),
                        subtitle: Text(
                          '${_babyName(h.babyId)} · $dateLabel'
                          '${h.observation != null ? '\n${h.observation}' : ''}',
                        ),
                        isThreeLine: h.observation != null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Editar',
                              onPressed: () => _openForm(hygiene: h),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              tooltip: 'Apagar',
                              onPressed: () => _confirmDelete(h.id),
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
        tooltip: 'Registrar higiene',
        child: const Icon(Icons.add),
      ),
    );
  }
}
