import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/banner.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class BannerRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  // --- PUBLIC ---
  Future<List<Banner>> getActiveBanners() async {
    try {
      final response = await _client.getActiveBanners();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- ADMIN ---
  Future<List<Banner>> getAllBannersAdmin() async {
    try {
      final response = await _client.getAllBannersAdmin();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Banner> addBanner(String imageUrl, String? redirectRoute) async {
    try {
      final response = await _client.addBanner(imageUrl, redirectRoute);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> deleteBanner(int id) async {
    try {
      await _client.deleteBanner(id);
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Banner> toggleStatus(int id) async {
    try {
      final response = await _client.toggleBannerStatus(id);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }
}