import 'dart:io';
import 'package:dio/dio.dart';
import 'package:raising_india/models/dto/admin_order_review_dto.dart';
import 'package:raising_india/models/dto/api_response.dart';
import 'package:raising_india/models/dto/auth_dtos.dart';
import 'package:raising_india/models/dto/auth_response.dart';
import 'package:raising_india/models/dto/cart_dtos.dart';
import 'package:raising_india/models/dto/dashboard_response.dart';
import 'package:raising_india/models/dto/page.dart';
import 'package:raising_india/models/dto/product_request.dart';
import 'package:raising_india/models/dto/review_request_dto.dart';
import 'package:raising_india/models/dto/token_password_dtos.dart';
import 'package:raising_india/models/dto/user_profile_response.dart';
import 'package:raising_india/models/model/address.dart';
import 'package:raising_india/models/model/admin.dart';
import 'package:raising_india/models/model/analytics_response.dart';
import 'package:raising_india/models/model/banner.dart';
import 'package:raising_india/models/model/brand.dart';
import 'package:raising_india/models/model/cart.dart';
import 'package:raising_india/models/model/category.dart';
import 'package:raising_india/models/model/coupon.dart';
import 'package:raising_india/models/model/customer.dart';
import 'package:raising_india/models/model/notification.dart';
import 'package:raising_india/models/model/order.dart';
import 'package:raising_india/models/model/product.dart';
import 'package:raising_india/models/model/product_review.dart';
import 'package:raising_india/models/model/wishlist.dart';
import 'package:retrofit/retrofit.dart' hide CancelRequest;
import 'package:raising_india/models/dto/cancel_request.dart';
part 'rest_client.g.dart';

