import 'package:go_router/go_router.dart';
import 'package:simple_blog/screens/counter_screen.dart';
import 'package:simple_blog/screens/login_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => CounterScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
  ],
);