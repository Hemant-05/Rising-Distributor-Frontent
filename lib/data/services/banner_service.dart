import 'dart:io';
import 'package:flutter/material.dart' hide Banner;
import 'package:raising_india/data/repositories/banner_repo.dart';
import 'package:raising_india/data/services/image_service.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/banner.dart';

class BannerService extends ChangeNotifier {
  final BannerRepository _repo = BannerRepository();

  // State: Public Banners (Active Only)
  List<Banner> _homeBanners = [];
  List<Banner> get homeBanners => _homeBanners;

  // State: Admin Banners (All)
  List<Banner> _adminBanners = [];
  List<Banner> get adminBanners => _adminBanners;

  // Alias for UI convenience (if your Admin UI uses .banners)
  List<Banner> get banners => _adminBanners;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- 1. Customer: Load Active Banners ---
  Future<void> loadHomeBanners() async {
    _isLoading = true;
    notifyListeners();
    try {
      _homeBanners = await _repo.getActiveBanners();
    } catch (e) {
      print("Banner Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. Admin: Load All Banners ---
  Future<void> loadAdminBanners() async {
    _isLoading = true;
    notifyListeners();
    try {
      _adminBanners = await _repo.getAllBannersAdmin();
    } catch (e) {
      print("Admin Banner Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 3. Admin: Add Banner (Modified to handle File Upload) ---
  Future<String?> addBanner(File imageFile, ImageService imageService) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Step A: Upload Image using ImageService
      final String? imageUrl = await imageService.uploadImage(imageFile);

      if (imageUrl == null) {
        throw Exception("Image upload failed");
      }

      // Step B: Save Banner details to Backend
      // Passing null for route as per your UI flow
      await _repo.addBanner(imageUrl, null);

      // Step C: Refresh Admin List
      await loadAdminBanners();

      return null; // Success
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to add banner: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 4. Admin: Delete Banner ---
  Future<String?> deleteBanner(int id) async {
    // Optimistic Update
    final index = _adminBanners.indexWhere((b) => b.id == id);
    Banner? backup;
    if (index != -1) {
      backup = _adminBanners[index];
      _adminBanners.removeAt(index);
      notifyListeners();
    }

    try {
      await _repo.deleteBanner(id);
      return null;
    } on AppError catch (e) {
      // Revert if failed
      if (backup != null) {
        _adminBanners.insert(index, backup);
        notifyListeners();
      }
      return e.message;
    } catch (e) {
      if (backup != null) {
        _adminBanners.insert(index, backup);
        notifyListeners();
      }
      return "Failed to delete banner.";
    }
  }

  // --- 5. Admin: Toggle Status ---
  Future<String?> toggleStatus(int id) async {
    try {
      final updatedBanner = await _repo.toggleStatus(id);

      final index = _adminBanners.indexWhere((b) => b.id == id);
      if (index != -1) {
        _adminBanners[index] = updatedBanner;
        notifyListeners();
      }
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to toggle status.";
    }
  }
}