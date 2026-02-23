import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/brand_repo.dart';
import 'package:raising_india/models/model/brand.dart';
import 'package:raising_india/models/model/product.dart';

import '../../error/exceptions.dart';

class BrandService extends ChangeNotifier {
  final BrandRepository _repo = BrandRepository();

  // State for Brands List
  List<Brand> _brands = [];
  List<Brand> get brands => _brands;

  // State for Products filtered by Brand
  List<Product> _brandProducts = [];
  List<Product> get brandProducts => _brandProducts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = "";
  String get error => _error;


  // --- 1. Fetch All Brands ---
  Future<void> fetchBrands() async {
    // Avoid refreshing if we already have data (optional optimization)
    if (_brands.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();
    try {
      _brands = await _repo.getAllBrands();

    } catch (e) {
      _error = "Failed to load brands. ${e.toString()}";
      print("Brand Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. Add Brand (Admin) ---
  Future<String?> addBrand(Brand brand) async {
    try {
      await _repo.addBrand(brand);
      // Clear list to force refresh next time user visits brands page
      _brands.clear();
      await fetchBrands();
      return null; // Success
    } on AppError catch (e) {
      _error = e.toString();
      return e.message;
    } catch (e) {
      _error = "Failed to add brand. ${e.toString()}";
      return "Failed to add brand.";
    }
  }

  // --- 3. Get Products by Brand ---
  Future<String?> fetchProductsByBrand(int brandId) async {
    _isLoading = true;
    _brandProducts = []; // Clear previous selection
    notifyListeners();
    try {
      _brandProducts = await _repo.getProductsByBrand(brandId);
      return null;
    } on AppError catch (e) {
      _error = e.toString();
      return e.message;
    } catch (e) {
      _error = "Failed to load products for this brand. ${e.toString()}";
      return "Failed to load products for this brand.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}