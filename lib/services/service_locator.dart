import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:raising_india/data/rest_client.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/admin/services/admin_image_service.dart';
import 'package:raising_india/screens/server_down_screen.dart';
import '../constant/ConString.dart' as ConString;
import '../data/services/address_service.dart';
import '../data/services/admin_service.dart';
import '../data/services/analytics_service.dart';
import '../data/services/banner_service.dart';
import '../data/services/brand_service.dart';
import '../data/services/cart_service.dart';
import '../data/services/category_service.dart';
import '../data/services/coupon_service.dart';
import '../data/services/image_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/order_service.dart';
import '../data/services/product_service.dart';
import '../data/services/review_service.dart';
import '../data/services/user_service.dart';
import '../data/services/wishlist_service.dart';
import '../main.dart';

final getIt = GetIt.instance;
bool _isServerDownScreenShowing = false;

void setupServiceLocator() {
  // 1. Register Dio (The Engine)
  final dio = Dio(BaseOptions(
    baseUrl: ConString.baseUrl, // Ensure you set your Base URL here
    contentType: "application/json",
    receiveTimeout: const Duration(seconds: 15),
    connectTimeout: const Duration(seconds: 15),
  ));

  // 2. Add Interceptors
  // Note: Order matters. AuthInterceptor should often be first to add headers.
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException e, handler) {
        // Check if the error is a Timeout or Connection issue
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {

          // If the screen isn't already showing, show it!
          if (!_isServerDownScreenShowing && navigatorKey.currentState != null) {
            _isServerDownScreenShowing = true;

            navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => const ServerDownScreen()),
            ).then((_) {
              // When the user taps "Try Again" and the screen pops, reset the flag
              _isServerDownScreenShowing = false;
            });
          }
        }
        return handler.next(e);
      },
    ),
  );

  getIt.registerLazySingleton<Dio>(() => dio);
  getIt.registerLazySingleton<RestClient>(() => RestClient(getIt<Dio>()));

  // 3. Register Services
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => ProductService());
  getIt.registerLazySingleton(() => CartService());
  getIt.registerLazySingleton(() => OrderService());
  getIt.registerLazySingleton(() => AddressService());
  getIt.registerLazySingleton(() => CategoryService());
  getIt.registerLazySingleton(() => BannerService());
  getIt.registerLazySingleton(() => ReviewService());
  getIt.registerLazySingleton(() => WishlistService());
  getIt.registerLazySingleton(() => UserService());
  getIt.registerLazySingleton(() => BrandService());
  getIt.registerLazySingleton(() => CouponService());

  // Admin specific services
  getIt.registerLazySingleton(() => AdminService());
  getIt.registerLazySingleton(() => ImageService());
  getIt.registerLazySingleton(() => AdminImageService());
  getIt.registerLazySingleton(() => NotificationService());
  getIt.registerLazySingleton(() => AnalyticsService()); // Added AnalyticsService
}

// --- UPDATED AUTH INTERCEPTOR ---

class AuthInterceptor extends Interceptor {
  // We use a separate Dio instance for the refresh call to avoid
  // the main Dio interceptor catching this request and causing an infinite loop.
  final Dio _tokenDio = Dio(BaseOptions(
    baseUrl: ConString.baseUrl, // Must match your API Base URL
    contentType: "application/json",
  ));

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final authService = getIt<AuthService>();
    final token = await authService.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 1. Check if the error is 401 (Unauthorized)
    if (err.response?.statusCode == 401) {
      final authService = getIt<AuthService>();
      final refreshToken = await authService.getRefreshToken();

      // If we have a refresh token, try to refresh
      if (refreshToken != null) {
        try {
          // 2. Call Refresh API
          final response = await _tokenDio.post('/auth/refresh', data: {
            'refresh_token': refreshToken,
          });

          if (response.statusCode == 200 && response.data != null) {

            // ✅ FIX: Parse from the nested 'data' object
            final responseData = response.data['data'];
            final newAccessToken = responseData['access_token'];
            final newRefreshToken = responseData['refresh_token'];

            if (newAccessToken != null && newRefreshToken != null) {
              // 3. Save new tokens
              await authService.saveTokens(newAccessToken, newRefreshToken);

              // 4. Retry the original request with the NEW token
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';

              // Fetch the original request again
              final cloneReq = await Dio().fetch(opts);
              return handler.resolve(cloneReq);
            } else {
              throw Exception("Tokens are null in the response");
            }
          }
        } catch (e) {
          // Refresh failed or parsing crashed -> Log out user
          print('🚨 Refresh Token Error: $e'); // Added print to help you debug future crashes
          await authService.signOut();
          return handler.next(err); // Reject the request so the UI knows it failed
        }
      }
    }

    // If not 401 or no refresh token, pass the error along
    return handler.next(err);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('╔════════════════════════════════════════════════════════════╗');
    print('║                    📤 API REQUEST                          ║');
    print('╠════════════════════════════════════════════════════════════╣');
    print('Method: ${options.method}');
    print('URL: ${options.uri}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    print('╚════════════════════════════════════════════════════════════╝');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('╔════════════════════════════════════════════════════════════╗');
    print('║                    📥 API RESPONSE                         ║');
    print('╠════════════════════════════════════════════════════════════╣');
    print('Status Code: ${response.statusCode}');
    print('URL: ${response.requestOptions.path}');
    print('Response: ${response.data}');
    print('╚════════════════════════════════════════════════════════════╝');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('╔════════════════════════════════════════════════════════════╗');
    print('║                    ❌ API ERROR                            ║');
    print('╠════════════════════════════════════════════════════════════╣');
    print('Type: ${err.type}');
    print('Message: ${err.message}');
    print('Status Code: ${err.response?.statusCode}');
    print('╚════════════════════════════════════════════════════════════╝');
    handler.next(err);
  }
}