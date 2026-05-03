import 'package:flutter/material.dart';

/// ---------------------------------------------------------------
/// HomeScreen — Tab 1 (Home)
/// ---------------------------------------------------------------
/// This is the first tab in the bottom navigation bar.
/// It represents the "Home" section of the app.
/// Replace the body content with your actual home screen UI.
/// ---------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Home Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
