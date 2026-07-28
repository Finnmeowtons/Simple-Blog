import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../enums/auth_mode.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  final AuthMode initialMode;
  const AuthScreen({super.key, required this.initialMode});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode mode;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    mode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: mode == AuthMode.login ? _buildLogin() : _buildRegister()),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      title: InkWell(
        child: const Text("Forum"),
        onTap: () {
          context.go('/');
        },
      ),
      centerTitle: true,
    );
  }

  Widget _buildLogin() {
    return SizedBox(
      width: 400,
      height: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Login",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black),
          ),
          const SizedBox(height: 16),
          emailPasswordForm(),

          const SizedBox(height: 16),

          Consumer<AuthProvider>(
            builder: (_, auth, _) {
              return Column(
                children: [

                  if (auth.error != null)
                    Text(
                      auth.error!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: auth.loading ? null : _submitForm, child: auth.loading ? const CircularProgressIndicator() : const Text("Login")),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              context.push('/auth/register');
            },
            child: const Text("No account yet?"),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister() {
    return SizedBox(
      width: 400,
      height: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Register",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black),
          ),
          const SizedBox(height: 16),
          emailPasswordForm(),

          const SizedBox(height: 16),

          Consumer<AuthProvider>(
            builder: (_, auth, _) {
              return Column(
                children: [
                  if (auth.error != null)
                    Text(
                      auth.error!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),

                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.loading ? null : _submitForm,
                      child: auth.loading ? const CircularProgressIndicator() : const Text("Register"),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text("Already have an account?"),
          ),
        ],
      ),
    );
  }

  Widget emailPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Email"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter an email";
              } else if (!emailRegex.hasMatch(value)) {
                return "Please enter a valid email";
              }
              return null;
            },
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: "Password"),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (mode == AuthMode.login) {
                _submitForm();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a password";
              } else if (value.length < 6) {
                return mode == AuthMode.register ? "Password must be at least 6 characters" : null;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    print("submitting form. Is Login ${mode == AuthMode.login}2");
    final success = mode == AuthMode.login
        ? await context.read<AuthProvider>().login(email: _emailController.text.trim(), password: _passwordController.text)
        : await context.read<AuthProvider>().register(email: _emailController.text.trim(), password: _passwordController.text);
    print("submitting form. Is Login ${mode == AuthMode.login}");

    if (success && context.mounted) {
      Navigator.pop(context);
    }
  }
}
