import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/sign_in_screen.dart';
import '../../presentation/screens/auth/sign_up_screen.dart';
import '../../presentation/screens/home/home_shell.dart';
import '../../presentation/screens/home/today_screen.dart';
import '../../presentation/screens/home/partner_screen.dart';
import '../../presentation/screens/home/gcal_screen.dart';
import '../../presentation/screens/home/events_screen.dart';
import '../../presentation/screens/home/settings_screen.dart';
import '../../presentation/screens/events/create_event_screen.dart';
import '../../presentation/screens/events/event_detail_screen.dart';
import '../../presentation/screens/partner/partner_link_screen.dart';
import '../../presentation/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    redirect: (context, state) {
      final isSignedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation.startsWith('/sign');
      if (!isSignedIn && !isOnAuth) return '/sign-in';
      if (isSignedIn && isOnAuth) return '/home/today';
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (_, __) => const SignUpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home/today',
              builder: (_, __) => const TodayScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home/partner',
              builder: (_, __) => const PartnerScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home/gcal',
              builder: (_, __) => const GCalScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home/events',
              builder: (_, __) => const EventsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/event/create',
        builder: (_, state) => CreateEventScreen(
          initialDate: state.extra as DateTime?,
        ),
      ),
      GoRoute(
        path: '/event/:id',
        builder: (_, state) => EventDetailScreen(
          eventId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/partner-link',
        builder: (_, __) => const PartnerLinkScreen(),
      ),
    ],
  );
});
