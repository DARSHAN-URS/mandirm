class AppConstants {
  AppConstants._();

  static const String appName = 'Mandirm';
  static const String appTagline = 'Connect with the Divine • Astrologer Console';

  // Backend API URL (Production FastAPI backend)
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://api.mandirm.in/api/v1',
  );

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ndjvkzrxgmxsdrbyeyim.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kanZrenJ4Z214c2RyYnlleWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1MDE2NTcsImV4cCI6MjEwNjA3NzY1N30.sokDKK8Lnh36oKHt6Yq8_6ImmUXhwJ72FyU0NHsR3w0',
  );

  // Agora RTC Configuration (Voice & Video Consultations)
  static const String agoraAppId = String.fromEnvironment(
    'AGORA_APP_ID',
    defaultValue: 'aab8b8f3e2444655986872ff7e5a8711',
  );

  // CDN Configuration (Supabase Storage public bucket)
  static const String cdnBaseUrl = String.fromEnvironment(
    'CDN_BASE_URL',
    defaultValue: 'https://ndjvkzrxgmxsdrbyeyim.supabase.co/storage/v1/object/public/assets',
  );

  static const bool enableCdnImages = bool.fromEnvironment(
    'ENABLE_CDN_IMAGES',
    defaultValue: true,
  );

  /// Resolves any relative asset path or image filename to its CDN URL
  static String cdnUrl(String assetPath) {
    if (assetPath.startsWith('http://') || assetPath.startsWith('https://')) {
      return assetPath;
    }
    final normalized = assetPath.startsWith('/') ? assetPath.substring(1) : assetPath;
    return '$cdnBaseUrl/$normalized';
  }

  // Asset paths matching consumer app exactly
  static const String logoAsset = 'assets/images/inner_logo.jpg';
  static const String flameLogoAsset = 'assets/images/mandirm_flame_logo.png';
  static const String splashBackgroundAsset = 'assets/images/splash_bg_clean.jpg';
  static const String loginTopHeaderAsset = 'assets/images/login_top_header.jpg';
  static const String astroHeroBannerAsset = 'assets/images/astro_hero_banner.jpg';
  static const String astroBannerArt = 'assets/images/astro_banner_art.jpg';
  static const String astroFeatureGraphic = 'assets/images/astro_feature_graphic.jpg';
  static const String homeHeaderAsset = 'assets/images/home_header.jpg';
  static const String astroRajeshAsset = 'assets/images/astro_rajesh.jpg';
  static const String astroShraddhaAsset = 'assets/images/astro_shraddha.jpg';
  static const String astroNishantAsset = 'assets/images/astro_nishant.jpg';
  static const String astroShaktiAsset = 'assets/images/astro_shakti.jpg';
  static const String pujaGangaDiyaAsset = 'assets/images/puja_ganga_diya.jpg';
  static const String pujaGuruBrihaspatiAsset = 'assets/images/puja_guru_brihaspati.jpg';
  static const String pujaNavgrahaAsset = 'assets/images/puja_navgraha.jpg';
  static const String deityGaneshaAsset = 'assets/images/deity_ganesha.jpg';
  static const String deityShivaAsset = 'assets/images/deity_shiva.jpg';
  static const String deityRudrakshaAsset = 'assets/images/deity_rudraksha.jpg';
  static const String catYantraAsset = 'assets/images/cat_yantra.jpg';
  static const String catBooksAsset = 'assets/images/cat_books.jpg';

  // Storage Keys
  static const String keyUserToken = 'astrologer_access_token';
  static const String keyUserProfile = 'astrologer_profile_data';
  static const String keySavedPhone = 'astrologer_saved_phone';
  static const String keyAstrologerId = 'astrologer_profile_id';
  static const String keyHasSeenOnboarding = 'astrologer_has_seen_onboarding';
  static const String defaultCountryCode = '+91';
}
