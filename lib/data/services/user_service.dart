import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/user_repo.dart';
import 'package:raising_india/error/exceptions.dart';
import '../../../models/dto/user_profile_response.dart';

class UserService extends ChangeNotifier {
  final UserRepository _repo = UserRepository();

  UserProfileResponse? _profile;
  UserProfileResponse? get profile => _profile;

  Future<void> loadProfile() async {
    try {
      _profile = await _repo.getProfile();
      notifyListeners();
    } catch (e) {
      print("Profile Error: $e");
    }
  }

  Future<String?> verifyFirebaseToken(String idToken) async {
    try {
      await _repo.verifyFirebaseToken(idToken);
      await loadProfile(); // Refresh profile status
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to verify with server.";
    }
  }

  Future<String?> sendMobileOtp(String mobileNumber) async {
    try {
      await _repo.sendMobileOtp(mobileNumber);
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to send OTP.";
    }
  }

  Future<String?> verifyMobileOtp(String mobileNumber, String otp) async {
    try {
      await _repo.verifyMobileOtp(mobileNumber, otp);
      await loadProfile();
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to verify OTP.";
    }
  }

  Future<String?> verifyTruecaller(String authCode, String codeVerifier) async {
    try {
      await _repo.verifyTruecaller(authCode, codeVerifier);
      await loadProfile(); // Refresh profile status
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to verify with Truecaller.";
    }
  }

  Future<String?> updateFCM(String token) async {
    try {
      String? res = await _repo.updateFcm(token);
      return res;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
