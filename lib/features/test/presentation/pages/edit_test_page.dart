import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/test_app.dart';
import '../bloc/edit_test_bloc.dart';

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
    _category = widget.test.category;
    if (!AppLocalizations.canonicalCategories.contains(_category)) {
      _category = AppLocalizations.canonicalCategories.first;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final cats = AppLocalizations.canonicalCategories;
    final localizedCats = tr.localizedCategories;

    return BlocConsumer<EditTestBloc, EditTestState>(
      listener: (context, state) {
        if (state.status == EditTestStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr.appEdited)),
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
        final submitting = state.status == EditTestStatus.submitting;
        return Scaffold(
          appBar: AppBar(title: Text(tr.editApp)),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const SizedBox(height: 24),
                    AppButton(
                      label: tr.editSave,
                      isLoading: submitting,
                      onPressed: () {
                        context.read<EditTestBloc>().add(EditTestSubmitted(
                              testId: widget.test.id,
                              title: _titleCtrl.text.trim(),
                              description: _descCtrl.text.trim(),
                              category: _category,
                            ));
                      },
                    ),
                  ],
                ),
              ),
              if (submitting)
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
