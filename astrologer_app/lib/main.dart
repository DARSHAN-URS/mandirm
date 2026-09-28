import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/home/screens/main_hub_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey, // ignore: deprecated_member_use
      );
    } catch (e) {
      debugPrint('Supabase init warning: $e');
    }
  }

  runApp(const AstrologerApp());
}

class AstrologerApp extends StatelessWidget {
  const AstrologerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mandiram Astrologer Portal',
      debugShowCheckedModeBanner: false,
      theme: AstrologerTheme.darkTheme,
      home: const AstrologerMainHubScreen(),
    );
  }
}
