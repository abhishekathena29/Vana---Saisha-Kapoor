import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// UI-facing state for sign-in/out. Wraps [AuthService] (the raw Firebase
/// calls) and also doubles as GoRouter's `refreshListenable`, since it
/// already re-notifies on every `authStateChanges()` event.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _authSub = AuthService.instance.authStateChanges.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _authSub;

  bool isLoading = false;
  String? errorMessage;

  User? get currentUser => AuthService.instance.currentUser;
  bool get isSignedIn => AuthService.instance.isSignedIn;
  String get displayName => AuthService.instance.displayName;

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _run(() => AuthService.instance.signIn(email: email, password: password));
  }

  Future<bool> signUp({required String name, required String email, required String password}) async {
    return _run(() => AuthService.instance.signUp(name: name, email: email, password: password));
  }

  Future<bool> sendPasswordReset(String email) async {
    return _run(() => AuthService.instance.sendPasswordReset(email));
  }

  Future<void> signOut() => AuthService.instance.signOut();

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      errorMessage = AuthService.instance.friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
