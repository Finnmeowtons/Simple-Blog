import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/screens/counter_screen.dart';

import 'providers/count_provider.dart';
import 'app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CountProvider())
      ],
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Simple Blog',
        theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        ),
      ),
    );
  }
}


