import 'package:go_router/go_router.dart';
import 'package:simple_blog/providers/auth_provider.dart';
import 'package:simple_blog/screens/forum_screen.dart';
import 'package:simple_blog/screens/login_screen.dart';
import 'package:simple_blog/screens/register_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,

    redirect: (context, state)  {
      final loggedIn = authProvider.user != null;

      final isAuthRoute =
          state.matchedLocation == '/' ||
              state.matchedLocation == '/register';

      if (!loggedIn && !isAuthRoute) {
        return '/';
      }

      if (loggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ForumScreen(),
      ),
    ],
  );
}