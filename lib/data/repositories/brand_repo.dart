import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/brand.dart';
import 'package:raising_india/models/model/product.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class BrandRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  // 1. Add Brand
  Future<Brand> addBrand(Brand brand) async {
    try {
      // Direct return because controller doesn't use ApiResponse wrapper
      final response =  await _client.addBrand(brand);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // 2. Get All Brands
  Future<List<Brand>> getAllBrands() async {
    try {
      final response = await _client.getAllBrands();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  // 3. Get Products By Brand
  Future<List<Product>> getProductsByBrand(int brandId) async {
    try {
      final response = await _client.getProductsByBrand(brandId);
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }
}