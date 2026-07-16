import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/add_test_bloc.dart';

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
  String _category = AppLocalizations.canonicalCategories.first;
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
      final tr = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.cantSelectImage)),
      );
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      final tr = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.selectImagePrompt)),
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
    final tr = AppLocalizations.of(context);
    final cats = AppLocalizations.canonicalCategories;
    final localizedCats = tr.localizedCategories;

    return BlocConsumer<AddTestBloc, AddTestState>(
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr.appAddedSuccess)),
          );
          context.pop();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(tr.addApplication)),
          body: Stack(
            children: [
              SingleChildScrollView(
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
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                        tr.selectImage,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
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
                        label: tr.title,
                        validator: (v) =>
                            v?.trim().isEmpty == true ? tr.required : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _descCtrl,
                        label: tr.description,
                        maxLines: 3,
                        validator: (v) =>
                            v?.trim().isEmpty == true ? tr.required : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _playStoreCtrl,
                        label: tr.playStoreUrl,
                        validator: (v) {
                          if (v?.trim().isEmpty == true) return tr.required;
                          if (!v!.trim().startsWith(
                            'https://play.google.com/store/apps/',
                          )) {
                            return tr.validPlayStoreUrl;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: InputDecoration(labelText: tr.category),
                        items: [
                          for (int i = 0; i < cats.length; i++)
                            DropdownMenuItem(
                              value: cats[i],
                              child: Text(localizedCats[i]),
                            ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _category = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr.pointsInfo,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: tr.addMinus50,
                        isLoading: state.submitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
              if (state.submitting)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
