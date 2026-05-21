import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_practice/registration_screen.dart';
import 'package:riverpod_practice/screens/main_nav_shell.dart';
import 'package:riverpod_practice/screens/home_screen.dart';
import 'package:riverpod_practice/screens/profile_screen.dart';
import 'package:riverpod_practice/screens/search_screen.dart';

/// ---------------------------------------------------------------
/// AppRouter — GoRouter Configuration
/// ---------------------------------------------------------------
/// This file defines ALL routes in the app using GoRouter.
///
/// KEY CONCEPTS:
///
/// 1. **StatefulShellRoute (Indexed Routing)**:
///    This is GoRouter's equivalent of a BottomNavigationBar.
///    It creates a "shell" that persists across tab switches,
///    so each tab's state (scroll position, text input, etc.)
///    is preserved when you switch tabs.
///
///    Without StatefulShellRoute, switching tabs would rebuild
///    the entire screen from scratch every time.
///
/// 2. **Route Structure**:
///    - `/home`     → HomeScreen (Tab 1)
///    - `/search`   → SearchScreen (Tab 2)
///    - `/profile`  → ProfileScreen (Tab 3)
///    - `/`         → Redirects to `/home` by default
///
/// 3. **Why GoRouter over Navigator?**
///    - Declarative routing (define routes once, not push/pop manually)
///    - Deep linking support (navigate to any route via URL)
///    - Type-safe route parameters
///    - Easy redirect logic (e.g., auth guards)
/// ---------------------------------------------------------------

// Step 1: Global navigation key for the root navigator.
// This allows GoRouter to control the root navigator from anywhere.
final rootNavigatorKey = GlobalKey<NavigatorState>();

// Step 2: Create individual navigator keys for each tab.
// Each tab needs its own navigator key so that navigation
// within a tab (e.g., pushing details page) doesn't affect
// other tabs. This is how StatefulShellRoute keeps tab
// navigators independent.
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

// Sep 3: Define the GoRouter instance.
// This is the central router configuration object.
//
// Properties explained:
// - initialLocation: The route shown when the app starts
// - navigatorKey: The root navigator key
// - routes: The list of all route definitions
GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',

  // Step 4: Define all routes.
  routes: [
    // StatefulShellRoute creates a persistent container for tabs.
    //
    // Parameters:
    // - builder: Builds the shell widget (MainNavShell) that wraps
    //   all tab content. This is where your BottomNavigationBar lives.
    // - branches: Each branch represents one tab with its own
    //   navigator and routes.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // navigationShell is the StatefulNavigationShell that manages
        // tab switching. We pass it to MainNavShell so the bottom nav
        // bar can call navigationShell.goBranch(index) to switch tabs.
        return MainNavShell(navigationShell: navigationShell);
      },

      // Each branch = one tab.
      // - navigatorKey: Isolated navigator for this tab
      // - routes: The routes available within this tab
      //   (first route is the default shown when switching to this tab)
      branches: [
        // --- TAB 1: Home ---
        StatefulShellBranch(
          navigatorKey: homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const RegistrationScreen(),
              // You can add sub-routes here, e.g.:
              // GoRoute(path: 'details', builder: ...)
            ),
          ],
        ),

        // --- TAB 2: Search ---
        StatefulShellBranch(
          navigatorKey: searchNavigatorKey,
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),

        // --- TAB 3: Profile ---
        StatefulShellBranch(
          navigatorKey: profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
