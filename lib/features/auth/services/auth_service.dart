import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/config/api_endpoints.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/address_model.dart';
import 'package:raising_india/models/user_model.dart';
import 'package:raising_india/network/dio_client.dart';
import 'package:raising_india/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/ConString.dart' as ConString;

class AuthService extends ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;
  final DioClient _dioClient = getIt<DioClient>();

  AuthService() {
    _onAuthStateChanged(_user);
  }

  Future<void> _onAuthStateChanged(AppUser? user) async {
    print('AuthService: _onAuthStateChanged called');
    _user = user;
    notifyListeners();
  }

  Future<String?> getUid() async {
    return user?.uid;
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final data = {'name': name, 'email': email, 'password': password};
      Response<dynamic> response;
      if (role == ConString.admin) {
        response = await _dioClient.post(
          ApiEndpoints.registerAdmin,
          data: data,
        );
      } else {
        response = await _dioClient.post(ApiEndpoints.registerUser, data: data);
      }

      // Expecting response.data to be a map containing data -> user and tokens
      final resp = response.data as Map<String, dynamic>;
      // adapt to common shapes: data.user or user
      final payload_data = resp['data'] ?? resp;

      final userMap = payload_data['user'] ?? payload_data['admin'];

      if (userMap == null) {
        throw ServerException(message: 'User Data Not Found...');
      }

      final uid = userMap['uid']?.toString() ?? '';
      userMap['role'] = role;
      _user = AppUser.fromMap(userMap as Map<String, dynamic>, uid);

      // store tokens if present
      final tokens = payload_data['tokens'];

      final accessToken = tokens['access_token'];
      final refreshToken = tokens['refresh_token'];

      await _persistTokens(accessToken?.toString(), refreshToken?.toString());

      notifyListeners();


      return null;
    } on DioException catch (e) {
      // Map Dio errors using DioClient's handler where possible
      final ex = mapDioException(e);
      // our mapping returns Exception subclasses that have `message` field
      if (ex is ServerException) return ex.message;
      if (ex is AuthenticationException) return ex.message;
      if (ex is ValidationException) return ex.message;
      if (ex is NetworkException) return ex.message;
      return 'An unexpected error occurred \n ${e.message}';
    } catch (e) {
      return e is Exception
          ? e.toString()
          : 'Server is Busy, please try again later';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final data = {'email': email, 'password': password};

      final response = await _dioClient.post(ApiEndpoints.login, data: data);

      final resp = response.data as Map<String, dynamic>;
      final statusCode = resp['statusCode'];
      if (statusCode == 200) {
        final payload_data = resp['data'] ?? resp;

        /*final userMap = payload_data['user'] ?? payload_data['admin'];

        if (userMap == null) {
          throw ServerException(message: 'Invalid server response');
        }

        final uid = userMap['id']?.toString() ?? userMap['uid']?.toString() ??
            '';
        _user = AppUser.fromMap(userMap as Map<String, dynamic>, uid);*/

        final accessToken =
            payload_data['access_token'] ?? resp['access_token'];
        final refreshToken =
            payload_data['refresh_token'] ?? resp['refresh_token'];
        await _persistTokens(accessToken?.toString(), refreshToken?.toString());
      } else {
        throw Exception(['Error while Log In Account...']);
      }
      return null;
    } on DioException catch (e) {
      final ex = mapDioException(e);
      if (ex is ServerException) return ex.message;
      if (ex is AuthenticationException) return ex.message;
      if (ex is ValidationException) return ex.message;
      if (ex is NetworkException) return ex.message;
      return 'An unexpected error occurred';
    } catch (e) {
      return 'An unknown error occurred';
    }
  }

  Future<String> sendVerificationCode(String email) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.forgotPassword(email),
      );
      final resp = response.data as Map<String, dynamic>;
      final statusCode = resp['statusCode'];
      if (statusCode == 200) {
        return 'ok';
      }
      return 'fail';
    } on DioException catch (e) {
      final ex = mapDioException(e);
      if (ex is ServerException) return ex.message;
      if (ex is AuthenticationException) return ex.message;
      if (ex is ValidationException) return ex.message;
      if (ex is NetworkException) return ex.message;
      return 'An unexpected error occurred';
    } catch (e) {
      return 'An unknown error occurred ${e.toString()}';
    }
  }

  Future<String?> registerNumber(String number) async {
    final data = {"mobileNumber": number};
    try {
      final response = await _dioClient.post(
        ApiEndpoints.registerMobile,
        data: data,
      );
      final resp = response.data as Map<String, dynamic>; // Parse response data
      final statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        return resp['message']?.toString() ?? 'success';
      } else {
        return resp['message']?.toString() ??
            'Failed to register number with status: $statusCode';
      }
    } on DioException catch (e) {
      final ex = mapDioException(e);
      if (ex is ServerException) return ex.message;
      if (ex is AuthenticationException) return ex.message;
      if (ex is ValidationException) return ex.message;
      if (ex is NetworkException) return ex.message;
      return 'An unexpected error occurred: ${e.message}';
    } catch (e) {
      return e is Exception
          ? e.toString()
          : 'An unknown error occurred: ${e.toString()}';
    }
  }

  Future<String?> verifyOTP(String code) async {
    final data = {"otp": code};
    try {
      final response = await _dioClient.post(
        ApiEndpoints.verifyOtp,
        data: data,
      );
      final resp = response.data as Map<String, dynamic>;
      final statusCode = resp['statusCode'];
      if (statusCode == 200) {
        return 'success';
      } else if (statusCode == 500) {
        throw Exception(['Number is already in use with different account...']);
      }
    } on DioException catch (e) {
      final ex = mapDioException(e);
      if (ex is ServerException) return ex.message;
      if (ex is AuthenticationException) return ex.message;
      if (ex is ValidationException) return ex.message;
      if (ex is NetworkException) return ex.message;
      return 'An unexpected error occurred';
    } catch (e) {
      return 'An unknown error occurred ${e.toString()}';
    }
    return 'fail';
  }

  Future<String> resetPassword(
    String email,
    String code,
    String newPass,
  ) async {
    final data = {"email": email, "otp": code, "newPassword": newPass};
    try {
      final response = await _dioClient.post(
        ApiEndpoints.resetPassword,
        data: data,
      );
      final resp = response.data as Map<String, dynamic>;
      final statusCode = resp['statusCode'];
      if (statusCode == 200) {
        return 'success';
      }
      return 'fail';
    } on DioException catch (e) {
      final ex = mapDioException(e);
      if (ex is ServerException) return ex.message;
      if (ex is AuthenticationException) return ex.message;
      if (ex is ValidationException) return ex.message;
      if (ex is NetworkException) return ex.message;
      return 'An unexpected error occurred';
    } catch (e) {
      return 'An unknown error occurred ${e.toString()}';
    }
  }

  Future<String> updateFCMToken(String token) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.updateFCMToken(token),
      );
      final resp = response.data as Map<String, dynamic>;
      final statusCode = resp['statusCode'];
      if (statusCode == 200) {
        return 'success';
      }
      return 'fail';
    } on DioException catch (e) {
      final ex = mapDioException(e);
      if (ex is ServerException) return ex.message;
      if (ex is AuthenticationException) return ex.message;
      if (ex is ValidationException) return ex.message;
      if (ex is NetworkException) return ex.message;
      return 'An unexpected error occurred';
    } catch (e) {
      return 'An unknown error occurred ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', false);
    prefs.remove('isAdmin');
    // remove tokens
    prefs.remove('access_token');
    prefs.remove('refresh_token');
    _user = null;
    notifyListeners();
  }

  Future<String?> updateUserLocation() async {
    // TODO: Implement your own logic to update user location
    return 'Location updated';
  }

  Future<bool> addLocation(Map<String, dynamic> address) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.addAddresses,
        data: address,
      );
      final resp = response.data as Map<String, dynamic>;
      final statusCode = resp['statusCode'];
      if (statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLocationFromList(int addressId) async {
    final response = await _dioClient.delete(
      ApiEndpoints.deleteAddress(addressId),
    );
    final resp = response.data as Map<String, dynamic>;
    final statusCode = resp['statusCode'];
    if (statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<AddressModel>> getLocationList() async {
    List<AddressModel> addressList = [];
    try {
      final response = await _dioClient.get(ApiEndpoints.getAllAddresses);
      final resp = response.data as Map<String, dynamic>;
      final statusCode = resp['statusCode'];
      if (statusCode == 200) {
        final payload_data = resp['data'] ?? resp;
        for (var item in payload_data) {
          AddressModel model = AddressModel.fromMap(item);
          addressList.add(model);
        }
        return addressList;
      }
      return addressList;
    } catch (e) {
      return [];
    }
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.me);
      final resp = response.data as Map<String, dynamic>;
      final statusCode = resp['statusCode'];
      if (statusCode == 200) {
        final payload_data = resp['data'] ?? resp;

        final userMap =
            payload_data['user'] ??
            payload_data['admin'] ??
            payload_data['profile'];

        if (userMap == null) {
          throw ServerException(message: 'Invalid server response');
        }

        final uid =
            userMap['id']?.toString() ?? userMap['uid']?.toString() ?? '';
        _user = AppUser.fromMap(userMap as Map<String, dynamic>, uid);

        notifyListeners();

      } else {
        throw Exception(['Error while Fetching User Data...']);
      }
      return _user;
    } on DioException catch (e) {
      final ex = mapDioException(e);
      if (ex is ServerException) {
        print(ex.message);
        return null;
      }
      if (ex is AuthenticationException) {
        print(ex.message);
        return null;
      }
      if (ex is ValidationException) {
        print(ex.message);
        return null;
      }
      if (ex is NetworkException) {
        print(ex.message);
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
    return _user;
  }

  /// Refreshes the access token using the stored refresh token.
  /// Returns the new access token if successful, otherwise null.
  Future<String?> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedRefreshToken = prefs.getString('refresh_token');

      if (storedRefreshToken == null) {
        print("step 1 : refresh token is null");
        await signOut();
        return null;
      }

      final response = await _dioClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': storedRefreshToken},
      );
      if (response.statusCode == 200) {
        final resp = response.data as Map<String, dynamic>;
        final newAccessToken = resp['data']['access_token']?.toString();
        final newRefreshToken = resp['data']['refresh_token']?.toString();

        if (newAccessToken != null && newRefreshToken != null) {
          await _persistTokens(newAccessToken, newRefreshToken);
          return newAccessToken;
        } else {
          print("step 2 : after calling api both access and refresh token are null");
          await signOut();
          return null;
        }
      } else if (response.statusCode == 401) {
        throw Exception(response.statusMessage);
      }
      throw ServerException(message: 'Error While Refreshing Token...');
    } on DioException catch (e) {
      final ex = mapDioException(e);
      if (ex is AuthenticationException) {
        print("step 3 : Get Authentication exception ${ex.message}");
        await signOut();
      }
      return null;
    } catch (e) {
      print("step 4 : Get Exception ${e.toString()}");
      await signOut();
      return null;
    }
  }

  // Helper: persist tokens and set default header
  Future<void> _persistTokens(String? accessToken, String? refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      prefs.setString('access_token', accessToken);
      // ✅ FIXED: Use accessToken instead of refreshToken for Authorization header
      _dioClient.dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
    if (refreshToken != null) {
      prefs.setString('refresh_token', refreshToken);
    }
  }
}