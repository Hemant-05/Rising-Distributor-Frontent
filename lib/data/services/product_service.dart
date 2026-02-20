import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/product_repo.dart';
import 'package:raising_india/data/services/image_service.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/dto/product_request.dart';
import 'package:raising_india/models/model/product.dart';

class ProductService extends ChangeNotifier {
  final ProductRepository _repo = ProductRepository();

  List<Product> _products = [];
  List<Product> get products => _products;

  String? _error;
  String? get error => _error;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // State for "Products by Category" screen
  List<Product> _categoryProducts = [];
  List<Product> get categoryProducts => _categoryProducts;

  List<Product> _bestSelling = [];
  List<Product> get bestSelling => _bestSelling;

  Future<void> fetchBestSelling() async {
    _isLoading = true;
    notifyListeners();
    try {
      _bestSelling = await _repo.getBestSelling();
    } catch (e) {
      _error = e.toString();
      print("Best Selling Fetch Error: $e");
    } finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategory(String categoryName) async {
    _isLoading = true;
    // Clear previous list to avoid showing wrong data while loading
    _categoryProducts = [];
    notifyListeners();

    try {
      _categoryProducts = await _repo.getByCategory(categoryName);
    } catch (e) {
      _error = e.toString();
      print("Category Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableProducts() async {
    if (_products.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _repo.getAllAvailableProducts();
    } catch (e) {
      _error = e.toString();
      print("Product Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> search(String query) async {
    try {
      final result = await _repo.searchProducts(query: query);
      // 'content' is the key Spring Page uses for the list
      final list = result['content'] as List;
      return list.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

// --- ADD PRODUCT ---
  Future<String?> addProduct(ProductRequest request, List<File> imageFiles, ImageService imageService) async {
    _isLoading = true;
    notifyListeners();
    List<String> imageUrls = [];
    try {

      // 1. Upload Images using the provided ImageService
      for (var file in imageFiles) {
        // We await each upload. You could also use Future.wait for parallel uploads.
        String? url = await imageService.uploadImage(file);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      if (imageUrls.isEmpty && imageFiles.isNotEmpty) {
        throw Exception("Failed to upload images. Please try again.");
      }

      // 2. Update Product Model with new URLs
      request.photosList!.insertAll(0, imageUrls);

      // 3. Save Product to Database
      Product product = await _repo.addProduct(request);

      _products.insert(_products.length-1, product);

      return null; // Success
    } catch (e) {
      for(String url in imageUrls){
        imageService.deleteImage(url);
      }
      if (e is AppError)
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<String?> updateProduct(Product product) async {
    _isLoading = true;
    try {
      Product updatedProduct = await _repo.updateProduct(product);
      int index = _products.indexWhere((p) => p.pid == product.pid);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } on AppError catch (e) {
      _error = e.message;
      _isLoading = false;
      return e.message;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return "Failed to update product.";
    }
  }

  Future<String?> deleteProduct(String pid) async {
    _isLoading = true;
    try {
      await _repo.deleteProduct(pid);
      _products.removeWhere((p) => p.pid == pid);
      _isLoading = false;
      notifyListeners();
      return null;
    } on AppError catch (e) {
      _error = e.message;
      _isLoading = false;
      return e.message;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return "Failed to delete product.";
    }
  }
}