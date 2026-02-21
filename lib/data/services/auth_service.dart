import 'package:dio/dio.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/data/repositories/auth_repository.dart';
import 'package:raising_india/models/dto/auth_response.dart';
import 'package:raising_india/models/model/admin.dart';
import 'package:raising_india/models/model/customer.dart';
import 'package:raising_india/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  final Dio _dio = getIt<Dio>(); // For updating headers

  Customer? _customer;
  Admin? _admin;

  bool get isCustomer => _customer != null;
  bool get isAdmin => _admin != null;

  // Helpers
  String? get currentUid => _customer?.uid ?? _admin?.uid;
  Customer? get customer => _customer;
  Admin? get admin => _admin;

  AuthService() {
    loadUserFromStorage();
  }

  // --- 1. SIGN IN ---
  Future<String?> signIn(String email, String password) async {
    try {
      // 1. Get Tokens
      final authResponse = await _repo.login(email, password);

      // 2. Save & Set Headers
      await _persistTokens(authResponse.accessToken, authResponse.refreshToken);

      // 3. Fetch Profile
      await _fetchAndSetUser();

      return null; // Success
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Login failed. Please try again.";
    }
  }

  // --- 2. SIGN UP (Auto-Login included) ---
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String mobileNumber,
  }) async {
    try {
      // 1. Call Register
      final data = await _repo.registerUser(
        name: name,
        email: email,
        password: password,
        mobileNumber: mobileNumber,
      );

      // 2. Extract Tokens (Backend returns them in "tokens" key)
      // Structure: { "customer": {...}, "tokens": { "access_token": "...", "refresh_token": "..." } }
      if (data.containsKey('tokens')) {
        final tokenMap = data['tokens'] as Map<String, dynamic>;
        // Map manually or use AuthResponse.fromJson if structure matches
        final accessToken = tokenMap['access_token'] ?? tokenMap['accessToken'];
        final refreshToken = tokenMap['refresh_token'] ?? tokenMap['refreshToken'];

        // 3. Auto-Login logic
        if (accessToken != null) {
          await _persistTokens(accessToken, refreshToken);
          await _fetchAndSetUser();
        }
      }

      return null; // Success
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Registration failed.";
    }
  }

  // --- 3. REFRESH TOKEN ---
  Future<AuthResponse?> tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        await signOut();
        return null;
      }

      final newTokens = await _repo.refreshToken(refreshToken);
      await _persistTokens(newTokens.accessToken, newTokens.refreshToken);
      return newTokens;
    } catch (e) {
      // If refresh fails, force logout
      await signOut();
      return null;
    }
  }

  // --- 4. PROFILE & ROLE LOGIC ---
  Future<void> _fetchAndSetUser() async {
    try {
      final profile = await _repo.getUserProfile();

      _customer = null;
      _admin = null;

      if (profile.role == "USER") {
        _customer = Customer(
          uid: profile.uid,
          name: profile.name,
          email: profile.email,
          mobileNumber: profile.mobileNumber,
          isMobileVerified: profile.isMobileVerified,
        );
      } else {
        _admin = Admin(
          uid: profile.uid,
          name: profile.name,
          email: profile.email,
          role: profile.role,
        );
      }
      notifyListeners();
    } catch (e) {
      // If fetching profile fails (e.g. 401), try refreshing token once
      if (e is AuthenticationException) {
        // Logic to try refresh token could go here, for now we sign out
        await signOut();
      }
    }
  }

  // --- 5. FORGOT PASSWORD ---
  Future<String> sendVerificationCode(String email) async {
    try {
      await _repo.forgotPassword(email);
      return 'ok';
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to send OTP.';
    }
  }

  Future<String> resetPassword(String email, String otp, String newPass) async {
    try {
      await _repo.resetPassword(email, otp, newPass);
      return 'success';
    } catch (e) {
      return 'fail';
    }
  }

  // --- 6. SESSION ---
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _customer = null;
    _admin = null;
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _fetchAndSetUser();
    }
  }

  Future<void> _persistTokens(String? access, String? refresh) async {
    final prefs = await SharedPreferences.getInstance();
    if (access != null) {
      await prefs.setString('access_token', access);
      _dio.options.headers['Authorization'] = 'Bearer $access';
    }
    if (refresh != null) {
      await prefs.setString('refresh_token', refresh);
    }
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
  }
}