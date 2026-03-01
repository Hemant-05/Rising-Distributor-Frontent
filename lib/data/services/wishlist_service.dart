import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/wishlist_repo.dart';
import 'package:raising_india/models/model/product.dart';
import 'package:raising_india/models/model/wishlist.dart';

class WishlistService extends ChangeNotifier {
  final WishlistRepository _repo = WishlistRepository();

  List<Wishlist> _wishlistItems = [];
  List<Wishlist> get items => _wishlistItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Helper to quickly check if a product is favorited
  bool isInWishlist(String productPid) {
    return _wishlistItems.any((item) => item.product?.pid == productPid);
  }

  Future<void> fetchWishlist(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _wishlistItems = await _repo.getWishlist(userId);
    } catch (e) {
      print("Wishlist fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // OPTIMISTIC UI: Instantly toggle heart, sync in background
  Future<void> toggleWishlist(String userId, Product product) async {
    final pid = product.pid!;
    final isCurrentlyWished = isInWishlist(pid);

    if (isCurrentlyWished) {
      // 1. Optimistically Remove Locally
      final removedItemIndex = _wishlistItems.indexWhere((item) => item.product?.pid == pid);
      final removedItem = _wishlistItems.removeAt(removedItemIndex);
      notifyListeners();

      // 2. Sync with Server
      try {
        await _repo.removeFromWishlist(userId, pid);
      } catch (e) {
        // Revert if server fails
        _wishlistItems.insert(removedItemIndex, removedItem);
        notifyListeners();
      }
    } else {
      // 1. Optimistically Add Locally (Create a temporary model)
      final tempItem = Wishlist(userId: userId, product: product);
      _wishlistItems.insert(0, tempItem);
      notifyListeners();

      // 2. Sync with Server
      try {
        await _repo.addToWishlist(userId, pid);
      } catch (e) {
        // Revert if server fails
        _wishlistItems.removeWhere((item) => item.product?.pid == pid);
        notifyListeners();
      }
    }
  }
}