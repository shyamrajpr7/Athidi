import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/constants/supabase_config.dart';
import 'package:athidhi/providers/auth_provider.dart';
import 'package:athidhi/providers/event_provider.dart';
import 'package:athidhi/providers/guest_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  runApp(const AthidhiApp());
}

class AthidhiApp extends StatelessWidget {
  const AthidhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),
      ],
      child: MaterialApp(
        title: 'Athidhi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
