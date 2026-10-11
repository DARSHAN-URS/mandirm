import 'package:flutter/material.dart';
import 'core/l10n/locale_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/splash/screens/splash_screen.dart';
import 'services/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AuthService().initialize();
  } catch (e) {
    debugPrint('AuthService initialization error: $e');
  }

  // Initialize saved language preference (English/Hindi)
  await LocaleService().initialize();

  runApp(const AstrologerApp());
}

class AstrologerApp extends StatelessWidget {
  const AstrologerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocaleService().locale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Mandirm Astrologer Portal',
          debugShowCheckedModeBanner: false,
          theme: AstrologerTheme.darkTheme,
          home: const AstrologerSplashScreen(),
        );
      },
    );
  }
}
