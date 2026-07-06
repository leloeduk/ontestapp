import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/test_app.dart';
import '../bloc/edit_test_bloc.dart';

const _categories = [
  'Divertissement',
  'Jeux',
  'Réseaux sociaux',
  'Utilitaires',
  'Éducation',
  'Productivité',
  'Musique',
  'Photographie',
  'Shopping',
  'Voyage',
  'Sport',
  'Videogames',
  'Autre',
];

class EditTestPage extends StatefulWidget {
  const EditTestPage({super.key, required this.test});

  final TestApp test;

  @override
  State<EditTestPage> createState() => _EditTestPageState();
}

class _EditTestPageState extends State<EditTestPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _category;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.test.title);
    _descCtrl = TextEditingController(text: widget.test.description);
    _category = widget.test.category.isNotEmpty
        ? widget.test.category
        : _categories.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditTestBloc, EditTestState>(
      listener: (context, state) {
        if (state.status == EditTestStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application modifiée')),
          );
          context.pop();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Modifier l\'application')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Titre',
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _descCtrl,
                label: 'Description',
                maxLines: 3,
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration:
                    const InputDecoration(labelText: 'Catégorie'),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 24),
              BlocBuilder<EditTestBloc, EditTestState>(
                builder: (context, state) {
                  return AppButton(
                    label: 'Enregistrer',
                    isLoading: state.status == EditTestStatus.submitting,
                    onPressed: () {
                      context.read<EditTestBloc>().add(EditTestSubmitted(
                            testId: widget.test.id,
                            title: _titleCtrl.text.trim(),
                            description: _descCtrl.text.trim(),
                            category: _category,
                          ));
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
