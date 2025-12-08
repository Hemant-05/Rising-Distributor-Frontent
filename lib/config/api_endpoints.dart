// core/config/api_endpoints.dart

class ApiEndpoints {
  ApiEndpoints._();

  // ============================================================================
  // Authentication Endpoints
  // ============================================================================

  static const String auth = '/api/auth';
  static const String users = '/api/users';

  // Auth - Basic
  static const String registerUser = '$auth/register/user';
  static const String registerAdmin = '$auth/register/admin';
  static const String login = '$auth/login';
  static const String logout = '$auth/logout';
  static const String refreshToken = '$auth/refresh';

  // Auth - Password
  static const String registerMobile = '$users/mobile';
  static const String verifyOtp = '$registerMobile/verify';

  static const String forgotPasswordReq = '$users/password/request-reset';
  static const String resetPassword = '$users/password/reset';

  // Auth - Profile
  static const String me = '$users/me';

  // ============================================================================
  // Products Endpoints
  // ============================================================================

  static const String products = '/api/products';
  static const String getProducts = products;
  static const String addProducts = products;
  static String updateProducts(String id) => '$products/$id';
  static String deleteProducts(String id) => '$products/$id';
  static String getProductsById(String id) => '$products/$id';
  static String getProductsByCategory(String category) => '$products/category/$category';
  static String getProductsBySearch(String query) => '$products/search/$query';


  // ============================================================================
  // Notifications Endpoints
  // ============================================================================

  static const String notifications = '/notifications';
  static const String getNotifications = notifications;

  // ============================================================================
  // Search Endpoints
  // ============================================================================

  static const String search = '/search';
  static const String searchProducts = '$search/products';

  // ============================================================================
  // Profile Endpoints
  // ============================================================================

  static const String profile = '/profile';
  static const String updateProfile = '$profile/update';

  // ============================================================================
  // Settings Endpoints
  // ============================================================================

  static const String settings = '/settings';
  static const String privacySettings = '$settings/privacy';
  static const String notificationSettings = '$settings/notifications';
  static const String accountSettings = '$settings/account';
  static const String deleteAccount = '$settings/delete-account';

  // ============================================================================
  // Upload Endpoints
  // ============================================================================

  static const String upload = '/upload';
  static const String uploadImage = '$upload/image';
  static const String uploadVideo = '$upload/video';

  // ============================================================================
  // Report & Moderation Endpoints
  // ============================================================================

  static const String reports = '/reports';
  static const String moderationQueue = '/moderation/queue';
}