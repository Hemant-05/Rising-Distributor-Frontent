import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/review_service.dart';
import 'package:raising_india/models/dto/admin_order_review_dto.dart';

// TODO: Ensure you import your actual AdminReviewsScreen path here
// import 'package:raising_india/features/admin/reviews/screens/admin_reviews_screen.dart';

class ReviewAnalyticsWidget extends StatefulWidget {
  const ReviewAnalyticsWidget({super.key});

  @override
  State<ReviewAnalyticsWidget> createState() => _ReviewAnalyticsWidgetState();
}

class _ReviewAnalyticsWidgetState extends State<ReviewAnalyticsWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data when the widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<ReviewService>();
      service.loadAdminReviews(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewService>(
      builder: (context, reviewService, _) {
        // Show Shimmer if loading and no data is present yet
        if (reviewService.isLoading && reviewService.adminReviews.isEmpty) {
          return _buildShimmer();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header & Refresh ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Review Analytics',
                        style: simple_text_style(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      // Refresh both stats and the list
                      reviewService.loadAdminReviews(page: 0);
                    },
                    child: reviewService.isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.refresh_rounded, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Stats Row ---
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStat(
                      'Total Reviews',
                      reviewService.totalReviews.toString(),
                      Icons.rate_review,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStat(
                      'Avg Rating',
                      reviewService.avgRating.toStringAsFixed(1),
                      Icons.star_rounded,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Recent Reviews Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Reviews',
                    style: simple_text_style(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Redirect to full screen
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const AdminReviewsScreen(),
                      //   ),
                      // );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View All',
                      style: simple_text_style(
                        color: AppColour.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- Recent Reviews List (Max 5) ---
              _buildRecentReviewsList(reviewService.adminReviews),
            ],
          ),
        );
      },
    );
  }

  // --- Helper: Build Stats Card ---
  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: simple_text_style(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: simple_text_style(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper: Build Recent Reviews List ---
  Widget _buildRecentReviewsList(List<AdminOrderReviewDto> reviews) {
    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No reviews found yet.',
            style: simple_text_style(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    // Take max 5 items
    final recentReviews = reviews.take(5).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentReviews.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        final reviewDto = recentReviews[index];

        // Safely extract data prioritizing Service Review, then Product Review
        // Note: Change '.rating' and '.comment' if your exact Model fields differ
        final isService = reviewDto.serviceReview != null;
        final hasProduct = reviewDto.productReviews != null && reviewDto.productReviews!.isNotEmpty;

        String typeLabel = "Unknown";
        double rating = 0.0;
        String comment = "No comment";

        if (isService) {
          typeLabel = "Service";
          rating = (reviewDto.serviceReview?.rating ?? 0).toDouble(); // Change field if needed
          comment = reviewDto.serviceReview?.reviewText ?? "No comment"; // Change field if needed
        } else if (hasProduct) {
          typeLabel = "Product";
          rating = (reviewDto.productReviews!.first.rating ?? 0).toDouble(); // Change field if needed
          comment = reviewDto.productReviews!.first.reviewText ?? "No comment"; // Change field if needed
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon based on type
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isService ? Icons.delivery_dining : Icons.shopping_bag,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$typeLabel Review',
                          style: simple_text_style(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: simple_text_style(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: simple_text_style(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper: Shimmer Skeleton ---
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 150, height: 24, color: Colors.white),
                Container(width: 24, height: 24, color: Colors.white),
              ],
            ),
            const SizedBox(height: 16),
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Reviews Header
            Container(width: 120, height: 20, color: Colors.white),
            const SizedBox(height: 16),
            // List Items Shimmer
            for (int i = 0; i < 3; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: double.infinity, height: 14, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 150, height: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ]
          ],
        ),
      ),
    );
  }
}