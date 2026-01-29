import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/custom_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  final String? token; // passed via deep link parameter if available

  VerifyEmailScreen({super.key, this.token});

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    // If deep link provided a token immediately, verify it
    if (token != null) {
      context.read<AuthBloc>().add(VerifyEmailRequested(token!));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Success! Redirecting to login...")),
            );
            context.go('/auth/login');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                "Check your inbox",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "We sent a verification code to your email. Enter it below or click the link in the email.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              FormBuilder(
                key: _formKey,
                initialValue: {'token': token},
                child: FormBuilderTextField(
                  name: 'token',
                  decoration: const InputDecoration(
                    labelText: 'Verification Token',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
              ),
              const SizedBox(height: 24),
              
              CustomButton(
                text: 'Verify',
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final tokenInput = _formKey.currentState!.value['token'];
                    context.read<AuthBloc>().add(VerifyEmailRequested(tokenInput));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}