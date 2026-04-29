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

class _AdminReviewsScreenState extends State<AdminReviewsScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewService>().loadAdminReviews();
      context.read<ReviewService>().fetchReviewAnalytics();
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
          Text('Customer Reviews', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() => Center(child: CircularProgressIndicator(color: AppColour.primary));

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No reviews yet', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(message, style: simple_text_style(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColour.primary),
            onPressed: () => context.read<ReviewService>().loadAdminReviews(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(List<OrderReviewDto> list) {
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
            _buildSearchSection(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) => _buildOrderReviewCard(list[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header Stats ---
  Widget _buildStatsHeader(List<OrderReviewDto> list) {
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
        gradient: LinearGradient(colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColour.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Total\nReviews', list.length.toString(), Icons.rate_review),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem('Service\nRating', sAvg.toStringAsFixed(1), Icons.delivery_dining),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem('Product\nRating', pAvg.toStringAsFixed(1), Icons.shopping_bag),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(value, style: simple_text_style(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title, style: simple_text_style(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }

  // --- Search ---
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => context.read<ReviewService>().loadAdminReviews(page: 0, keyword: val),
        decoration: InputDecoration(
          hintText: 'Search reviews or order IDs...',
          hintStyle: simple_text_style(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: AppColour.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
    );
  }

  // ===========================================================================
  // 🚀 UPGRADED REVIEW CARD (Handles Multiple Products!)
  // ===========================================================================
  Widget _buildOrderReviewCard(OrderReviewDto reviewData) {
    ServiceReview? serviceReview = reviewData.serviceReview;
    List<ProductReview> productReviews = reviewData.productReviews ?? [];

    // ✅ Safely extract username based on your exact models
    String userName = 'Unknown User';
    if (productReviews.isNotEmpty && productReviews.first.userName != null) {
      userName = productReviews.first.userName!;
    } else if (serviceReview?.userId != null) {
      userName = 'User ID: ${serviceReview!.userId}'; // Fallback to ID
    }

    String orderId = serviceReview?.orderId?.toString() ?? 'N/A';
    DateTime? reviewDate = serviceReview?.createdAt ?? (productReviews.isNotEmpty ? productReviews.first.createdAt : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Order Header ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: AppColour.primary.withOpacity(0.1), radius: 20, child: Text(userName[0].toUpperCase(), style: simple_text_style(color: AppColour.primary, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Order #$orderId', style: simple_text_style(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                if (reviewDate != null)
                  Text(DateFormat('MMM d, yyyy').format(reviewDate), style: simple_text_style(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),

          // --- 2. Service Review Section ---
          if (serviceReview != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text("Delivery & Service", style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue.shade800)),
                      const Spacer(),
                      _buildStarRating(serviceReview.rating ?? 0.0),
                    ],
                  ),
                  if (serviceReview.reviewText != null && serviceReview.reviewText!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text('"${serviceReview.reviewText}"', style: simple_text_style(fontSize: 14, color: Colors.blue.shade900)),
                    ),
                  ]
                ],
              ),
            ),
            if (productReviews.isNotEmpty) const Divider(height: 1, color: Colors.black12),
          ],

          // --- 3. Individual Product Reviews List ---
          if (productReviews.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Product Reviews (${productReviews.length})", style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700)),
                  const SizedBox(height: 12),

                  // Generates a separate block for EVERY product reviewed in this order
                  ...productReviews.map((pr) => _buildSingleProductReview(pr)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleProductReview(ProductReview pr) {
    // ✅ Use productId since the full product object isn't in the model
    String productName = "Product ID: ${pr.productId ?? 'Unknown'}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Fallback Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50, height: 50, color: Colors.grey.shade100,
                  child: const Icon(Icons.shopping_bag, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              // Name & Stars
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName, style: simple_text_style(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    _buildStarRating(pr.rating ?? 0.0),
                  ],
                ),
              ),
            ],
          ),
          // Product Comment
          if (pr.reviewText != null && pr.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text('"${pr.reviewText}"', style: simple_text_style(fontSize: 13, color: Colors.grey.shade800)),
            ),
          ]
        ],
      ),
    );
  }

  // --- Helper: Render 5 Stars ---
  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}