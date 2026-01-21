import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/auth/screens/verification_screen.dart';
import 'package:raising_india/features/user/coupon/bloc/coupon_bloc.dart';
import 'package:raising_india/features/user/coupon/screens/coupons_screen.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import 'package:raising_india/features/user/payment/screens/place_order_screen.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';
import 'package:raising_india/models/address_model.dart';
import 'package:raising_india/models/coupon_model.dart';
import 'package:raising_india/models/order_model.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:raising_india/features/user/payment/screens/payment_result_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({
    super.key,
    required this.address,
    required this.addressCode,
    required this.total,
    required this.mrpTotal,
    required this.name,
    required this.contact,
    required this.email,
    required this.cartProductList,
    required this.isVerified,
  });

  final String address;
  final LatLng addressCode;
  final String total;
  final String mrpTotal;
  final String name;
  final String contact;
  final String email;
  final List<Map<String, dynamic>> cartProductList;
  final bool isVerified;

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen>
    with TickerProviderStateMixin {
  late Razorpay _razorpay;
  // final FirebaseFirestore firestore = FirebaseFirestore.instance; // Removed FirebaseFirestore
  // final FirebaseAuth auth = FirebaseAuth.instance; // Removed FirebaseAuth

  bool isCOD = true;
  bool _isProcessingOrder = false;

  late CouponBloc _couponBloc;

  // Coupon related variables
  final TextEditingController _couponController = TextEditingController();
  CouponModel? _appliedCoupon;
  double _discountAmount = 0.0;
  bool _isCouponApplied = false;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? _userId; // Will be set from your custom authentication

  double get _originalTotal => double.parse(widget.total);
  double get _finalTotal =>
      _originalTotal -
      _discountAmount +
      3 +
      (double.parse(widget.total) < 99 ? deliveryFee : 0);
  // 3, 15 < 99 > free

  @override
  void initState() {
    super.initState();
    // TODO: Get userId from your custom authentication system or UserBloc
    _userId = "dummy_user_id"; // Placeholder

    // Razorpay initialization
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _couponBloc = context.read<CouponBloc>();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _openCheckOut() {
    final razorpayKeyId = dotenv.env['RAZORPAY_KEY_ID'];
    String amount = (_finalTotal * 100).toInt().toString();
    String name = widget.name;
    String contact = widget.contact;
    String email = widget.email;

    var options = {
      'key': razorpayKeyId,
      'amount': amount,
      'name': name,
      'description': 'Shopping From Raising India',
      'prefill': {'contact': contact, 'email': email},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print('=================${e.toString()}');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placeOrder(false, true, response.paymentId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(
          isSuccess: true,
          transactionId: response.paymentId!,
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    placeOrder(false, false, null);

    _removeCoupon();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(
          isSuccess: false,
          transactionId: response.message!,
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print(response.walletName);
  }

  void userNotVerifiedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Your account is not verified. \nPlease verify your account to place the order.',
        ),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationCodeScreen(role: user),
      ),
    );
  }

  void payNowComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This feature is, Coming Soon....',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void placeOrder(
    bool isCod,
    bool isPaymentSuccess,
    String? transactionId,
  ) async {
    setState(() => _isProcessingOrder = true);

    List<Map<String, dynamic>> list = widget.cartProductList.map((map) {
      return {
        'productId': map['productId'],
        'name': (map['product'] as ProductModel).name,
        'image': (map['product'] as ProductModel).photosList[0],
        'quantity': map['quantity'].toString(),
      };
    }).toList();

    final newOrder = OrderModel(
      orderId: Uuid().v4(),
      // TODO: Get userId from your custom authentication system or UserBloc
      userId: _userId!, // Using the placeholder userId
      name: widget.name,
      createdAt: DateTime.now(),
      items: list,
      subtotal: _originalTotal,
      deliveryFee: double.parse(widget.total) < 99 ? deliveryFee : 0,
      transactionId: isPaymentSuccess ? transactionId : 'NA',
      total: _finalTotal,
      paymentMethod: isCod ? PayMethodCOD : PayMethodPrepaid,
      paidAt: isPaymentSuccess ? DateTime.now() : null,
      paymentStatus: isCod
          ? PayStatusPending
          : isPaymentSuccess
              ? PayStatusPaid
              : PayStatusFailed,
      orderStatus: (isPaymentSuccess || isCod)
          ? OrderStatusCreated
          : OrderStatusCancelled,
      cancellationReason: (isPaymentSuccess || isCod) ? null : 'Payment Failed',
      address: AddressModel.fromMap({}), // add full address model
    );

    context.read<OrderBloc>().add(PlaceOrderEvent(model: newOrder));

    if (isPaymentSuccess) {
      context.read<ProductFunBloc>().add(ClearCartPressed());

      // Generate cashback coupon
      // TODO: Get userId from your custom authentication system or UserBloc
      final String userId = _userId!; // Using the placeholder userId
      _couponBloc.add(
        GenerateCashbackCoupon(
          userId: userId,
          orderId: newOrder.orderId,
          orderTotal: newOrder.total,
        ),
      );

      // If coupon was applied, confirm its usage
      if (_appliedCoupon != null && _userId != null) {
        _couponBloc.add(
          ConfirmCouponUsage(
            userId: _userId!,
            couponId: _appliedCoupon!.id,
            orderId: newOrder.orderId,
          ),
        );
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🎉 Order completed! Cashback coupon added to your account.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }

    if (isCod) {
      // If coupon was applied, confirm its usage
      if (_appliedCoupon != null && _userId != null) {
        _couponBloc.add(
          ConfirmCouponUsage(
            userId: _userId!,
            couponId: _appliedCoupon!.id,
            orderId: newOrder.orderId,
          ),
        );
      }
      context.read<ProductFunBloc>().add(ClearCartPressed());
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderPlacedScreen()),
      );
    }

    setState(() => _isProcessingOrder = false);
  }

  void _applyCoupon() {
    if (_couponController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a coupon code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_userId != null) {
      _couponBloc.add(
        ApplyCouponToCheckout(
          userId: _userId!,
          couponCode: _couponController.text.trim().toUpperCase(),
          orderTotal: _originalTotal,
        ),
      );
    }
  }

  void _removeCoupon() {
    if (_appliedCoupon != null && _userId != null) {
      _couponBloc.add(
        CancelCouponApplication(userId: _userId!, couponId: _appliedCoupon!.id),
      );
    }
  }

  void _navigateToMyCoupons() async {
    _couponBloc.add(LoadUserCoupons());
    final selectedCoupon = await Navigator.push<CouponModel>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<CouponBloc>(context),
          child: const CouponsScreen(isSelectionMode: true),
        ),
      ),
    );

    if (selectedCoupon != null) {
      _couponController.text = selectedCoupon.code;
      _applyCoupon();
    }
  }

  void _handleCouponStates(BuildContext context, CouponState state) {
    if (state is CouponAppliedToCheckout) {
      setState(() {
        _appliedCoupon = state.coupon;
        _discountAmount = state.discountAmount;
        _isCouponApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Coupon applied! You saved ₹${state.discountAmount.toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state is CouponError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    } else if (state is CouponApplicationCancelled) {
      setState(() {
        _appliedCoupon = null;
        _discountAmount = 0.0;
        _isCouponApplied = false;
        _couponController.clear();
      });
    }
  }

  @override
  void dispose() {
    // Release coupon reservation if user leaves without completing order
    _removeCoupon();
    _razorpay.clear();
    _couponController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 10),
            Text(
              "Checkout",
              style: simple_text_style(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: BlocListener<CouponBloc, CouponState>(
        listener: _handleCouponStates,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Section
                  _buildAddressSection(),
                  const SizedBox(height: 20),

                  // Order Summary Section
                  _buildOrderSummarySection(),
                  const SizedBox(height: 20),

                  // Apply Coupon Section
                  _buildApplyCouponSection(),
                  const SizedBox(height: 20),

                  // Payment Method Section
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 30),

                  // Price Details Section
                  _buildPriceDetailsSection(),
                  const SizedBox(height: 20),

                  // Place Order Button
                  _buildPlaceOrderButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
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
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Delivery Address',
                  style: simple_text_style(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Address Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: AppColour.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.address,
                          style: simple_text_style(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
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
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: simple_text_style(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.cartProductList.length} items',
                    style: simple_text_style(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: widget.cartProductList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildOrderItem(item),
                    if (index < widget.cartProductList.length - 1)
                      Divider(color: Colors.grey.shade200, height: 24),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    ProductModel product = item['product'];
    int quantity = item['quantity'];

    return Row(
      children: [
        // Product Image
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.photosList[0],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.fastfood, color: Colors.grey.shade400),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: simple_text_style(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${product.quantity.toStringAsFixed(0)} ${product.measurement}',
                style: simple_text_style(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColour.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Qty: $quantity',
                      style: simple_text_style(
                        color: AppColour.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${(product.price * quantity).toStringAsFixed(2)}',
                    style: simple_text_style(
                      color: AppColour.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplyCouponSection() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  color: AppColour.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Apply Coupon',
                  style: simple_text_style(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (!_isCouponApplied) ...[
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(
                            Icons.confirmation_number_outlined,
                            color: AppColour.primary,
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        style: simple_text_style(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<CouponBloc, CouponState>(
                    builder: (context, state) {
                      final isLoading = state is CouponLoading;
                      return SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _applyCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColour.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Apply',
                                  style: simple_text_style(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // View My Coupons Button
              GestureDetector(
                onTap: _navigateToMyCoupons,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColour.primary.withOpacity(0.1),
                        AppColour.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColour.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.card_giftcard, color: AppColour.primary),
                      const SizedBox(width: 12),
                      Text(
                        'View My Coupons',
                        style: simple_text_style(
                          color: AppColour.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColour.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Applied Coupon Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Coupon Applied Successfully!',
                                style: simple_text_style(
                                  color: Colors.green.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Code: ${_appliedCoupon?.code}',
                                style: simple_text_style(
                                  color: Colors.green.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _removeCoupon,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.green.shade700,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount Applied',
                          style: simple_text_style(
                            color: Colors.green.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '- ₹${_discountAmount.toStringAsFixed(2)}',
                          style: simple_text_style(
                            color: Colors.green.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailsSection() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: AppColour.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Price Details',
                  style: simple_text_style(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPriceRow('MRP Total', '₹${widget.mrpTotal}', AppColour.black, true),
            _buildPriceRow('Discounted Price', '₹${widget.total}'),
            _buildPriceRow(
              'Delivery Fee',
              double.parse(widget.total) < 99 ? '₹$deliveryFee' : 'Free',
            ),
            _buildPriceRow('Platform Fee', '₹$platformFee'),

            if (_isCouponApplied)
              _buildPriceRow(
                'Coupon Discount',
                '- ₹${_discountAmount.toStringAsFixed(2)}',
                Colors.green.shade600,
              ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.grey.shade300, thickness: 1),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColour.primary.withOpacity(0.1),
                    AppColour.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: simple_text_style(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${_finalTotal.toStringAsFixed(2)}',
                    style: simple_text_style(
                      color: AppColour.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, [Color? color, bool isCut = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: simple_text_style(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Sen',
              decorationThickness: 2,
              decoration: isCut ? TextDecoration.lineThrough : TextDecoration.none,
              color: color ?? AppColour.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppColour.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Payment Method',
                  style: simple_text_style(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildPaymentOption(
                    'Cash On Delivery',
                    'cod',
                    Icons.money,
                    'Pay when delivered',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPaymentOption(
                    'Pay Now',
                    'online',
                    Icons.credit_card,
                    'Get 5% Cashback',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    String value,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = isCOD ? (value == 'cod') : (value == 'online');

    return GestureDetector(
      onTap: () => setState(() {
        // isCOD = (value == 'cod');
        if(value == 'online'){
          payNowComingSoonSnackBar();
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColour.primary.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColour.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColour.primary : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: simple_text_style(
                color: isSelected ? AppColour.primary : AppColour.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: simple_text_style(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isVerified
              ? [AppColour.primary, AppColour.primary.withOpacity(0.8)]
              : [AppColour.grey, AppColour.grey.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.isVerified
                ? AppColour.primary.withOpacity(0.3)
                : AppColour.grey.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: widget.isVerified
            ? () {
                _isProcessingOrder
                    ? null
                    : isCOD
                        ? placeOrder(true, false, null)
                        : _openCheckOut();
              }
            : userNotVerifiedSnackBar,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isProcessingOrder
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing Order...',
                    style: simple_text_style(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isVerified
                        ? Icons.shopping_cart_checkout
                        : Icons.block,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isVerified
                        ? isCOD
                            ? "PLACE ORDER ₹${_finalTotal.toStringAsFixed(2)}"
                            : "PROCEED & PAY ₹${_finalTotal.toStringAsFixed(2)}"
                        : 'NOT VERIFIED',
                    style: simple_text_style(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
