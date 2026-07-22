import 'package:flutter/cupertino.dart';
import 'package:simple_blog/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(){
    loadCurrentUser();
  }
  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;

  bool _loading = false;
  User? _user;
  String? _error;

  final _authService = AuthService();

  Future<bool> login({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email: email, password: password);

      _user = response.user;

      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = "Something went wrong.";
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(email: email, password: password);
      _user = response.user;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = "Something went wrong.";
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();

    try {
      await _authService.logout();

      _user = null;
    }
    finally {
      _loading = false;
      notifyListeners();
    }
  }

  void loadCurrentUser() {
    _user = _authService.getCurrentUser();
    notifyListeners();
  }
}
