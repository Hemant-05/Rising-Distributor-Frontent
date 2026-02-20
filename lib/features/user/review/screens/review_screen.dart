import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

// Services
import 'package:raising_india/data/services/review_service.dart';
import 'package:raising_india/data/services/order_service.dart'; // To fetch order details
import 'package:raising_india/data/services/auth_service.dart';

// Models
import 'package:raising_india/models/model/order.dart'; // New Order Model
import 'package:raising_india/models/dto/review_request_dto.dart'; // For submission

class ReviewScreen extends StatefulWidget {
  final String orderId;

  const ReviewScreen({super.key, required this.orderId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0; // Default 5 stars

  Order? _order; // To store fetched order details
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    // Note: Ideally, OrderService should have getOrderById. 
    // If not, you might need to find it in the existing list.
    // Assuming orderService.orders has the list already loaded
    final orderService = context.read<OrderService>();

    // Simple check in local list first
    try {
      final foundOrder = orderService.orders.firstWhere(
              (o) => o.id.toString() == widget.orderId
      );
      setState(() {
        _order = foundOrder;
        _isLoading = false;
      });
    } catch (e) {
      // If not found locally, you might need a fetchSingleOrder API call
      setState(() {
        _isLoading = false;
        // Handle error state or fetch from API
      });
    }
  }

  Future<void> _submitReview() async {
    if (_order == null) return;

    setState(() => _isSubmitting = true);

    final user = context.read<AuthService>().customer;
    final reviewService = context.read<ReviewService>();

    // Construct Review DTO
    // Note: This logic assumes you submit ONE review for the whole order, 
    // OR loops through items. Adapting to your UI which seems to be one general review.

    // If your backend expects product-specific reviews, you'd need a loop.
    // Here is a single review submission example based on your UI flow.

    final itemIds = _order!.orderItems?.map((i) => i.product?.pid ?? "0").toList() ?? [];

    // Assuming backend takes first product or handles order-level review
    if (itemIds.isEmpty) return;

    final request = ReviewRequestDto(
      userId: user?.uid,
      userName: user?.name,
      orderId: _order!.id,
      serviceRating: _rating,
      serviceReview: _commentController.text,
      products: [
        ProductRatingDto(
          productId: int.tryParse(itemIds.first),
          rating: _rating,
          reviewText: _commentController.text,
        ),
      ],
    );

    final error = await reviewService.submitReview(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review Submitted!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_order == null) {
      return const Scaffold(body: Center(child: Text("Order not found")));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Review Order', style: simple_text_style(fontSize: 20)),
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
              _buildOrderSummaryCard(_order!),
              const SizedBox(height: 20),
              _buildRatingSection(),
              const SizedBox(height: 20),
              _buildCommentSection(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildOrderSummaryCard(Order order) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColour.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id}', style: simple_text_style(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Delivered Successfully', style: simple_text_style(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${order.orderItems?.length ?? 0} Items',
            style: simple_text_style(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Rate Your Experience', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  size: 40,
                  color: index < _rating ? Colors.amber : Colors.grey.shade400,
                ),
                onPressed: () => setState(() => _rating = index + 1.0),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _commentController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Share your feedback (optional)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
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
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          'Submit Review',
          style: simple_text_style(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}