import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/cart.dart';
import 'package:raising_india/models/model/coupon.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class CouponRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  // --- USER METHODS ---

  Future<Cart> applyCoupon(String userId, String code) async {
    try {
      final response = await _client.applyCoupon(userId, code);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Cart> removeCoupon(String userId) async {
    try {
      final response = await _client.removeCoupon(userId);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- ADMIN METHODS ---

  Future<Coupon> createCoupon(Coupon coupon) async {
    try {
      final response = await _client.createCoupon(coupon);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<Coupon>> getAllCoupons() async {
    try {
      final response = await _client.getAllCoupons();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> deleteCoupon(int id) async {
    try {
      await _client.deleteCoupon(id);
    } catch (e) {
      throw handleError(e);
    }
  }
}