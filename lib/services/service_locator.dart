import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:raising_india/constant/ConString.dart' as ConString;
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../error/exceptions.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {

  final dio = Dio(
    BaseOptions(
      baseUrl: ConString.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LoggingInterceptor());

  getIt.registerSingleton<DioClient>(DioClient(dio: dio));
}

Exception mapDioException(DioException e) {
  if (e.type == DioExceptionType.badResponse) {
    final status = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    final message = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Server error';
    if (status == 401) return AuthenticationException(message: message);
    if (status == 403) return UnAuthorizedException(message : message);
    if (status == 404) return NotFoundException(message: message);
    if (status == 422) return ValidationException(message: message);
    return ServerException(message: message);
  }

  if (e.type == DioExceptionType.connectionError) {
    return NetworkException(message: 'No internet connection');
  }

  if (e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.connectionTimeout) {
    return NetworkException(message: 'Connection timeout');
  }

  return ServerException(message: 'An unexpected error occurred');
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
    if(err.response?.statusCode == 401){
      AuthService().refreshToken();
    }
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
class AuthInterceptor extends Interceptor {

  AuthInterceptor();

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.get('access_token');
    if (token != null) {
      options.headers.addAll({
        'Authorization': 'Bearer $token',
      });
    }

    return handler.next(options);
  }
}

