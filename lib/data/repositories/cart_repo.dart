import 'package:raising_india/error/exceptions.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';
import '../../../models/dto/cart_dtos.dart';

class CartRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<List<CartItemDto>> getCartItems() async {
    try {
      final response = await _client.getCartItems();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> getCartCount() async {
    try {
      final response = await _client.getCartItemCount();
      return response.data ?? 0;
    } catch (e) {
      // Return 0 on error so UI doesn't crash
      return 0;
    }
  }

  Future<bool> addToCart(String productId, int quantity) async {
    try {
      final request = CartRequestDto(productId: productId, quantity: quantity);
      final response = await _client.addToCart(request);
      return response.data ?? false;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<bool> updateQuantity(String productId, int quantity) async {
    try {
      final request = CartRequestDto(productId: productId, quantity: quantity);
      final response = await _client.updateCartQuantity(request);
      return response.data ?? false;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<bool> removeFromCart(String productId) async {
    try {
      final response = await _client.removeCartItem(productId);
      return response.data ?? false;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<bool> clearCart() async {
    try {
      final response = await _client.clearCart();
      return response.data ?? false;
    } catch (e) {
      throw handleError(e);
    }
  }

  // Returns { "inCart": true, "quantity": 5 }
  Future<Map<String, dynamic>> getCartStatus(String productId) async {
    try {
      final response = await _client.getCartStatus(productId);
      return response.data ?? {};
    } catch (e) {
      return {};
    }
  }
}