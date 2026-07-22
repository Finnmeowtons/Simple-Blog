import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app_router.dart';

import '../providers/count_provider.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Column(
        children: [
          Center(child: Text(context.watch<CountProvider>().count.toString())),
          Row(
            children: [
              FilledButton(
                onPressed: () {
                  context.read<CountProvider>().increment();
                  router.push("/login");
                },
                child: Text("Increment"),
              ),
              FilledButton(
                onPressed: () {
                  context.read<CountProvider>().decrement();
                },
                child: Text("Decrement"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
