import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athidhi/services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  codeSent,
  authenticated,
  unauthenticated,
  error
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  String _phoneNumber = '';

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get phoneNumber => _phoneNumber;
  bool get isAuthenticated => _authService.isLoggedIn;
  String? get userId => _authService.userId;

  AuthProvider() {
    _checkAuth();
  }

  void _checkAuth() {
    final session = Supabase.instance.client.auth.currentSession;
    _status =
        session != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
    _status = AuthStatus.loading;
    _phoneNumber = phone;
    _errorMessage = '';
    notifyListeners();

    await _authService.sendOtp(
      phoneNumber: phone,
      onCodeSent: () {
        _status = AuthStatus.codeSent;
        notifyListeners();
      },
      onError: (error) {
        _status = AuthStatus.error;
        _errorMessage = error;
        notifyListeners();
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final success = await _authService.verifyOtp(
      phoneNumber: _phoneNumber,
      otp: otp,
    );

    if (success) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.error;
      _errorMessage = 'Invalid OTP. Please try again.';
    }
    notifyListeners();
    return success;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
