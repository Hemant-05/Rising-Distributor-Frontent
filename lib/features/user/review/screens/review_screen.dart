import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

// Services
import 'package:raising_india/data/services/review_service.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/data/services/auth_service.dart';

// Models
import 'package:raising_india/models/model/order.dart';
import 'package:raising_india/models/dto/review_request_dto.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;

  const ReviewScreen({super.key, required this.orderId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Order? _order;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // ✅ NEW: Flag to track if we are just viewing an old review
  bool _hasExistingReview = false;

  // --- State for Service Review ---
  double _serviceRating = 0.0;
  final TextEditingController _serviceCommentController = TextEditingController();

  // --- State for Individual Product Reviews ---
  final Map<String, double> _productRatings = {};
  final Map<String, TextEditingController> _productComments = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();

    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    final orderService = context.read<OrderService>();
    final reviewService = context.read<ReviewService>();

    try {
      // 1. Find the Order Details
      final foundOrder = orderService.orders.firstWhere((o) => o.id.toString() == widget.orderId);

      if (foundOrder.orderItems != null) {
        for (var item in foundOrder.orderItems!) {
          if (item.product != null && item.product!.pid != null) {
            _productRatings[item.product!.pid!] = 0.0;
            _productComments[item.product!.pid!] = TextEditingController();
          }
        }
      }

      // 2. ✅ Check if the user already submitted a review for this order
      try {
        final existingReview = await reviewService.getReviewByOrder(foundOrder.id!);

        // If the backend returns data, populate our state and lock the screen!
        if (existingReview != null) {
          _hasExistingReview = true;

          // Populate Service Review
          if (existingReview.serviceReview != null) {
            _serviceRating = existingReview.serviceReview!.rating ?? 0.0;
            _serviceCommentController.text = existingReview.serviceReview!.reviewText ?? '';
          }

          // Populate Product Reviews
          if (existingReview.productReviews != null) {
            for (var pr in existingReview.productReviews!) {
              // Ensure we map the DTO ID back to our String PID
              // (Adjust 'pr.productId' or 'pr.product?.pid' based on your exact DTO structure)
              String pid = pr.productId?.toString() ?? '';

              if (_productRatings.containsKey(pid)) {
                _productRatings[pid] = pr.rating ?? 0.0;
                _productComments[pid]!.text = pr.reviewText ?? '';
              }
            }
          }
        }
      } catch (e) {
        // Backend threw an error (likely a 404 Not Found).
        // This is perfectly fine! It just means they haven't reviewed it yet.
        debugPrint("No existing review found for this order.");
      }

      setState(() {
        _order = foundOrder;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _serviceCommentController.dispose();
    for (var controller in _productComments.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_order == null || _hasExistingReview) return;

    if (_serviceRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please provide a service rating"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSubmitting = true);

    final user = context.read<AuthService>().customer;
    final reviewService = context.read<ReviewService>();

    List<ProductRatingDto> productReviewsToSubmit = [];
    _productRatings.forEach((pid, rating) {
      if (rating > 0.0) {
        productReviewsToSubmit.add(
          ProductRatingDto(
            productId: pid, // Make sure your DTO accepts String!
            rating: rating,
            reviewText: _productComments[pid]?.text.trim(),
          ),
        );
      }
    });

    final request = ReviewRequestDto(
      userId: user?.uid,
      userName: user?.name,
      orderId: _order!.id,
      serviceRating: _serviceRating,
      serviceReview: _serviceCommentController.text.trim(),
      products: productReviewsToSubmit,
    );

    final error = await reviewService.submitReview(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review Submitted Successfully!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColour.primary,)));
    if (_order == null) return const Scaffold(body: Center(child: Text("Order not found")));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            // ✅ Change Title dynamically
            Text(_hasExistingReview ? 'Your Review' : 'Rate Order', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Show a badge if it's already reviewed
              if (_hasExistingReview)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text("Already reviewed this order.",style: simple_text_style(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

              _buildServiceReviewSection(),
              const SizedBox(height: 24),
              if (_order!.orderItems != null && _order!.orderItems!.isNotEmpty) ...[
                Text("Item Reviews", style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                const SizedBox(height: 12),
                _buildProductReviewsList(),
              ],
              const SizedBox(height: 30),

              // ✅ Only show the Submit button if they HAVEN'T reviewed it yet
              if (!_hasExistingReview) _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildServiceReviewSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColour.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.delivery_dining, color: AppColour.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery & Service', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('How was your overall experience?', style: simple_text_style(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _serviceRating ? Icons.star : Icons.star_border,
                  size: 40,
                  color: index < _serviceRating ? Colors.amber : Colors.grey.shade300,
                ),
                // ✅ Disable tapping if already reviewed
                onPressed: _hasExistingReview ? null : () => setState(() => _serviceRating = index + 1.0),
              );
            }),
          ),
          const SizedBox(height: 16),

          // ✅ Show text field if they are writing a review, OR if they already wrote one and left a comment.
          if (!_hasExistingReview || (_hasExistingReview && _serviceCommentController.text.isNotEmpty))
            TextField(
              controller: _serviceCommentController,
              maxLines: 3,
              readOnly: _hasExistingReview, // ✅ Lock editing
              decoration: InputDecoration(
                hintText: 'Write a review for our service (Optional)',
                hintStyle: simple_text_style(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColour.primary)),
                filled: true,
                fillColor: _hasExistingReview ? Colors.transparent : Colors.grey.shade50,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductReviewsList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _order!.orderItems!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _order!.orderItems![index];
        final product = item.product;
        if (product == null || product.pid == null) return const SizedBox.shrink();

        final pid = product.pid!;
        final currentRating = _productRatings[pid] ?? 0.0;

        // ✅ If it's a past review and they didn't rate this specific item, skip it to keep the UI clean
        if (_hasExistingReview && currentRating == 0.0) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60, height: 60, color: Colors.grey.shade100,
                      child: product.photosList != null && product.photosList!.isNotEmpty
                          ? Image.network(product.photosList!.first, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => const Icon(Icons.image_not_supported, color: Colors.grey))
                          : const Icon(Icons.shopping_bag, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name ?? 'Product', style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return GestureDetector(
                              // ✅ Disable tapping if already reviewed
                              onTap: _hasExistingReview ? null : () => setState(() => _productRatings[pid] = starIndex + 1.0),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  starIndex < currentRating ? Icons.star : Icons.star_border,
                                  size: 28,
                                  color: starIndex < currentRating ? Colors.amber : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (currentRating > 0.0) ...[
                const SizedBox(height: 16),
                if (!_hasExistingReview || (_hasExistingReview && _productComments[pid]!.text.isNotEmpty))
                  TextField(
                    controller: _productComments[pid],
                    maxLines: 2,
                    readOnly: _hasExistingReview, // ✅ Lock editing
                    decoration: InputDecoration(
                      hintText: 'What did you like or dislike?',
                      hintStyle: simple_text_style(color: Colors.grey.shade400, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColour.primary)),
                      filled: _hasExistingReview ? false : true,
                    ),
                  ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColour.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColour.primary.withOpacity(0.4),
        ),
        child: _isSubmitting
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('Submit Review', style: simple_text_style(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}