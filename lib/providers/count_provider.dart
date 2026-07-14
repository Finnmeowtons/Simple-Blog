import 'package:flutter/material.dart';

class CountProvider extends ChangeNotifier {
  int count = 0;

  CountProvider({
    this.count = 0,
  });

  void increment() {
    count++;
    notifyListeners(); // Notify all listeners about the change
  }

  void decrement() {
    count--;
    notifyListeners();
  }
}