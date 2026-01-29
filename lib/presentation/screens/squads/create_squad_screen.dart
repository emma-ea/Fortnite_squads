import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/squad/squad_bloc.dart';
import '../../widgets/common/custom_button.dart';

class CreateSquadScreen extends StatelessWidget {
  const CreateSquadScreen({super.key});

  static final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assemble Squad')),
      body: BlocConsumer<SquadBloc, SquadState>(
        listener: (context, state) {
          if (state is SquadCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Squad created successfully!')),
            );
            context.pop(); // Return to previous screen
          } else if (state is SquadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SquadLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Create a New Squad",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Set up your team details to find the perfect match.",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),

                  // --- Squad Name (FR-3.2) ---
                  FormBuilderTextField(
                    name: 'squadName',
                    decoration: const InputDecoration(
                      labelText: 'Squad Name',
                      prefixIcon: Icon(Icons.shield_outlined),
                      border: OutlineInputBorder(),
                      helperText: '3-30 characters',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(30),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // --- Description (FR-3.4) ---
                  FormBuilderTextField(
                    name: 'description',
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      prefixIcon: Icon(Icons.description_outlined),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: FormBuilderValidators.maxLength(200),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // --- Max Size (FR-3.5) ---
                      Expanded(
                        child: FormBuilderDropdown<int>(
                          name: 'maxSize',
                          initialValue: 4,
                          decoration: const InputDecoration(
                            labelText: 'Max Players',
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.required(),
                          items: [2, 3, 4]
                              .map((size) => DropdownMenuItem(
                                    value: size,
                                    child: Text('$size Players'),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // --- Visibility (FR-3.9) ---
                      Expanded(
                        child: FormBuilderDropdown<String>(
                          name: 'visibility',
                          initialValue: 'PUBLIC',
                          decoration: const InputDecoration(
                            labelText: 'Visibility',
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.required(),
                          items: ['PUBLIC', 'PRIVATE', 'INVITE_ONLY']
                              .map((v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(
                                      v.replaceAll('_', ' ').toLowerCase().replaceFirst(
                                        v[0].toLowerCase(), 
                                        v[0].toUpperCase()
                                      ), // "Invite only" formatting
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Tags (FR-3.11) ---
                  FormBuilderTextField(
                    name: 'tags',
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)',
                      prefixIcon: Icon(Icons.label_outline),
                      border: OutlineInputBorder(),
                      hintText: 'competitive, mic-on, chill',
                    ),
                    // We'll process this string into a List<String> on submit
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Create Squad',
                    isLoading: isLoading,
                    onPressed: () {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        final data = _formKey.currentState!.value;
                        
                        // Parse tags string into list
                        List<String> tagsList = [];
                        if (data['tags'] != null && data['tags'].toString().isNotEmpty) {
                          tagsList = data['tags']
                              .toString()
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();
                        }

                        context.read<SquadBloc>().add(
                          CreateSquadRequested(
                            name: data['squadName'],
                            description: data['description'],
                            maxSize: data['maxSize'],
                            visibility: data['visibility'],
                            tags: tagsList,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}