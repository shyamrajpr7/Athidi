import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/auth_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/screens/auth/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Language toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => lang.toggleLanguage(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lang.isMalayalam ? 'English' : 'മലയാളം',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.location_on,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 28),
              Text(
                lang.t('സ്വാഗതം', 'Welcome'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang.t('നിങ്ങളുടെ ഫോൺ നമ്പർ നൽകുക', 'Enter your phone number'),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 40),
              // Phone input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: const Text(
                        '🇮🇳 +91',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: lang.t('ഫോൺ നമ്പർ', 'Phone Number'),
                          hintStyle:
                              const TextStyle(color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          counterText: '',
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          letterSpacing: 2,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Error message
              if (auth.status == AuthStatus.error)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    auth.errorMessage,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleContinue,
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
                          lang.t('തുടരുക', 'Continue'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  lang.t(
                    'തുടരുന്നതിലൂടെ നിങ്ങൾ ഞങ്ങളുടെ നിബന്ധനകൾ അംഗീകരിക്കുന്നു',
                    'By continuing you agree to our Terms & Privacy Policy',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue() async {
    if (_phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().t(
                  '10 അക്ക നമ്പർ നൽകുക',
                  'Please enter a valid 10-digit number',
                ),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    await context.read<AuthProvider>().sendOtp(_phoneController.text);
    if (mounted && context.read<AuthProvider>().status == AuthStatus.codeSent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OtpScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
