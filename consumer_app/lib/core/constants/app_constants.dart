class AppConstants {
  AppConstants._();

  static const String appName = 'Mandirm';
  static const String appTagline = 'Connect with the Divine • Mandir, Puja & Astrology';

  // Backend API URL (FastAPI on Railway / localhost dev)
  // Backend API URL (Production FastAPI backend)
  // Override via --dart-define=BACKEND_URL=https://api.mandirm.in/api/v1
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://api.mandirm.in/api/v1',
  );

  // Supabase Configuration
  // Can be passed via --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=...
  // Default values can be replaced with your live Supabase project credentials.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ndjvkzrxgmxsdrbyeyim.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kanZrenJ4Z214c2RyYnlleWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1MDE2NTcsImV4cCI6MjEwNjA3NzY1N30.sokDKK8Lnh36oKHt6Yq8_6ImmUXhwJ72FyU0NHsR3w0',
  );

  // Asset paths
  static const String logoAsset = 'assets/images/inner_logo.jpg';
  static const String flameLogoAsset = 'assets/images/mandirm_flame_logo.png';
  static const String splashBackgroundAsset = 'assets/images/splash_bg_clean.jpg';
  static const String splashOriginalAsset = 'assets/images/splash_screen_original.jpg';
  static const String loginTopHeaderAsset = 'assets/images/login_top_header.jpg';
  static const String loginScreenBgAsset = 'assets/images/login_screen_bg.jpg';
  static const String homeHeaderAsset = 'assets/images/home_header.jpg';
  static const String homeCardPujaAsset = 'assets/images/home_card_puja.jpg';
  static const String homeCardAstroAsset = 'assets/images/home_card_astro.jpg';
  static const String homeMockupFullAsset = 'assets/images/home_mockup_full.jpg';
  static const String pujaGangaDiyaAsset = 'assets/images/puja_ganga_diya.jpg';
  static const String pujaGuruBrihaspatiAsset = 'assets/images/puja_guru_brihaspati.jpg';
  static const String pujaNavgrahaAsset = 'assets/images/puja_navgraha.jpg';
  static const String pujaDetailBannerAsset = 'assets/images/puja_detail_banner.jpg';
  static const String pujaAboutThumbAsset = 'assets/images/puja_about_thumb.jpg';
  static const String pkgBasicAsset = 'assets/images/pkg_basic.jpg';
  static const String pkgSpecialAsset = 'assets/images/pkg_special.jpg';
  static const String pkgCompleteAsset = 'assets/images/pkg_complete.jpg';
  static const String pujaHeroBgAsset = 'assets/images/puja_hero_bg.jpg';
  static const String astroHeroBannerAsset = 'assets/images/astro_hero_banner.jpg';
  static const String astroRajeshAsset = 'assets/images/astro_rajesh.jpg';
  static const String astroShraddhaAsset = 'assets/images/astro_shraddha.jpg';
  static const String astroNishantAsset = 'assets/images/astro_nishant.jpg';
  static const String astroShaktiAsset = 'assets/images/astro_shakti.jpg';

  // Store Assets
  static const String storeHeroCropAsset = 'assets/images/store_hero_crop.jpg';
  static const String storeHeroAiAsset = 'assets/images/store_hero_ai.jpg';
  static const String storePromoBannerAsset = 'assets/images/store_promo_banner.jpg';
  static const String deityGaneshaAsset = 'assets/images/deity_ganesha.jpg';
  static const String deityKrishnaAsset = 'assets/images/deity_krishna.jpg';
  static const String deityShivaAsset = 'assets/images/deity_shiva.jpg';
  static const String deityLakshmiAsset = 'assets/images/deity_lakshmi.jpg';
  static const String deitySamagriAsset = 'assets/images/deity_samagri.jpg';
  static const String deityRudrakshaAsset = 'assets/images/deity_rudraksha.jpg';
  static const String prodGaneshaAsset = 'assets/images/prod_ganesha_ai.jpg';
  static const String prodRudrakshaAsset = 'assets/images/prod_rudraksha_ai.jpg';
  static const String prodThaliAsset = 'assets/images/prod_thali.jpg';
  static const String prodOmPlateAsset = 'assets/images/prod_om_plate.jpg';
  static const String festNavratriAsset = 'assets/images/fest_navratri.jpg';
  static const String festDiwaliAsset = 'assets/images/fest_diwali.jpg';
  static const String festShivratriAsset = 'assets/images/fest_shivratri.jpg';
  static const String catAllAsset = 'assets/images/cat_all.jpg';
  static const String catIdolsAsset = 'assets/images/cat_idols.jpg';
  static const String catSamagriAsset = 'assets/images/cat_samagri.jpg';
  static const String catYantraAsset = 'assets/images/cat_yantra.jpg';
  static const String catDhoopAsset = 'assets/images/cat_dhoop.jpg';
  static const String catEssentialsAsset = 'assets/images/cat_essentials.jpg';
  static const String catVratAsset = 'assets/images/cat_vrat.jpg';
  static const String catBooksAsset = 'assets/images/cat_books.jpg';
  static const String mahakalHeroAsset = 'assets/images/mahakal_hero.jpg';
  static const String mahakalThumb1Asset = 'assets/images/mahakal_thumb_1.jpg';
  static const String mahakalThumb2Asset = 'assets/images/mahakal_thumb_2.jpg';
  static const String mahakalThumb3Asset = 'assets/images/mahakal_thumb_3.jpg';
  static const String mahakalThumb4Asset = 'assets/images/mahakal_thumb_4.jpg';
  static const String mahakalThumb5Asset = 'assets/images/mahakal_thumb_5.jpg';
  static const String mahakalThumb6Asset = 'assets/images/mahakal_thumb_6.jpg';
  static const String mahakalThumb7Asset = 'assets/images/mahakal_thumb_7.jpg';
  static const String consecratedOmShieldAsset = 'assets/images/consecrated_om_shield.jpg';

  // Chadava Screen Assets
  static const String chadavaHeroBannerAsset = 'assets/images/chadava_hero_banner.jpg';
  static const String chadavaPackagesBannerAsset = 'assets/images/chadava_packages_banner.jpg';
  static const String chadavaCardMahakalAsset = 'assets/images/chadava_card_mahakal.jpg';
  static const String chadavaCardVishnuAsset = 'assets/images/chadava_card_vishnu.jpg';
  static const String chadavaCardGaneshAsset = 'assets/images/chadava_card_ganesh.jpg';
  static const String chadavaTypeFlowerAsset = 'assets/images/chadava_type_flower.jpg';
  static const String chadavaTypeCoconutAsset = 'assets/images/chadava_type_coconut.jpg';
  static const String chadavaTypeSweetAsset = 'assets/images/chadava_type_sweet.jpg';
  static const String chadavaTypeLampAsset = 'assets/images/chadava_type_lamp.jpg';
  static const String chadavaTypeRudrakshaAsset = 'assets/images/chadava_type_rudraksha.jpg';
  static const String chadavaTypeVastraAsset = 'assets/images/chadava_type_vastra.jpg';
  static const String chadavaTempleMahakalAsset = 'assets/images/chadava_temple_mahakal.jpg';
  static const String chadavaTempleKashiAsset = 'assets/images/chadava_temple_kashi.jpg';
  static const String chadavaTempleKedarnathAsset = 'assets/images/chadava_temple_kedarnath.jpg';
  static const String chadavaTempleTirupatiAsset = 'assets/images/chadava_temple_tirupati.jpg';
  static const String chadavaTempleSiddhivinayakAsset = 'assets/images/chadava_temple_siddhivinayak.jpg';
  static const String chadavaCatAllAsset = 'assets/images/chadava_cat_all.jpg';
  static const String chadavaCatShivaAsset = 'assets/images/chadava_cat_shiva.jpg';
  static const String chadavaCatVishnuAsset = 'assets/images/chadava_cat_vishnu.jpg';
  static const String chadavaCatHanumanAsset = 'assets/images/chadava_cat_hanuman.jpg';
  static const String chadavaCatDeviAsset = 'assets/images/chadava_cat_devi.jpg';
  static const String chadavaCatGaneshAsset = 'assets/images/chadava_cat_ganesh.jpg';
  static const String chadavaCatOtherAsset = 'assets/images/chadava_cat_other.jpg';

  // Storage Keys
  static const String keyUserToken = 'user_access_token';
  static const String keyUserProfile = 'user_profile_data';
  static const String keyIsFirstTime = 'is_first_time_user';
  static const String keySavedPhone = 'saved_phone_number';
  static const String keyAppLocale = 'app_locale';

  // Default Country Code
  static const String defaultCountryCode = '+91';
}
