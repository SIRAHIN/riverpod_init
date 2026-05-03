import 'package:flutter/material.dart';

/// ---------------------------------------------------------------
/// SearchScreen — Tab 2 (Search)
/// ---------------------------------------------------------------
/// This is the second tab in the bottom navigation bar.
/// It represents the "Search" section of the app.
/// Replace the body content with your actual search UI.
/// ---------------------------------------------------------------
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Search Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
