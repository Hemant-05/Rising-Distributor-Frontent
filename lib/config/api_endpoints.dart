// core/config/api_endpoints.dart

import 'package:raising_india/constant/ConString.dart';

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

  static String forgotPassword(String email) => '$auth/forgot-password?email=$email';
  static const String resetPassword = '$auth/reset-password';

  // Auth - Profile
  static const String me = '$users/me';
  static String updateFCMToken(String token) => '$users/update-fcm-token?token=$token';

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
  // Cart Endpoints
  // ============================================================================

  static const String cart = '/api/cart';
  static const String getCartItems = '$cart/items';
  static const String addToCart = '$cart/add';
  static const String updateCartProductQty = '$cart/update';
  static const String getCountCartItems = '$cart/count';
  static const String clearCart = '$cart/clear';
  static String removeCartItem(String productId) => '$cart/remove/$productId';
  static String isInCart(String productId) => '$cart/status/$productId';

  // ============================================================================
  // Order Endpoints
  // ============================================================================

  static const String order = '/api/order';
  static const String getMyOrders = '$order/my-orders';
  static String confirmPayment = '$order/confirm-payment';
  static String placeOrder(String addressId, String paymentMethod) => '$order/place?addressId=$addressId&paymentMethod=$paymentMethod';
  static String updateOrderStatus(String orderId, String status) => '$order/$orderId?status=$status';
  static String getOrderById(String orderId) => '$order/$orderId';
  static String cancelOrder(String orderId) => '$order/cancel/$orderId';
  static String getOrderInvoice(String orderId) => '$order/$orderId/invoice';
  static String getOrdersByStatus(String status) => '$order/status/$status';


  // ============================================================================
  // Addresses Endpoints
  // ============================================================================

  static const String addresses = '/api/addresses';
  static const String getAllAddresses = '$addresses/all';
  static const String addAddresses = '$addresses/add';
  static String setPrimaryAddress(String addressId) => '$addresses/set-primary/$addressId';
  static String deleteAddress(int addressId) => '$addresses/delete/$addressId';

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