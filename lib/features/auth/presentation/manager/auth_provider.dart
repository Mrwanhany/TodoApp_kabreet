import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app_kabreet/features/auth/data/model/user_model.dart';
import 'package:todo_app_kabreet/features/auth/data/service/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _authService.getUserData(firebaseUser.uid);
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result =
          await _authService.signInWithEmailPassword(email, password);
      return result != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmailPassword(
      String email, String password, String displayName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.registerWithEmailPassword(
          email, password, displayName);
      return result != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
