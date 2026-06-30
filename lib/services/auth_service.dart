import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  bool get isLoggedIn => _client.auth.currentSession != null;
  String? get userId => _client.auth.currentUser?.id;

  Future<void> sendOtp({
    required String phoneNumber,
    VoidCallback? onCodeSent,
    void Function(String)? onError,
  }) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phoneNumber,
      );
      onCodeSent?.call();
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );
      return response.session != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
