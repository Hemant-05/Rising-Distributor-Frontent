import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/dto/auth_dtos.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';
import '../../../models/dto/user_profile_response.dart';

class UserRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<UserProfileResponse> getProfile() async {
    try {
      final response = await _client.getCurrentUserProfile();
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> saveMobile(String mobile) async {
    try {
      await _client.saveMobileNumber(MobileRequest(mobileNumber: mobile));
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> verifyMobile(String otp) async {
    try {
      await _client.verifyMobile(OtpVerificationRequest(otp: otp));
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> updateFcm(String token) async {
    try {
      await _client.updateFcmToken(token);
    } catch (e) {
      // suppress error
    }
  }
}