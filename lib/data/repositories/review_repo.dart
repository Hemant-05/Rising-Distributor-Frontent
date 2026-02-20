import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/dto/review_request_dto.dart';
import 'package:raising_india/models/model/product_review.dart';
import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';
import 'package:raising_india/models/dto/admin_order_review_dto.dart';
import 'package:raising_india/models/dto/page.dart';

class ReviewRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  // --- USER METHODS ---

  Future<void> submitReview(ReviewRequestDto request) async {
    try {
      await _client.submitReview(request);
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<ProductReview>> getProductReviews(int productId) async {
    try {
      final response = await _client.getProductReviews(productId);
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  // --- ADMIN METHODS ---

  Future<AdminOrderReviewDto> getReviewByOrder(int orderId) async {
    try {
      final response = await _client.getReviewByOrder(orderId);
      if (response.data == null) {
        throw Exception("Review details not found for this order.");
      }
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  /// Get All Reviews with pagination and filtering
  Future<Page<AdminOrderReviewDto>> getAllReviews({
    int page = 0,
    int size = 10,
    String? keyword,
    double? rating,
    String sort = "date",
  }) async {
    try {
      final response = await _client.getAllReviews(
        page,
        size,
        keyword,
        rating,
        sort,
      );

      if (response.data == null) {
        // Return an empty page structure if null
        return Page(content: [], totalElements: 0, totalPages: 0);
      }
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }
}