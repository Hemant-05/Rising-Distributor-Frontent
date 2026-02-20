import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/category.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class CategoryRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  // --- PUBLIC ---
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _client.getAllCategories();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Category> getCategoryById(int id) async {
    try {
      final response = await _client.getCategoryById(id);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- ADMIN ---
  Future<Category> createCategory(String name, int? parentId) async {
    try {
      final response = await _client.createCategory(name, parentId);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Category> updateCategory(int id, Category category) async {
    try {
      final response = await _client.updateCategory(id, category);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await _client.deleteCategory(id);
      return response.data ?? false;
    } catch (e) {
      throw handleError(e);
    }
  }
}