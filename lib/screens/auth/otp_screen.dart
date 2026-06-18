import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/auth_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/screens/host/host_dashboard.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _canResend = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) _canResend = true;
      });
      return _resendSeconds > 0;
    });
  }

  void _onDigitEntered(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) _handleVerify();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                lang.t('കോഡ് നൽകുക', 'Enter OTP'),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lang.t(
                  '+91 ${auth.phoneNumber} എന്ന നമ്പരിലേക്ക് OTP അയച്ചു',
                  'OTP sent to +91 ${auth.phoneNumber}',
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),
              const SizedBox(height: 16),
              if (auth.status == AuthStatus.error)
                Text(
                  auth.errorMessage,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          lang.t('സ്ഥിരീകരിക്കുക', 'Verify'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: _canResend
                    ? GestureDetector(
                        onTap: () {
                          context
                              .read<AuthProvider>()
                              .sendOtp(auth.phoneNumber);
                          _startResendTimer();
                        },
                        child: Text(
                          lang.t('വീണ്ടും അയക്കുക', 'Resend OTP'),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Text(
                        lang.t(
                          '$_resendSeconds സെക്കൻഡിൽ വീണ്ടും അയക്കാം',
                          'Resend in $_resendSeconds seconds',
                        ),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: (value) => _onDigitEntered(value, index),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  void _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    final success = await context.read<AuthProvider>().verifyOtp(otp);
    if (mounted && success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HostDashboard()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }
}
