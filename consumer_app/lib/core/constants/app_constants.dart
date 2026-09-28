class AppConstants {
  AppConstants._();

  static const String appName = 'Mandiram';
  static const String appTagline = 'Connect with the Divine • Mandir, Puja & Astrology';

  // Supabase Configuration
  // Can be passed via --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=...
  // Default values can be replaced with your live Supabase project credentials.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  // Asset paths
  static const String logoAsset = 'assets/images/logo.jpeg';

  // Storage Keys
  static const String keyUserToken = 'user_access_token';
  static const String keyUserProfile = 'user_profile_data';
  static const String keyIsFirstTime = 'is_first_time_user';
  static const String keySavedPhone = 'saved_phone_number';

  // Default Country Code
  static const String defaultCountryCode = '+91';
}
