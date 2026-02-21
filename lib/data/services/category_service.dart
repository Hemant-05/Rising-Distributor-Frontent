import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/category_repo.dart';
import 'package:raising_india/data/services/image_service.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/category.dart';

/*
class CategoryService extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CategoryService() {
    loadCategories();
  }

  // --- 1. Load All Categories ---
  Future<void> loadCategories() async {
    // If we already have data, don't show loading spinner, just refresh silently
    if (_categories.isEmpty) _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repo.getAllCategories();
    } catch (e) {
      print("Category Load Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. Create (Admin) ---
  Future<String?> createCategory(String name, int? parentId) async {
    try {
      await _repo.createCategory(name, parentId);
      await loadCategories(); // Refresh list to show new item
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to create category.";
    }
  }

  // --- 3. Update (Admin) ---
  Future<String?> updateCategory(int id, Category updatedData) async {
    try {
      await _repo.updateCategory(id, updatedData);
      await loadCategories(); // Refresh list
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to update category.";
    }
  }

  // --- 4. Delete (Admin) ---
  Future<String?> deleteCategory(int id) async {
    try {
      await _repo.deleteCategory(id);

      // Optimistic Update: Remove locally to feel faster
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();

      return null;
    } on AppError catch (e) {
      // If server failed (e.g. category has products), reload to undo local delete
      await loadCategories();
      return e.message;
    } catch (e) {
      await loadCategories();
      return "Failed to delete category.";
    }
  }
}*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/category_repo.dart';
import 'package:raising_india/models/model/category.dart';

class CategoryService extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Load Categories ---
  Future<void> loadCategories() async {
    // Show loading only if list is empty to prevent UI flicker on refresh
    if (_categories.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _categories = await _repo.getAllCategories();
    } catch (e) {
      debugPrint("Category Load Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Add Category ---
  Future<String?> addCategory({
    required String name,
    required File? imageFile,
    required int? parentId,
    required ImageService imageService,
    // Add other fields if your Category model requires them (e.g. parentId)
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;

      // 1. Upload Image if present
      if (imageFile != null) {
        final String? url = await imageService.uploadImage(imageFile);
        if (url == null) throw Exception("Image upload failed");
        imageUrl = url;
      }

      // 2. Create Category Object
      // ID is typically handled by backend or repo for new items
      final newCategory = Category(
        name: name,
        imageUrl: imageUrl,
      );

      // 3. Save to Repo
      // Adjust parameters based on your Repo's specific addCategory signature
      await _repo.createCategory(name, parentId); // Example: assuming createCategory takes name & parentId

      // 4. Refresh List
      await loadCategories();

      return null; // Success
    } catch (e) {
      return "Failed to add category: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Update Category ---
  Future<String?> updateCategory({
    required Category category,
    required File? newImageFile,
    required ImageService imageService,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl = category.imageUrl;

      // 1. Upload New Image if selected
      if (newImageFile != null) {
        final String? url = await imageService.uploadImage(newImageFile);
        if (url != null) {
          imageUrl = url;
        }
      }

      // 2. Create Updated Object
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        imageUrl: imageUrl,
        parentCategory: category.parentCategory,
        subCategories: category.subCategories,
      );

      // 3. Update in Repo
      if (category.id != null) {
        await _repo.updateCategory(category.id!, updatedCategory);
      } else {
        throw Exception("Category ID is missing");
      }

      // 4. Refresh List
      await loadCategories();

      return null;
    } catch (e) {
      return "Failed to update category: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Delete Category ---
  Future<String?> deleteCategory(int id) async {
    // Optimistic Update
    final index = _categories.indexWhere((c) => c.id == id);
    Category? deletedItem;

    if (index != -1) {
      deletedItem = _categories[index];
      _categories.removeAt(index);
      notifyListeners();
    }

    try {
      await _repo.deleteCategory(id);
      return null;
    } catch (e) {
      // Revert if failed
      if (deletedItem != null) {
        _categories.insert(index, deletedItem);
        notifyListeners();
      }
      return "Failed to delete category.";
    }
  }
}