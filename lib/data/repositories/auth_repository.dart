import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/admin.dart';
import 'package:raising_india/models/model/customer.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';
import '../../../models/dto/auth_dtos.dart';
import '../../../models/dto/auth_response.dart';
import '../../../models/dto/token_password_dtos.dart';
import '../../../models/dto/user_profile_response.dart';

class AuthRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<Admin> updateAdminProfile(String uid, String name, String email) async {
    try {
      final response = await _client.updateAdminProfile(uid, {
        "name": name,
        "email": email,
      });
      return response.data!; // Returns the newly updated Admin object
    } catch (e) {
      throw handleError(e); // Assuming you have your RepoErrorHandler mixin here
    }
  }

  Future<Customer> updateCustomerProfile(String uid, String name, String email) async {
    try {
      final response = await _client.updateUserProfile(uid, {
        "name": name,
        "email": email,
      });
      return response.data!; // Returns the newly updated Customer object
    } catch (e) {
      throw handleError(e); // Assuming you have your RepoErrorHandler mixin here
    }
  }


  // --- 1. LOGIN ---
  Future<AuthResponse> login(String email, String password) async {
    try {
      final request = LogInRequest(email: email, password: password);
      final response = await _client.login(request);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- 2. REGISTER USER (Returns {customer: ..., tokens: ...}) ---
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String mobileNumber,
  }) async {
    try {
      final request = RegistrationRequest(
        name: name,
        email: email,
        password: password,
        number: mobileNumber,
      );
      final response = await _client.registerUser(request);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- 3. REFRESH TOKEN ---
  Future<AuthResponse> refreshToken(String token) async {
    try {
      final request = RefreshTokenRequest(refreshToken: token);
      final response = await _client.refreshToken(request);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- 4. GET PROFILE ---
  Future<UserProfileResponse> getUserProfile() async {
    try {
      final response = await _client.getCurrentUserProfile();
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- 5. PASSWORD MANAGEMENT ---
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _client.forgotPassword(email);
      return response.message ?? "OTP sent successfully";
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      final request = ResetPasswordDto(email: email, otp: otp, newPassword: newPassword);
      await _client.resetPassword(request);
    } catch (e) {
      throw handleError(e);
    }
  }
}