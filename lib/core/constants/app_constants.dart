class AppConstants {
  // App Info
  static const String appName = 'كتبي المدرسية';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'مكتبتك المدرسية الرقمية';

  // Base URL
  static const String baseUrl = 'https://wajibi.net';
  static const String booksBaseUrl = 'https://wajibi.net/books';
  static const String hostingerRemoteConfigUrl =
      'https://wajibi.net/app-config/remote_config.json';

  // Wajibi.net URL Patterns
  static const String primaryStagePath = '/primary';
  static const String middleStagePath = '/middle';
  static const String highStagePath = '/high';
  static const String kgStagePath = '/kg';

  // SharedPreferences Keys
  static const String keyFavoriteBooks = 'favorite_books';
  static const String keyThemeMode = 'theme_mode';
  static const String keyFontSize = 'font_size';
  static const String keyLastViewedBooks = 'last_viewed_books';
  static const String keyDownloadedBooks = 'downloaded_books';
  static const String keyReaderPreferences = 'reader_preferences';
  static const String keyWeeklyStudyPlan = 'weekly_study_plan';
  static const String keyHostingerRemoteConfig = 'hostinger_remote_config';
  static const String keyHostingerRemoteConfigFetchedAt =
      'hostinger_remote_config_fetched_at';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // App Store / Contact
  static const String supportEmail = 'support@kutubmadrasiyya.com';
  static const String appStoreLink = 'https://apps.apple.com/app/id000000000';

  // Pagination
  static const int booksPerPage = 20;

  // Animation Duration
  static const int animationDuration = 300;
}
