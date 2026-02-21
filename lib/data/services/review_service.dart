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
      return null;
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
      debugPrint("Error fetching product reviews: $e");
      return [];
    }
  }

  // --- 3. Fetch Admin Analytics (Admin Dashboard) ---
  Future<void> fetchReviewAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch a larger chunk to calculate accurate overall average rating
      final pageData = await _repo.getAllReviews(page: 0, size: 50);

      _totalReviewsCount = pageData.totalElements ?? pageData.content?.length ?? 0;

      // Dynamically calculate average rating from fetched elements
      final reviews = pageData.content ?? [];
      double totalStars = 0.0;
      int ratingCount = 0;

      for (var review in reviews) {
        if (review.serviceReview != null && review.serviceReview!.rating != null) {
          totalStars += review.serviceReview!.rating!;
          ratingCount++;
        }
        if (review.productReviews != null && review.productReviews!.isNotEmpty) {
          for (var pr in review.productReviews!) {
            if (pr.rating != null) {
              totalStars += pr.rating!;
              ratingCount++;
            }
          }
        }
      }

      _averageRating = ratingCount > 0 ? (totalStars / ratingCount) : 0.0;

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

      _totalReviewsCount = pageData.totalElements ?? _adminReviews.length;

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