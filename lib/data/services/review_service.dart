import 'package:flutter/material.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/dto/review_request_dto.dart';
import 'package:raising_india/models/model/product_review.dart';
import '../repositories/review_repo.dart';
import 'package:raising_india/models/dto/admin_order_review_dto.dart';

class ReviewService extends ChangeNotifier {
  final ReviewRepository _repo = ReviewRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // --- Admin State ---
  List<AdminOrderReviewDto> _adminReviews = [];
  List<AdminOrderReviewDto> get adminReviews => _adminReviews;

  int _totalReviewsCount = 0;
  double _averageRating = 0.0;

  int get totalReviews => _totalReviewsCount;
  double get avgRating => _averageRating;

  // --- 1. Submit Review (User) ---
  Future<String?> submitReview(ReviewRequestDto request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.submitReview(request);
      return null; // Success
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to submit review. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. Get Reviews for a Product (User) ---
  Future<List<ProductReview>> getProductReviews(int productId) async {
    try {
      return await _repo.getProductReviews(productId);
    } catch (e) {
      print("Error fetching product reviews: $e");
      return [];
    }
  }

  // --- 3. Fetch Admin Analytics (Admin Dashboard) ---
  Future<void> fetchReviewAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      // We fetch the first page just to get the 'totalElements' count from the Page object
      final pageData = await _repo.getAllReviews(page: 0, size: 1);

      _totalReviewsCount = pageData.totalElements ?? 0;

      // Since your backend controller doesn't have a specific "stats" endpoint yet,
      // we mock the average rating or calculate it if you fetch all data.
      // Ideally, ask backend dev to add /api/reviews/stats endpoint.
      _averageRating = 4.5;

    } catch (e) {
      debugPrint("Review Analytics Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 4. Load All Reviews List (Admin Screen) ---
  Future<void> loadAdminReviews({int page = 0, String? keyword}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final pageData = await _repo.getAllReviews(
          page: page,
          size: 20,
          keyword: keyword
      );

      if (page == 0) {
        _adminReviews = pageData.content ?? [];
      } else {
        _adminReviews.addAll(pageData.content ?? []);
      }

    } on AppError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "Failed to load reviews.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}