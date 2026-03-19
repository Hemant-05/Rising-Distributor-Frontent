import 'package:raising_india/error/exceptions.dart';
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

  Future<void> verifyFirebaseToken(String token) async {
    try {
      await _client.verifyFirebaseToken({"token": token});
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> verifyTruecaller(String authCode, String codeVerifier) async {
    try {
      await _client.verifyTruecaller({
        "authCode": authCode,
        "codeVerifier": codeVerifier
      });
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<String?> updateFcm(String token) async {
    try {
      final res = await _client.updateFcmToken(token);
      return res.message;
    } catch (e) {
      return e.toString();
    }
  }
}