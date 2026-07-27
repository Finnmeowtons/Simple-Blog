import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/providers/auth_provider.dart';
import 'package:simple_blog/providers/comment_provider.dart';
import 'package:simple_blog/providers/post_provider.dart';

import 'minimal_theme.dart';
import 'app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: 'https://sbedaspvqgrsdmhsrxdr.supabase.co', publishableKey: 'sb_publishable_rFukfueQLey_GcXg-_p9hA_svYmUuNm');

  final authProvider = AuthProvider();

  // debugPrintRebuildDirtyWidgets = true;
  runApp(
    MyApp(authProvider: authProvider),
  );
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: authProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentProvider(),
        ),
      ],
      child: MaterialApp.router(
        showPerformanceOverlay: true,
        routerConfig: createRouter(authProvider),
        debugShowCheckedModeBanner: false,
        title: 'Simple Blog',
        theme: MinimalTheme.light,
      ),
    );
  }
}
