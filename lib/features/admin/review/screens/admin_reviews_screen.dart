import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/data/services/review_service.dart';
import 'package:raising_india/models/dto/admin_order_review_dto.dart';
import 'package:raising_india/models/model/product_review.dart';
import 'package:raising_india/models/model/service_review.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen>
    with TickerProviderStateMixin {

  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _filterOptions = ['all', 'high_rating', 'low_rating', 'recent'];
  final List<String> _filterLabels = ['All Reviews', 'High Ratings (4+)', 'Low Ratings (≤2)', 'Recent (7 days)'];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // FIX: Wait for the widget to finish building before notifying listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewService>().loadAdminReviews();
      context.read<ReviewService>().fetchReviewAnalytics(); // Sync total counts
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Consumer<ReviewService>(
        builder: (context, reviewService, _) {
          if (reviewService.isLoading && reviewService.adminReviews.isEmpty) {
            return _buildLoadingState();
          } else if (reviewService.error == null) {
            return _buildLoadedState(reviewService.adminReviews);
          } else if (reviewService.error != null) {
            return _buildErrorState(reviewService.error!);
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: AppColour.white,
      title: Row(
        children: [
          back_button(),
          const SizedBox(width: 8),
          Text('Reviews', style: simple_text_style(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColour.primary),
          const SizedBox(height: 16),
          Text(
            'Loading reviews...',
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: simple_text_style(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ReviewService>().loadAdminReviews();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColour.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(List<AdminOrderReviewDto> list) {
    return RefreshIndicator(
      color: AppColour.primary,
      backgroundColor: AppColour.white,
      onRefresh: () async {
        await context.read<ReviewService>().loadAdminReviews();
        await context.read<ReviewService>().fetchReviewAnalytics();
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildStatsHeader(list),
            _buildSearchAndFilterSection(list),
            Expanded(child: _buildReviewsList(list)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(List<AdminOrderReviewDto> list) {
    // FIX: Dynamically calculate accurate rating averages instead of printing list length!
    double sTotal = 0; int sCount = 0;
    double pTotal = 0; int pCount = 0;

    for (var r in list) {
      if (r.serviceReview != null && r.serviceReview!.rating != null) {
        sTotal += r.serviceReview!.rating!;
        sCount++;
      }
      if (r.productReviews != null) {
        for (var pr in r.productReviews!) {
          if (pr.rating != null) {
            pTotal += pr.rating!;
            pCount++;
          }
        }
      }
    }

    double sAvg = sCount > 0 ? (sTotal / sCount) : 0.0;
    double pAvg = pCount > 0 ? (pTotal / pCount) : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColour.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem('Total Reviews', list.length.toString(), Icons.rate_review),
            ),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
            Expanded(
              child: _buildStatItem('Service Rating', sAvg.toStringAsFixed(1), Icons.room_service),
            ),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
            Expanded(
              child: _buildStatItem('Product Rating', pAvg.toStringAsFixed(1), Icons.shopping_basket),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: simple_text_style(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: simple_text_style(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(List<AdminOrderReviewDto> list) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<ReviewService>().loadAdminReviews(page: 0, keyword: value);
              },
              decoration: InputDecoration(
                hintText: 'Search reviews, users, or order IDs...',
                prefixIcon: Icon(Icons.search, color: AppColour.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: simple_text_style(fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildReviewsList(List<AdminOrderReviewDto> reviews) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _buildReviewCard(review, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No reviews found',
            style: simple_text_style(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reviews will appear here when customers submit them',
            style: simple_text_style(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(AdminOrderReviewDto review, int index) {
    // Safely extract the first product review if it exists
    ProductReview? productReview = (review.productReviews != null && review.productReviews!.isNotEmpty)
        ? review.productReviews!.first
        : null;
    ServiceReview? serviceReview = review.serviceReview;

    String userName = productReview?.userName ?? serviceReview?.userId ?? 'Unknown User';
    DateTime? date = productReview?.createdAt ?? serviceReview?.createdAt ?? DateTime.now();

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColour.primary.withOpacity(0.1), AppColour.primary.withOpacity(0.05)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColour.primary,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: simple_text_style(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userName.substring(0,8), style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('d/M/yy, hh:mm a').format(date),
                                      style: simple_text_style(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                if (serviceReview != null)
                                  Expanded(child: _buildRatingSection('Service', serviceReview.rating ?? 0, Icons.room_service, Colors.blue)),
                                if (serviceReview != null && productReview != null)
                                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                                if (productReview != null)
                                  Expanded(child: _buildRatingSection('Product', productReview.rating ?? 0, Icons.shopping_basket, Colors.green)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (serviceReview != null && (serviceReview.reviewText?.isNotEmpty ?? false)) ...[
                        _buildReviewSection('Service Review', serviceReview.reviewText!, Icons.room_service, Colors.blue),
                        const SizedBox(height: 16),
                      ],
                      if (productReview != null && (productReview.reviewText?.isNotEmpty ?? false)) ...[
                        _buildReviewSection('Product Review', productReview.reviewText!, Icons.shopping_basket, Colors.green),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingSection(String title, double rating, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(rating.toStringAsFixed(1), style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: Colors.amber, size: 16),
          ],
        ),
        Text(title, style: simple_text_style(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  Widget _buildReviewSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title, style: simple_text_style(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(content, style: TextStyle(fontSize: 14, color: Colors.grey.shade800)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}