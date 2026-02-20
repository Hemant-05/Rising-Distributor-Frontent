import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/cart_repo.dart';
import 'package:raising_india/data/repositories/product_repo.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/dto/cart_dtos.dart';
import 'package:raising_india/models/model/product.dart';

import '../../models/model/cart_item.dart';

class CartService extends ChangeNotifier {
  final CartRepository _cartRepo = CartRepository();
  final ProductRepository _productRepo = ProductRepository();

  // The UI listens to this list of "Rich" objects
  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- 1. Fetch & Hydrate ---
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Step A: Get List of IDs from Backend (List<CartItemDto>)
      final List<CartItemDto> dtos = await _cartRepo.getCartItems();

      final List<CartItem> loadedItems = [];

      // Step B: Loop through DTOs and fetch full Product for each
      // Future.wait makes these calls run in parallel (Fast!)
      await Future.wait(dtos.map((dto) async {
        if (dto.productId != null) {
          try {
            // CALL PRODUCT API using the ID
            final Product fullProduct = await _productRepo.getProduct(dto.productId!);

            // Map to YOUR CartItem model
            loadedItems.add(CartItem(
              // DTO doesn't usually have a CartItem ID, so we leave it null or use what's available
              product: fullProduct,
              quantity: dto.quantity ?? 1,
            ));
          } catch (e) {
            print("Product ID ${dto.productId} not found or deleted");
          }
        }
      }));

      _cartItems = loadedItems;

    } catch (e) {
      print("Cart Load Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. Add / Update / Remove ---

  Future<String?> addToCart(String productId, int quantity) async {
    try {
      await _cartRepo.addToCart(productId, quantity);
      await fetchCart(); // Refresh to see changes
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to add item.";
    }
  }

  Future<String?> updateQuantity(String productId, int quantity) async {
    try {
      await _cartRepo.updateQuantity(productId, quantity);

      // OPTIMISTIC UPDATE: Find item by Product ID and update quantity locally
      final index = _cartItems.indexWhere((item) => item.product?.pid == productId);
      if (index != -1) {
        final oldItem = _cartItems[index];
        _cartItems[index] = CartItem(
          id: oldItem.id,
          product: oldItem.product,
          quantity: quantity,
        );
        notifyListeners();
      }
      return null;
    } on AppError catch (e) {
      await fetchCart(); // Revert if failed
      return e.message;
    } catch (e) {
      return "Failed to update.";
    }
  }

  Future<String?> removeFromCart(String productId) async {
    try {
      // Optimistic Remove
      _cartItems.removeWhere((item) => item.product?.pid == productId);
      notifyListeners();

      await _cartRepo.removeFromCart(productId);
      return null;
    } on AppError catch (e) {
      await fetchCart();
      return e.message;
    } catch (e) {
      return "Failed to remove.";
    }
  }

  Future<Map<String,dynamic>> isInCart(String productId) async {
    try {
      return await _cartRepo.getCartStatus(productId);
    } on AppError catch (e) {
      await fetchCart();
      return {
        "error" : e.message
      };
    } catch (e) {
      return {'error': "Failed to remove."};
    }
  }

  Future<void> clearCart() async {
    try {
      _cartItems.clear();
      notifyListeners();
      await _cartRepo.clearCart();
    } catch (e) {
      await fetchCart();
    }
  }
}