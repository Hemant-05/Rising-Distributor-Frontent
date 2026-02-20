import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:raising_india/data/rest_client.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/admin/services/admin_image_service.dart';
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

final getIt = GetIt.instance;

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
    // 1. Get Access Token from AuthService (which uses SharedPreferences internally)
    final authService = getIt<AuthService>();
    final token = await authService.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 2. Check if the error is 401 (Unauthorized)
    if (err.response?.statusCode == 401) {
      final authService = getIt<AuthService>();
      final refreshToken = await authService.getRefreshToken();

      // If we have a refresh token, try to refresh
      if (refreshToken != null) {
        try {
          // 3. Call Refresh API using the separate _tokenDio
          // Adjust the endpoint '/api/auth/refresh-token' to match your backend
          final response = await _tokenDio.post('/api/auth/refresh', data: {
            'refresh_token': refreshToken,
          });
          // final response = await authService.tryRefreshToken();

          print('=======================');
          print(response.data);
          if (response != null) {
            // 4. Extract new tokens (Adjust parsing based on your API response)
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token']; // If backend rotates it

            // 5. Save new tokens
            await authService.saveTokens(newAccessToken!, newRefreshToken);

            // 6. Retry the original request with the NEW token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            // We use a basic Dio() fetch here to ensure we just retry the HTTP call
            final cloneReq = await Dio().fetch(opts);

            return handler.resolve(cloneReq);
          }
        } catch (e) {
          // Refresh failed (Session truly expired) -> Log out user
          await authService.signOut();
        }
      }
    }

    // If not 401 or refresh failed, pass the error along
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