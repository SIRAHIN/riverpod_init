import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ---------------------------------------------------------------
/// MainNavShell — The Bottom Navigation Bar Container
/// ---------------------------------------------------------------
/// This is the "shell" widget that wraps all tab screens.
/// It contains the BottomNavigationBar at the bottom and displays
/// the current tab's content in the body area.
///
/// HOW IT WORKS:
/// - `navigationShell` is provided by GoRouter's StatefulShellRoute.
///   It manages which tab is currently displayed and handles switching.
/// - When the user taps a tab, we call `navigationShell.goBranch(index)`
///   which tells GoRouter to switch to that tab's branch.
/// - The `currentIndex` property tells us which tab is active,
///   so we can highlight the correct tab in the BottomNavigationBar.
///
/// WHY StatefulNavigationShell instead of a simple index?
/// - StatefulNavigationShell preserves each tab's navigation stack.
///   For example, if you push a details page on the Home tab,
///   switch to Profile tab, then come back to Home — the details
///   page is still there. With a simple index, you'd lose that state.
/// ---------------------------------------------------------------
class MainNavShell extends StatelessWidget {
  // The navigation shell from GoRouter's StatefulShellRoute.
  final StatefulNavigationShell navigationShell;

  const MainNavShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Step 1: The body displays the current tab's content.
      // navigationShell automatically shows the correct branch's widget.
      body: navigationShell,

      // Step 2: The bottom navigation bar for switching tabs.
      bottomNavigationBar: BottomNavigationBar(
        // currentIndex: Which tab is currently selected.
        // navigationShell.currentIndex gives us the active tab index.
        currentIndex: navigationShell.currentIndex,

        // onTap: Called when user taps a tab.
        // goBranch switches to the specified tab branch.
        // The `initialLocation: true` parameter resets the tab
        // to its initial route when tapped again (like Instagram).
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },

        // 3 tabs = 3 BottomNavigationBarItems
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],

        // Styling
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
