import 'package:flutter/material.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/coupon.dart';

import '../repositories/coupon_repo.dart';

class CouponService extends ChangeNotifier {
  final CouponRepository _repo = CouponRepository();

  // For Admin List View
  List<Coupon> _coupons = [];
  List<Coupon> get coupons => _coupons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- USER LOGIC ---

  /// Applies coupon and returns the UPDATED Cart.
  /// You should pass this result to your CartService/Provider to update the UI.
  Future<dynamic> applyCoupon(String userId, String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedCart = await _repo.applyCoupon(userId, code);
      return updatedCart; // Success: Return Cart object
    } on AppError catch (e) {
      return e.message; // Error: Return String message
    } catch (e) {
      return "Failed to apply coupon.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<dynamic> removeCoupon(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedCart = await _repo.removeCoupon(userId);
      return updatedCart; // Success
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to remove coupon.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ADMIN LOGIC ---

  Future<void> fetchAllCoupons() async {
    _isLoading = true;
    notifyListeners();
    try {
      _coupons = await _repo.getAllCoupons();
    } catch (e) {
      print("Coupon Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createCoupon(Coupon coupon) async {
    try {
      await _repo.createCoupon(coupon);
      await fetchAllCoupons();
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to create coupon.";
    }
  }

  Future<String?> deleteCoupon(int id) async {
    try {
      await _repo.deleteCoupon(id);
      _coupons.removeWhere((c) => c.id == id);
      notifyListeners();
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to delete coupon.";
    }
  }
}