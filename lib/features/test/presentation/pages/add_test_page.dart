import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/add_test_bloc.dart';

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

class AddTestPage extends StatefulWidget {
  const AddTestPage({super.key});

  @override
  State<AddTestPage> createState() => _AddTestPageState();
}

class _AddTestPageState extends State<AddTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _playStoreCtrl = TextEditingController();
  String _category = _categories.first;
  String? _imagePath;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _playStoreCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );
      if (picked != null) {
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de sélectionner l\'image')),
      );
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une image')),
      );
      return;
    }
    final uid = context.read<AuthBloc>().state.user.uid;
    context.read<AddTestBloc>().add(
      AddTestSubmitted(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imagePath: _imagePath!,
        playStoreUrl: _playStoreCtrl.text.trim(),
        category: _category,
        userId: uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddTestBloc, AddTestState>(
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application ajoutée avec succès')),
          );
          context.pop();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Ajouter une application')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: _imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sélectionner une image',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _titleCtrl,
                  label: 'Titre',
                  validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  maxLines: 3,
                  validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _playStoreCtrl,
                  label: 'URL Play Store',
                  validator: (v) {
                    if (v?.trim().isEmpty == true) return 'Requis';
                    if (!v!.trim().startsWith(
                      'https://play.google.com/store/apps/',
                    )) {
                      return 'URL Play Store valide :https://play.google.com/store/apps/';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: _categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  '10 points gagnés par test terminé • 50 points déduits à l\'ajout',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AddTestBloc, AddTestState>(
                  builder: (context, state) {
                    return AppButton(
                      label: 'Ajouter (-50 points)',
                      isLoading: state.submitting,
                      onPressed: _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
