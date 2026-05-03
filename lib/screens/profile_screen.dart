import 'package:flutter/material.dart';

/// ---------------------------------------------------------------
/// ProfileScreen — Tab 3 (Profile)
/// ---------------------------------------------------------------
/// This is the third tab in the bottom navigation bar.
/// It represents the "Profile" section of the app.
/// Replace the body content with your actual profile UI.
/// ---------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Profile Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
