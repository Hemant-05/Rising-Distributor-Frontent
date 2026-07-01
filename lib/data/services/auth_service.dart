import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/data/repositories/auth_repository.dart';
import 'package:raising_india/models/dto/auth_response.dart';
import 'package:raising_india/models/model/admin.dart';
import 'package:raising_india/models/model/customer.dart';
import 'package:raising_india/services/notification_service.dart';
import 'package:raising_india/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  final Dio _dio = getIt<Dio>();
  bool _googleSignInInitialized = false;
  static const String _googleServerClientId =
      '462845774640-meljhuf4h5pqc96pqra70kuv3fbh5i2q.apps.googleusercontent.com';

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

  Future<String?> updateAdminProfile(String name, String email) async {
    if (_admin == null || _admin!.uid == null) return "Admin not found.";

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Call the repository
      final updatedAdmin = await _repo.updateAdminProfile(
        _admin!.uid!,
        name,
        email,
      );

      // 2. Update the local admin state so the app UI refreshes immediately!
      _admin = Admin(
        uid: updatedAdmin.uid,
        name: updatedAdmin.name,
        email: updatedAdmin.email,
        role: updatedAdmin.role,
      );

      return null; // Success!
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to update profile. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateCustomerProfile(String name, String email) async {
    if (_customer == null || _customer!.uid == null) {
      return "Customer not found.";
    }

    _isLoading = true;
    notifyListeners();

    try {
      final updateCustomer = await _repo.updateCustomerProfile(
        _customer!.uid!,
        name,
        email,
      );
      _customer = Customer(
        uid: updateCustomer.uid,
        name: updateCustomer.name,
        email: updateCustomer.email,
        mobileNumber: updateCustomer.mobileNumber,
        isMobileVerified: updateCustomer.isMobileVerified,
      );
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to update profile. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserFromStorage() async {
    // ✅ FIX 2: Removed "isLoading = true" and "notifyListeners" from here.
    // We are already loading by default.

    try {
      print("DEBUG: loadUserFromStorage started");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      print("DEBUG: token from storage: $token");

      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
        // This will verify the token and set the user roles
        print("DEBUG: Fetching user profile...");
        await _fetchAndSetUser();
        print("DEBUG: User profile fetched. Syncing FCM token...");
        await NotificationBackgroundService.syncFCMTokenWithServer();
        print("DEBUG: FCM token synced.");
      }
    } catch (e) {
      print("DEBUG: Exception in loadUserFromStorage: $e");
      // If anything fails during startup check, clear everything
      await signOut();
    } finally {
      // ✅ FIX 3: Only notify ONCE when the check is totally finished.
      print("DEBUG: Setting _isLoading to false");
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 1. SIGN IN ---
  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (email.isEmpty || password.isEmpty) {
        return "All fields are required";
      }
      if (!email.contains('@') || !email.contains('.')) {
        return "Invalid email format";
      }
      if (password.length < 6) {
        return "Password must be at least 6 characters long";
      }

      final authResponse = await _repo.login(email, password);
      await _persistTokens(authResponse.accessToken, authResponse.refreshToken);
      await _fetchAndSetUser();
      await NotificationBackgroundService.syncFCMTokenWithServer();

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
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      var data = {};
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return "All fields are required";
      }
      if (!email.contains('@') || !email.contains('.')) {
        return "Invalid email format";
      }
      if (password.length < 6) {
        return "Password must be at least 6 characters long";
      }
      if (role == user) {
        data = await _repo.registerUser(
          name: name,
          email: email,
          password: password,
        );
      } else {
        data = await _repo.registerAdmin(
          name: name,
          email: email,
          password: password,
        );
      }

      await NotificationBackgroundService.syncFCMTokenWithServer();

      if (data.containsKey('tokens')) {
        final tokenMap = data['tokens'] as Map<String, dynamic>;
        final accessToken = tokenMap['access_token'] ?? tokenMap['accessToken'];
        final refreshToken =
            tokenMap['refresh_token'] ?? tokenMap['refreshToken'];

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

  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final firebaseIdToken = await _getFirebaseGoogleIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        return 'Google sign-in could not get a valid token.';
      }

      final fcmToken = await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      final data = await _repo.googleCustomerAuth(
        idToken: firebaseIdToken,
        fcmToken: fcmToken,
      );

      if (data.containsKey('tokens')) {
        final tokenMap = data['tokens'] as Map<String, dynamic>;
        final accessToken = tokenMap['access_token'] ?? tokenMap['accessToken'];
        final refreshToken =
            tokenMap['refresh_token'] ?? tokenMap['refreshToken'];

        if (accessToken != null) {
          await _persistTokens(accessToken, refreshToken);
          await _fetchAndSetUser();
          await NotificationBackgroundService.syncFCMTokenWithServer();
          return null;
        }
      }

      return 'Google sign-in failed: backend did not return tokens.';
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Google sign-in failed. Please try again.';
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return 'Google sign-in was cancelled.';
      }
      return e.description ?? 'Google sign-in failed. Please try again.';
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      return 'Google sign-in failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _getFirebaseGoogleIdToken() async {
    if (kIsWeb) {
      final provider = firebase_auth.GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      final credential = await firebase_auth.FirebaseAuth.instance
          .signInWithPopup(provider);
      return credential.user?.getIdToken();
    }

    await _ensureGoogleSignInInitialized();
    final googleUser = await GoogleSignIn.instance.authenticate(
      scopeHint: const ['email', 'profile'],
    );
    final googleAuth = googleUser.authentication;
    final googleIdToken = googleAuth.idToken;

    if (googleIdToken == null || googleIdToken.isEmpty) {
      return null;
    }

    final credential = firebase_auth.GoogleAuthProvider.credential(
      idToken: googleIdToken,
    );
    final userCredential = await firebase_auth.FirebaseAuth.instance
        .signInWithCredential(credential);
    return userCredential.user?.getIdToken();
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: _googleServerClientId,
    );
    _googleSignInInitialized = true;
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
    await firebase_auth.FirebaseAuth.instance.signOut();
    if (_googleSignInInitialized) {
      await GoogleSignIn.instance.signOut();
    }
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
    } finally {
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
    } finally {
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
