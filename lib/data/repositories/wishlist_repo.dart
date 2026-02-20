import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/wishlist.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

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

  Future<void> add(String userId, String pid) async {
    try {
      await _client.addToWishlist(userId, pid);
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> remove(String userId, String pid) async {
    try {
      await _client.removeFromWishlist(userId, pid);
    } catch (e) {
      throw handleError(e);
    }
  }
}