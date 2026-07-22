import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> register({required String email, required String password}) async {
    final response = await supabase.auth.signUp(email: email, password: password);
    return response;
  }

  Future<AuthResponse> login({required String email, required String password}) async {
    final response = await supabase.auth.signInWithPassword(email: email, password: password);
    return response;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
