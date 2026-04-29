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
    _fetchStoredCredentials();
  }

  // fetch stored credentials on widget initialization to pre-fill the text fields if credentials are available.
  Future<void> _fetchStoredCredentials() async {
    final credentials =
        await ref.read(authRepositoryProvider).authLocalService.getUserCredential();
    if (credentials != null) {
      emailController.text = credentials.email;
      passwordController.text = credentials.password;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watching the auth state to update the UI based on loading, success, or failure states.
    final authState = ref.watch(authStateProvider);

    // Listening to auth state changes to show appropriate SnackBar messages.
    ref.listen(authStateProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      if (next is AsyncError) {
        messenger.showSnackBar(SnackBar(content: Text("${next.error}")));
      } else if (next is AsyncData) {
        messenger
            .showSnackBar(const SnackBar(content: Text("Login Successful")));
      }
    });

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
                onPressed: authState is AsyncLoading
                    ? null
                    : () {
                        ref.read(authStateProvider.notifier).login(
                              userName: emailController.text,
                              password: passwordController.text,
                            );
                      },
                child: authState is AsyncLoading
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
