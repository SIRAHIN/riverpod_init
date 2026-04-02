import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/provider/auth_state.dart';
import 'package:riverpod_practice/provider/auth_state_notifer.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Listening to auth state changes to show appropriate SnackBar messages.
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);

      if (next is AuthSuccess) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(content: Text("Login Successful")),
        );
      }

      if (next is AuthFailure) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(content: Text(next.errorMessage)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // Watching the auth state to update the UI based on loading, success, or failure states.
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: emailController),
            const SizedBox(height: 16),
            TextField(controller: passwordController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authState is AuthLoading
                    ? null
                    : () {
                        ref.read(authStateProvider.notifier).login(
                              userName: emailController.text,
                              password: passwordController.text,
                            );
                      },
                child: authState is AuthLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
