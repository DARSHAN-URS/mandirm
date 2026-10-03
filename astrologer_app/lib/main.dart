import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/home/screens/main_hub_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ndjvkzrxgmxsdrbyeyim.supabase.co',
  );
  const supabaseKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kanZrenJ4Z214c2RyYnlleWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1MDE2NTcsImV4cCI6MjEwNjA3NzY1N30.sokDKK8Lnh36oKHt6Yq8_6ImmUXhwJ72FyU0NHsR3w0',
  );

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
      title: 'Mandirm Astrologer Portal',
      debugShowCheckedModeBanner: false,
      theme: AstrologerTheme.darkTheme,
      home: const AstrologerMainHubScreen(),
    );
  }
}
