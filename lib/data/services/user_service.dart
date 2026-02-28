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

  Future<String?> registerMobile(String mobile) async {
    try {
      await _repo.saveMobile(mobile);
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to send OTP.";
    }
  }

  Future<String?> verifyMobile(String otp) async {
    try {
      await _repo.verifyMobile(otp);
      await loadProfile(); // Refresh profile status
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to verify OTP.";
    }
  }

  Future<String?> updateFCM(String token)async{
    try{
      String? res = await _repo.updateFcm(token);
      return res;
    } on AppError catch(e){
      return e.message;
    } catch(e){
      return e.toString();
    }
  }
}