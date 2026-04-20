import 'package:flutter/material.dart';
import '../view_model/baby_view_model.dart';
import '../../data/repositories/baby_repository.dart';
import 'baby_form_dialog.dart';

class BabiesScreen extends StatefulWidget {
  const BabiesScreen({super.key});

  @override
  State<BabiesScreen> createState() => _BabiesScreenState();
}

class _BabiesScreenState extends State<BabiesScreen> {
  late final BabyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BabyViewModel(BabyRepository());
    _viewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onUpdate);
    _viewModel.dispose();
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  Future<void> _openForm({String? id, String? name}) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => BabyFormDialog(
        title: id == null ? 'Cadastrar Baby' : 'Editar Baby',
        initialName: name,
      ),
    );

    if (result == null) return;

    if (id == null) {
      _viewModel.add(result);
    } else {
      _viewModel.update(id, result);
    }
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar baby'),
        content: Text('Deseja apagar "$name"?'),
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
              _viewModel.delete(id);
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final babies = _viewModel.babies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Babies'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: babies.isEmpty
          ? const Center(child: Text('Nenhum baby cadastrado.'))
          : ListView.separated(
              itemCount: babies.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final baby = babies[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.child_care)),
                  title: Text(baby.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar',
                        onPressed: () => _openForm(id: baby.id, name: baby.name),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        tooltip: 'Apagar',
                        onPressed: () => _confirmDelete(baby.id, baby.name),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        tooltip: 'Cadastrar baby',
        child: const Icon(Icons.add),
      ),
    );
  }
}
