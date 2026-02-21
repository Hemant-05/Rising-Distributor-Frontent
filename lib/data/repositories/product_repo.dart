import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/dto/product_request.dart';
import 'package:raising_india/models/model/product.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class ProductRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<List<Product>> getAllAvailableProducts() async {
    try {
      final response = await _client.getAllAvailableProducts();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<Product>> getBestSelling() async {
    try {
      final response = await _client.getBestSellingProducts();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<Product>> getByCategory(String category) async {
    try {
      final response = await _client.getProductsByCategory(category);
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Product> getProduct(String pid) async {
    try {
      final response = await _client.getProduct(pid);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Map<String, dynamic>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String sort = "asc",
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _client.searchProducts(
          query, category, minPrice, maxPrice, sort, page, size
      );
      return response.data ?? {};
    } catch (e) {
      throw handleError(e);
    }
  }

  // Admin Methods
  Future<Product> addProduct(ProductRequest request) async {
    try {
      final res = await _client.addProduct(request);
      return res.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Product> updateProduct(String pid, ProductRequest request) async
  {
    try {
      final res = await _client.updateProduct(pid, request);
      return res.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> deleteProduct(String pid) async {
    try {
      await _client.deleteProduct(pid);
    } catch (e) {
      throw handleError(e);
    }
  }
}