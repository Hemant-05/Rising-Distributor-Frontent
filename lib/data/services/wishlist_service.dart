import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/wishlist_repo.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/wishlist.dart';

class WishlistService extends ChangeNotifier {
  final WishlistRepository _repo = WishlistRepository();

  List<Wishlist> _items = [];
  List<Wishlist> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchWishlist(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _repo.getWishlist(userId);
    } catch (e) {
      print("Wishlist Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addToWishlist(String userId, String pid) async {
    try {
      await _repo.add(userId, pid);
      await fetchWishlist(userId);
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to add to wishlist.";
    }
  }

  Future<String?> removeFromWishlist(String userId, String pid) async {
    try {
      await _repo.remove(userId, pid);
      _items.removeWhere((w) => w.product?.pid == pid);
      notifyListeners();
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to remove.";
    }
  }
}