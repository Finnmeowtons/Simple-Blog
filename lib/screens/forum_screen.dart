import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forum"),
          centerTitle: true,
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: (){
            context.read<AuthProvider>().logout();
          }, child: Text("Logout"))
        ],
      ),
    );
  }
}
