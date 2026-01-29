import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart'; // You'll create this next
import '../../widgets/common/custom_button.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join the Squad')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is RegistrationSuccess) {
            // SRS Source 8: "Registration successful. Please verify your email."
            context.go('/auth/verify-email'); 
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Create your profile",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Email Field
                  FormBuilderTextField(
                    name: 'email',
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(), // FR-1.3
                    ]),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  FormBuilderTextField(
                    name: 'password',
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                      helperText: 'Min 8 chars, 1 uppercase, 1 number, 1 special',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(8), // FR-1.4
                      // Custom regex for SRS complexity requirements (Source 7)
                      (val) {
                         if (val != null && !RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(val)) {
                           return 'Password too weak';
                         }
                         return null;
                      }
                    ]),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date of Birth Field (FR-1.7)
                  FormBuilderDateTimePicker(
                    name: 'dateOfBirth',
                    inputType: InputType.date,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      (val) {
                        // Simple age check - logic for "Under 13" (FR-1.8) typically happens 
                        // here or in the BLoC to redirect to Parental Consent flow.
                        if (val != null) {
                          final age = DateTime.now().year - val.year;
                          if (age < 13) return 'Parental consent required for ages < 13';
                        }
                        return null;
                      }
                    ]),
                  ),
                  const SizedBox(height: 32),
                  
                  CustomButton(
                    text: 'Create Account',
                    onPressed: () {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        final data = _formKey.currentState!.value;
                        
                        context.read<AuthBloc>().add(
                          SignUpRequested(
                            email: data['email'],
                            password: data['password'],
                            dateOfBirth: data['dateOfBirth'],
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