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
  final Dio _dio = getIt<Dio>();

  Customer? _customer;
  Admin? _admin;

  bool get isCustomer => _customer != null;
  bool get isAdmin => _admin != null;

  // ✅ FIX 1: Default to TRUE.
  // The app starts in a "checking" state. No need to notify listeners to start loading.
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Helpers
  String? get currentUid => _customer?.uid ?? _admin?.uid;
  Customer? get customer => _customer;
  Admin? get admin => _admin;

  AuthService() {
    loadUserFromStorage();
  }

  Future<void> loadUserFromStorage() async {
    // ✅ FIX 2: Removed "isLoading = true" and "notifyListeners" from here.
    // We are already loading by default.

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
        // This will verify the token and set the user roles
        await _fetchAndSetUser();
      }
    } catch (e) {
      // If anything fails during startup check, clear everything
      await signOut();
    } finally {
      // ✅ FIX 3: Only notify ONCE when the check is totally finished.
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 1. SIGN IN ---
  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final authResponse = await _repo.login(email, password);
      await _persistTokens(authResponse.accessToken, authResponse.refreshToken);
      await _fetchAndSetUser();

      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Login failed. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. SIGN UP ---
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String mobileNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _repo.registerUser(
        name: name,
        email: email,
        password: password,
        mobileNumber: mobileNumber,
      );

      if (data.containsKey('tokens')) {
        final tokenMap = data['tokens'] as Map<String, dynamic>;
        final accessToken = tokenMap['access_token'] ?? tokenMap['accessToken'];
        final refreshToken = tokenMap['refresh_token'] ?? tokenMap['refreshToken'];

        if (accessToken != null) {
          await _persistTokens(accessToken, refreshToken);
          await _fetchAndSetUser();
        }
      }
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Registration failed.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 3. REFRESH TOKEN ---
  Future<AuthResponse?> tryRefreshToken() async {
    // No change needed here, logic is fine
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        await signOut();
        return null;
      }

      final newTokens = await _repo.refreshToken(refreshToken);
      await _persistTokens(newTokens.accessToken, newTokens.refreshToken);
      await _fetchAndSetUser();

      return newTokens;
    } catch (e) {
      await signOut();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 4. PROFILE & ROLE LOGIC ---
  Future<void> _fetchAndSetUser() async {
    // This logic is solid.
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
    // Note: We don't notifyListeners here anymore for loadUserFromStorage,
    // because loadUserFromStorage handles the final notification.
    // But for login/signup flows, the finally block handles it.
  }

  // --- 6. SESSION ---
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _customer = null;
    _admin = null;
    _dio.options.headers.remove('Authorization'); // Clear header too

    _isLoading = false;
    notifyListeners();
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

  // --- 5. FORGOT PASSWORD ---
  Future<String> sendVerificationCode(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return 'ok';
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to send OTP.';
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> resetPassword(String email, String otp, String newPass) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.resetPassword(email, otp, newPass);
      return 'success';
    } catch (e) {
      return 'fail';
    }finally{
      _isLoading = false;
      notifyListeners();
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