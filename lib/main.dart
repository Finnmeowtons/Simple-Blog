import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/providers/auth_provider.dart';

import 'providers/count_provider.dart';
import 'app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async  {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: 'https://sbedaspvqgrsdmhsrxdr.supabase.co',
      publishableKey: 'sb_publishable_rFukfueQLey_GcXg-_p9hA_svYmUuNm',
      );

  final authProvider = AuthProvider();
  runApp(ChangeNotifierProvider.value(
      value: authProvider,
      child: MyApp(authProvider: authProvider,)
  ),);
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: createRouter(authProvider),
      title: 'Simple Blog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}