@RestApi(baseUrl: "https://rising-distributor.onrender.com/api")
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // ===========================================================================
  // 1. AUTH CONTROLLER
  // ===========================================================================
  // 1. Register User (Returns Customer + Tokens)
  @POST("/auth/register/user")
  Future<ApiResponse<Map<String, dynamic>>> registerUser(
    @Body() RegistrationRequest request,
  );

  // 2. Register Admin (Returns Admin + Tokens)
  @POST("/auth/register/admin")
  Future<ApiResponse<Map<String, dynamic>>> registerAdmin(
    @Body() RegistrationRequest request,
  );

  // 3. Login
  @POST("/auth/login")
  Future<ApiResponse<AuthResponse>> login(@Body() LogInRequest request);

  // 4. Refresh Token
  @POST("/auth/refresh")
  Future<ApiResponse<AuthResponse>> refreshToken(
    @Body() RefreshTokenRequest request,
  );

  // 5. Forgot Password
  @POST("/auth/forgot-password")
  Future<ApiResponse<String>> forgotPassword(@Query("email") String email);

  // 6. Reset Password
  @POST("/auth/reset-password")
  Future<ApiResponse<String>> resetPassword(@Body() ResetPasswordDto request);

  // ===========================================================================
  // 2. ADDRESS CONTROLLER
  // ===========================================================================
  @GET("/addresses/all")
  Future<ApiResponse<List<Address>>> getAddresses();

  @POST("/addresses/add")
  Future<ApiResponse<Address>> addAddress(@Body() Address address);

  @PUT("/addresses/update/{id}")
  Future<ApiResponse<Address>> updateAddress(
    @Path("id") int id,
    @Body() Address request,
  );

  @PUT("/addresses/set-primary/{id}")
  Future<ApiResponse<bool>> setPrimaryAddress(@Path("id") int id);

  @DELETE("/addresses/delete/{id}")
  Future<ApiResponse<bool>> deleteAddress(@Path("id") int id);

  // ===========================================================================
  // 3. CART CONTROLLER
  // ===========================================================================
  @GET("/cart/items")
  Future<ApiResponse<List<CartItemDto>>> getCartItems();

  @GET("/cart/count")
  Future<ApiResponse<int>> getCartItemCount();

  @POST("/cart/add")
  Future<ApiResponse<bool>> addToCart(@Body() CartRequestDto request);

  @PUT("/cart/update")
  Future<ApiResponse<bool>> updateCartQuantity(@Body() CartRequestDto request);

  @DELETE("/cart/remove/{productId}")
  Future<ApiResponse<bool>> removeCartItem(@Path("productId") String productId);

  @DELETE("/cart/clear")
  Future<ApiResponse<bool>> clearCart();

  // New endpoint from your controller
  @GET("/cart/status/{productId}")
  Future<ApiResponse<Map<String, dynamic>>> getCartStatus(
    @Path("productId") String productId,
  );

  // ===========================================================================
  // 4. CATEGORY CONTROLLER
  // ===========================================================================
  @GET("/categories/all")
  Future<ApiResponse<List<Category>>> getAllCategories();

  @GET("/categories/{id}")
  Future<ApiResponse<Category>> getCategoryById(@Path("id") int id);

  // --- Admin Endpoints ---
  @POST("/categories/create")
  Future<ApiResponse<Category>> createCategory(
    @Query("name") String name,
    @Query("parentId") int? parentId,
  );

  @PUT("/categories/{id}/update")
  Future<ApiResponse<Category>> updateCategory(
    @Path("id") int id,
    @Body() Category category,
  );

  @DELETE("/categories/{id}/delete")
  Future<ApiResponse<bool>> deleteCategory(@Path("id") int id);

  // ===========================================================================
  // 5. BANNER CONTROLLER
  // ===========================================================================
  // Public Endpoint (Customer App)
  @GET("/public/banners")
  Future<ApiResponse<List<Banner>>> getActiveBanners();

  // Admin Endpoints
  @GET("/admin/banners")
  Future<ApiResponse<List<Banner>>> getAllBannersAdmin();

  @POST("/admin/banners/add")
  Future<ApiResponse<Banner>> addBanner(
    @Query("imageUrl") String imageUrl,
    @Query("redirectRoute") String? redirectRoute,
  );

  @DELETE("/admin/banners/{id}")
  Future<ApiResponse<String>> deleteBanner(@Path("id") int id);

  @PATCH("/admin/banners/{id}/toggle")
  Future<ApiResponse<Banner>> toggleBannerStatus(@Path("id") int id);

  // ===========================================================================
  // 6. BRAND CONTROLLER
  // ===========================================================================
  @POST("/brands/add")
  Future<ApiResponse<Brand>> addBrand(@Body() Brand brand);

  // 2. Get All Brands
  @GET("/brands/all")
  Future<ApiResponse<List<Brand>>> getAllBrands();

  // 3. Get Single Brand by ID
  @GET("/brands/{id}")
  Future<ApiResponse<Brand>> getBrandById(@Path("id") int id);

  // 4. Get Products by Brand ID
  @GET("/brands/{brandId}/products")
  Future<ApiResponse<List<Product>>> getProductsByBrand(
    @Path("brandId") int brandId, // Java Long -> Dart int
  );
  // ===========================================================================
  // 7. COUPON CONTROLLER
  // ===========================================================================
  // User Endpoints
  @POST("/coupons/apply")
  Future<ApiResponse<Cart>> applyCoupon(
    @Query("userId") String userId,
    @Query("code") String code,
  );

  @POST("/coupons/remove")
  Future<ApiResponse<Cart>> removeCoupon(@Query("userId") String userId);

  // Admin Endpoints
  @POST("/coupons/create")
  Future<ApiResponse<Coupon>> createCoupon(@Body() Coupon coupon);

  @GET("/coupons/all")
  Future<ApiResponse<List<Coupon>>> getAllCoupons();

  @DELETE("/coupons/{id}")
  Future<ApiResponse<String>> deleteCoupon(@Path("id") int id);

  // ===========================================================================
  // 8. IMAGE CONTROLLER (Multipart)
  // ===========================================================================
  @POST("/images/upload")
  @MultiPart()
  Future<ApiResponse<String>> uploadImage(@Part(name: "file") File file);

  @DELETE("/images/delete")
  Future<ApiResponse<String>> deleteImage(@Query("imageUrl") String imageUrl);

  // ===========================================================================
  // 9. ADMIN CONTROLLER
  // ===========================================================================

  @PUT("/admin/profile/{uid}")
  Future<ApiResponse<Admin>> updateAdminProfile(
    @Path("uid") String uid,
    @Body() Map<String, dynamic> body,
  );

  @GET("/admin/products")
  Future<ApiResponse<List<Product>>> getAllProducts();

  @GET("/admin/orders")
  Future<ApiResponse<List<Order>>> getAllAdminOrders();

  @GET("/admin/orders/status/{status}")
  Future<ApiResponse<List<Order>>> getOrdersByStatus(
    @Path("status") String status,
  );
  @GET("/admin/orders/today")
  Future<ApiResponse<List<Order>>> getTodaysOrders();

  @PUT("/admin/orders/{orderId}")
  Future<ApiResponse<Order>> updateAdminOrderStatus(
    @Path("orderId") int orderId,
    @Query("status") String status,
  );

  @GET("/admin/stats/revenue")
  Future<ApiResponse<double>> getTotalRevenue();

  @GET("/admin/dashboard")
  Future<ApiResponse<DashboardResponse>> getDashboard();

  // ===========================================================================
  // 10. NOTIFICATION CONTROLLER (Admin)
  // ===========================================================================
  @POST("/admin/notifications/broadcast")
  Future<ApiResponse<String>> sendBroadcast(
    @Query("title") String title,
    @Query("body") String body,
  );

  @GET("/admin/notifications")
  Future<ApiResponse<List<NotificationModel>>> getAdminNotifications();

  @PUT("/admin/notifications/{id}/read")
  Future<ApiResponse<void>> markNotificationRead(@Path("id") String id);

  // ===========================================================================
  // 11. ORDER CONTROLLER
  // ===========================================================================
  @POST("/orders/place")
  Future<ApiResponse<Order>> placeOrder(
    @Query("addressId") int addressId,
    @Query("paymentMethod") String paymentMethod,
  );

  @POST("/orders/confirm-payment")
  Future<ApiResponse<Order>> confirmPayment(
    @Body() Map<String, dynamic> payload,
  );

  // (Ensure you already have these from previous steps)
  @GET("/orders/{id}")
  Future<ApiResponse<Order>> getOrderById(@Path("id") int id);

  @GET("/orders/my-orders")
  Future<ApiResponse<List<Order>>> getMyOrders();

  @POST("/orders/cancel/{orderId}")
  Future<ApiResponse<Order>> cancelOrder(
      @Path("orderId") int orderId,
      @Body() CancelRequest request,
      );

  @GET("/orders/{id}/invoice")
  @DioResponseType(ResponseType.bytes)
  Future<List<int>> downloadInvoice(@Path("id") int id);

  // ===========================================================================
  // 12. PRODUCT CONTROLLER
  // ===========================================================================
  // 1. Get All Products
  @GET("/products")
  Future<ApiResponse<List<Product>>> getAllAvailableProducts();

  // 2. Get Best Selling
  @GET("/products/best-selling")
  Future<ApiResponse<List<Product>>> getBestSellingProducts();

  // 3. Get Products by Category
  @GET("/products/category/{category}")
  Future<ApiResponse<List<Product>>> getProductsByCategory(
    @Path("category") String category,
  );

  // 4. Get Single Product
  @GET("/products/{pid}")
  Future<ApiResponse<Product>> getProduct(@Path("pid") String pid);

  // 5. Add Product (Admin)
  @POST("/products")
  Future<ApiResponse<Product>> addProduct(@Body() ProductRequest request);

  // 6. Update Product (Admin)
  @PUT("/products/{pid}")
  Future<ApiResponse<Product>> updateProduct(
    @Path("pid") String pid,
    @Body() ProductRequest request,
  );

  // 7. Delete Product (Admin)
  @DELETE("/products/{pid}")
  Future<ApiResponse<void>> deleteProduct(@Path("pid") String pid);

  // 8. Restock Product (Admin)
  @PUT("/products/restock/{productId}")
  Future<ApiResponse<Product>> restockProduct(
    @Path("productId") String productId,
    @Query("qty") int qty,
  );

  // 9. Search & Filter
  // Note: Returns Map<String, dynamic> because Spring 'Page' object structure is complex.
  // You can access the list via response.data['content']
  @GET("/products/search")
  Future<ApiResponse<Map<String, dynamic>>> searchProducts(
    @Query("query") String? query,
    @Query("category") String? category,
    @Query("minPrice") double? minPrice,
    @Query("maxPrice") double? maxPrice,
    @Query("sort") String sort, // 'asc' or 'desc'
    @Query("page") int page,
    @Query("size") int size,
  );

  @GET("/products/archived")
  Future<ApiResponse<List<Product>>> getArchivedProducts();

  @PUT("/products/{pid}/restore")
  Future<ApiResponse<Product>> restoreProduct(@Path("pid") String pid);

  // ===========================================================================
  // 13. REVIEW CONTROLLER
  // ===========================================================================
  @POST("/reviews/submit")
  Future<ApiResponse<String>> submitReview(@Body() ReviewRequestDto request);

  @GET("/reviews/product/{productId}")
  Future<ApiResponse<List<ProductReview>>> getProductReviews(
    @Path("productId") int productId,
  );

  @GET("/reviews/product/{productId}/average")
  Future<ApiResponse<double>> getProductAverageRating(
    @Path("productId") int productId,
  );

  // --- Reviews (Admin) ---

  @GET("/reviews/order/{orderId}")
  Future<ApiResponse<AdminOrderReviewDto>> getReviewByOrder(
    @Path("orderId") int orderId,
  );

  // Note: Ensure you have a Dart model for 'Page<T>' that matches Spring's Page structure
  // (fields: content, totalPages, totalElements, etc.)
  @GET("/reviews/all")
  Future<ApiResponse<Page<AdminOrderReviewDto>>> getAllReviews(
    @Query("page") int page,
    @Query("size") int size,
    @Query("keyword") String? keyword,
    @Query("rating") double? rating,
    @Query("sort") String? sort,
  );

  // ===========================================================================
  // 14. USER CONTROLLER
  // ===========================================================================

  @PUT("/users/profile/{uid}")
  Future<ApiResponse<Customer>> updateUserProfile(
    @Path("uid") String uid,
    @Body() Map<String, dynamic> body,
  );

  @GET("/users/me")
  Future<ApiResponse<UserProfileResponse>> getCurrentUserProfile();

  @POST("/users/mobile")
  Future<ApiResponse<void>> saveMobileNumber(@Body() MobileRequest request);

  @POST("/users/mobile/verify")
  Future<ApiResponse<void>> verifyMobile(
    @Body() OtpVerificationRequest request,
  );

  @POST("/users/update-fcm-token")
  Future<ApiResponse<String>> updateFcmToken(@Query("token") String token);

  // ===========================================================================
  // 15. WISHLIST CONTROLLER
  // ===========================================================================
  @POST("/wishlist/add")
  Future<ApiResponse<String>> addToWishlist(
    @Query("userId") String userId,
    @Query("productPid") String productPid,
  );

  @DELETE("/wishlist/remove")
  Future<ApiResponse<String>> removeFromWishlist(
    @Query("userId") String userId,
    @Query("productPid") String productPid,
  );

  @GET("/wishlist/{userId}")
  Future<ApiResponse<List<Wishlist>>> getWishlist(
    @Path("userId") String userId,
  );

  // --- Admin Analytics ---
  /// Get Sales Analytics Data
  /// [filter] options: 'DAILY', 'WEEKLY', 'MONTHLY', 'ALL_TIME'
  @GET("/admin/analytics")
  Future<ApiResponse<AnalyticsResponse>> getSalesAnalytics(
    @Query("filter") String filter,
  );
}
