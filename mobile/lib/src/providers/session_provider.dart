import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api.dart';

final sessionProvider = StateNotifierProvider<SessionController, bool>((ref) {
  return SessionController();
});

class SessionController extends StateNotifier<bool> {
  final ApiService _api = ApiService();

  SessionController() : super(false) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _api.isLoggedIn();
    state = loggedIn;
  }

  Future<void> login(String email, String password) async {
    final success = await _api.login(email, password);
    state = success;
  }

  Future<void> logout() async {
    await _api.logout();
    state = false;
  }
}
