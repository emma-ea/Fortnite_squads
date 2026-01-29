import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/user/user_bloc.dart';
import '../../widgets/common/custom_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Simple compression
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile')),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdateSuccess) {
            context.go('/home'); // Redirect to main app on success
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  // --- Avatar Picker (Source 12, FR-1.23) ---
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Upload Avatar (Max 5MB)",
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 24),

                  // --- Username (Source 12, FR-1.18) ---
                  FormBuilderTextField(
                    name: 'username',
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(20),
                      FormBuilderValidators.match(RegExp(r'^[a-zA-Z0-9_]+$'),
                          errorText: "Alphanumeric & underscore only"),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // --- Epic Games ID (Source 12, FR-1.20) ---
                  FormBuilderTextField(
                    name: 'epicId',
                    decoration: const InputDecoration(
                      labelText: 'Epic Games ID',
                      prefixIcon: Icon(Icons.gamepad),
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // --- Region Dropdown (Source 12, FR-1.21) ---
                  FormBuilderDropdown<String>(
                    name: 'region',
                    decoration: const InputDecoration(
                      labelText: 'Region',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(),
                    items: [
                      'NA-East',
                      'NA-West',
                      'Europe',
                      'Oceania',
                      'Asia',
                      'Middle East'
                    ]
                        .map((region) => DropdownMenuItem(
                              value: region,
                              child: Text(region),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // --- Skill Level (Source 12, FR-1.27) ---
                  FormBuilderDropdown<String>(
                    name: 'skillLevel',
                    decoration: const InputDecoration(
                      labelText: 'Skill Level',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(),
                    items: ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT']
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // --- Preferred Modes (Source 12, FR-1.28) ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Preferred Game Modes",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  FormBuilderFilterChips<String>(
                    name: 'preferredModes',
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: FormBuilderValidators.required(),
                    spacing: 8.0,
                    options: const [
                      FormBuilderChipOption(
                          value: 'BATTLE_ROYALE', child: Text('Battle Royale')),
                      FormBuilderChipOption(
                          value: 'ZERO_BUILD', child: Text('Zero Build')),
                      FormBuilderChipOption(
                          value: 'CREATIVE', child: Text('Creative')),
                      FormBuilderChipOption(
                          value: 'RANKED', child: Text('Ranked')),
                    ],
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Complete Profile',
                    onPressed: () {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        final data = _formKey.currentState!.value;

                        context.read<UserBloc>().add(
                              UpdateProfileRequested(
                                username: data['username'],
                                epicId: data['epicId'],
                                region: data['region'],
                                skillLevel: data['skillLevel'],
                                preferredModes:
                                    List<String>.from(data['preferredModes']),
                                avatarFile: _selectedImage,
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
