import 'package:raising_india/data/rest_client.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/wishlist.dart';
import 'package:raising_india/services/service_locator.dart';

class WishlistRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<List<Wishlist>> getWishlist(String userId) async {
    try {
      final response = await _client.getWishlist(userId);
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> addToWishlist(String userId, String productPid) async {
    try {
      await _client.addToWishlist(userId, productPid);
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> removeFromWishlist(String userId, String productPid) async {
    try {
      await _client.removeFromWishlist(userId, productPid);
    } catch (e) {
      throw handleError(e);
    }
  }
}