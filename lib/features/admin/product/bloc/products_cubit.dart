import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/models/product_model.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  // TODO: Replace with your custom backend service for products
  ProductsCubit(dynamic firestore) : super(ProductsState(products: []));

  StreamSubscription? _sub;

  void fetchProducts() {
    emit(state.copyWith(loading: true));
    // TODO: Implement fetching products from your custom backend
    // For now, simulating an empty list
    Future.delayed(Duration(seconds: 1), () {
      emit(ProductsState(products: []));
    });
  }

  Future<void> updateProductAvailable(String pid, bool value) async {
    // TODO: Implement updating product availability with your custom backend
    print('Updating product $pid availability to $value');
  }

  Future<void> deleteProduct(BuildContext context, String pid, List<String> urlList) async {
    try {
      // TODO: Implement image deletion from your custom backend
      for (String url in urlList) {
        await deleteImage(url);
      }
      // TODO: Implement product deletion from your custom backend
      print('Deleting product with ID: $pid');

      if (context.mounted) {
        Navigator.pop(context); // Close Product Detail Screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColour.primary,
            content: Text("Product deleted successfully", style: simple_text_style(color: AppColour.white)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColour.primary,
          content: Text("Delete failed: $e", style: simple_text_style(color: AppColour.white)),
        ),
      );
    }
  }

  // ✅ Delete image
  Future<bool> deleteImage(String downloadUrl) async {
    // TODO: Implement image deletion with your custom backend storage
    print('Deleting image from URL: $downloadUrl');
    return true; // Simulate success
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
