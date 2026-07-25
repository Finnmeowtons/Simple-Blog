import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_blog/providers/auth_provider.dart';
import 'package:simple_blog/screens/auth_screen.dart';
import 'package:simple_blog/screens/forum_screen.dart';
import 'enums/auth_mode.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const ForumScreen(),
      ),

      GoRoute(
        path: '/auth',
        builder: (_, _) =>
        const AuthScreen(
          initialMode: AuthMode.login,
        ),
      ),

      GoRoute(
        path: '/auth/register',
        builder: (_, _) =>
        const AuthScreen(
          initialMode: AuthMode.register,
        ),
      ),
    ],
  );
}