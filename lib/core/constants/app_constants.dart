/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Mekenet Insurance';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.safeinsurance.mobile';

  // API Base URL — update for production
  static const String baseUrl = 'https://api.mekenet.et/api';
  static const String fileBaseUrl = 'https://api.mekenet.et';
  // static const String baseUrl = 'http://10.189.191.68:9090/api';
  // static const String fileBaseUrl = 'http://10.189.191.68:9090';
  

  // Timeouts
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 60000;
  static const int sendTimeoutMs = 60000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultPage = 0;

  // Cache
  static const int cacheMaxAge = 7; // days
  static const String cacheBoxName = 'safe_insurance_cache';
  static const String settingsBoxName = 'safe_insurance_settings';
  static const String offlineQueueBoxName = 'offline_queue';

  // Secure Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userProfileKey = 'user_profile';
  static const String pinCodeKey = 'pin_code';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String rememberMeKey = 'remember_me';
  static const String rememberedEmailKey = 'remembered_email';

  // SharedPrefs Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String onboardingKey = 'onboarding_done';
  static const String fcmTokenKey = 'fcm_token';

  // Supported Locales
  static const List<String> supportedLocales = ['en', 'am'];

  // Token
  static const String tokenPrefix = 'Bearer ';
  static const String authHeader = 'Authorization';

  // Retry
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // ms

  // Animation durations
  static const int splashDuration = 2500;
  static const int pageTransitionDuration = 300;
  static const int shimmerDuration = 1500;

  // Routes names
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeOtp = '/otp';
  static const String routeCreatePin = '/create-pin';
  static const String routePinLogin = '/pin-login';
  static const String routeDashboard = '/dashboard';
  static const String routeProfile = '/profile';
  static const String routeEditProfile = '/profile/edit';
  static const String routeSettings = '/settings';
  static const String routeNotifications = '/notifications';
  static const String routePolicies = '/policies';
  static const String routePolicyDetails = '/policies/:id';
  static const String routeBrowsePolicies = '/policies/browse';
  static const String routeApplyPolicy = '/policies/apply/:id';
  static const String routeDigitalCard = '/policies/:id/card';
  static const String routeClaims = '/claims';
  static const String routeClaimDetails = '/claims/:id';
  static const String routeNewClaim = '/claims/new';
  static const String routePayments = '/payments';
  static const String routePaymentDetails = '/payments/:id';
  static const String routeDocuments = '/documents';
  static const String routeSupport = '/support';
  static const String routeFaq = '/support/faq';
  static const String routeAbout = '/about';
  static const String routePrivacyPolicy = '/privacy-policy';
  static const String routeTerms = '/terms';
  static const String routeNotFound = '/404';
}
