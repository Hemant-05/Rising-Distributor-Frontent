import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/helper_functions.dart';
import 'package:raising_india/models/model/address.dart';
import 'package:raising_india/models/model/cart.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// UI Components
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';

// Screens
import 'package:raising_india/features/user/coupon/screens/coupons_screen.dart';
import 'package:raising_india/features/user/payment/screens/order_placed_screen.dart';
import 'package:raising_india/features/user/payment/screens/payment_result_screen.dart';

// Services
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/cart_service.dart';
import 'package:raising_india/data/services/coupon_service.dart';
import 'package:raising_india/data/services/order_service.dart';

// Models
import 'package:raising_india/models/model/cart_item.dart';
import 'package:raising_india/models/model/order.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({
    super.key,
    required this.address,
    required this.total,
    required this.mrpTotal,
    required this.email,
    required this.cartProductList,
    required this.isVerified,
  });

  final Address address;
  final String total;
  final String mrpTotal;
  final String email;
  final List<CartItem> cartProductList;
  final bool isVerified;

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> with TickerProviderStateMixin {
  late Razorpay _razorpay;
  bool isCOD = true;
  bool _isProcessingOrder = false;
  int? _pendingDatabaseOrderId;

  // Coupon State
  final TextEditingController _couponController = TextEditingController();
  double _discountAmount = 0.0;
  bool _isCouponApplied = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Getters for totals
  double get _originalTotal => double.tryParse(widget.total) ?? 0.0;

  double get _deliveryCharge {
    double totalAfterDiscount = _originalTotal - _discountAmount;
    return totalAfterDiscount >= 199 ? 0.0 : deliveryFee;
  }

  double get _finalTotal {
    double base = _originalTotal;
    base -= _discountAmount;
    base += platformFee;
    base += _deliveryCharge;
    return base < 0 ? 0 : base;
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- 1. PLACE ORDER (LOCK STOCK) ---
  Future<void> _placeOrder({required bool isCod}) async {
    setState(() => _isProcessingOrder = true);

    final orderService = context.read<OrderService>();
    final cartService = context.read<CartService>();

    try {
      final result = await orderService.placeOrder(
        addressId: widget.address.id!,
        paymentMethod: isCod ? PayMethodCOD : PayMethodOnline,
      );

      // Check if result is an error String
      if (result is String) {
        setState(() => _isProcessingOrder = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red));
        return;
      }

      // Success! Result should be an Order object
      if (result is Order) {
        await cartService.clearCart();
        _pendingDatabaseOrderId = result.id; // Save DB ID

        if (isCod) {
          setState(() => _isProcessingOrder = false);
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderPlacedScreen()));
          }
        } else {
          // Open Razorpay with the generated Order ID
          final String razorpayOrderId = result.razorpayOrderId ?? "";
          if (razorpayOrderId.isEmpty) throw Exception("Razorpay Order ID missing from backend");
          _openCheckOut(razorpayOrderId);
        }
      }
    } catch (e) {
      setState(() => _isProcessingOrder = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  // --- 2. OPEN RAZORPAY ---
  void _openCheckOut(String razorpayOrderId) {
    final razorpayKeyId = dotenv.env['RAZORPAY_KEY_ID'] ?? "";
    String amount = (_finalTotal * 100).toInt().toString();

    var options = {
      'key': razorpayKeyId,
      'amount': amount,
      'name': 'Raising India',
      'description': 'Order Payment',
      'order_id': razorpayOrderId,
      'prefill': {'contact': widget.address.phoneNumber, 'email': widget.email},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessingOrder = false);
      debugPrint('Razorpay Error: $e');
    }
  }

  // --- 3. CONFIRM PAYMENT ---
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_pendingDatabaseOrderId == null) return;
    final orderService = context.read<OrderService>();

    try {
      await orderService.confirmPayment(
        orderId: _pendingDatabaseOrderId!,
        transactionId: response.paymentId ?? "", // Passed correctly now
        payId: response.paymentId ?? "",
        signature: response.signature ?? "",
      );

      setState(() => _isProcessingOrder = false);

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PaymentResultScreen(isSuccess: true, transactionId: response.paymentId ?? "NA")));
      }
    } catch (e) {
      setState(() => _isProcessingOrder = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment verification failed."), backgroundColor: Colors.red));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingOrder = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed: ${response.message}")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  // --- COUPON LOGIC ---
  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a code")));
      return;
    }

    final userId = context.read<AuthService>().currentUid;
    if (userId == null) return;

    final result = await context.read<CouponService>().applyCoupon(userId, code);

    if (result is String) {
      if(!_isCouponApplied) {
        _couponController.clear();
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red));
    } else {
      Cart cart = Cart.fromJson(result);
      setState(() {
        _isCouponApplied = true;
        _discountAmount = (cart.discountAmount ?? 0.0).toDouble();
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coupon Applied!"), backgroundColor: Colors.green));
    }
  }

  void removeCoupon() async {
    final userId = context.read<AuthService>().currentUid;
    if (userId == null) return;
    await context.read<CouponService>().removeCoupon(userId);
    setState(() {
      _couponController.clear();
      _isCouponApplied = false;
      _discountAmount = 0.0;
    });
  }

  void _navigateToMyCoupons() async {
    final selectedCode = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CouponsScreen(isSelectionMode: true)));
    if (selectedCode != null && selectedCode is String) {
      _couponController.text = selectedCode;
      _applyCoupon();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _isCouponApplied) {
          removeCoupon();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: AppColour.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Row(
            children: [
              Container(
                height: 40, width: 40,
                decoration: BoxDecoration(color: AppColour.lightGrey.withOpacity(0.25), borderRadius: BorderRadius.circular(50)),
                child: InkWell(
                  onTap: () {
                    if (_isCouponApplied) removeCoupon();
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColour.black),
                ),
              ),
              const SizedBox(width: 10),
              Text("Checkout", style: simple_text_style(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAddressSection(),
                const SizedBox(height: 20),
                _buildOrderSummarySection(),
                const SizedBox(height: 20),
                _buildApplyCouponSection(),
                const SizedBox(height: 20),
                _buildPaymentMethodSection(),
                const SizedBox(height: 30),
                _buildPriceDetailsSection(),
                const SizedBox(height: 20),
                _buildPlaceOrderButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI WIDGETS ---
  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)]), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.white),
                const SizedBox(width: 12),
                Text('Delivery Address', style: simple_text_style(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.home_outlined, color: AppColour.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(formatFullAddress(widget.address), style: simple_text_style(fontSize: 14, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)]), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                const SizedBox(width: 12),
                Text('Order Summary', style: simple_text_style(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${widget.cartProductList.length} items', style: simple_text_style(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: widget.cartProductList.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8), color: Colors.grey[200],
                          image: (item.product?.photosList?.isNotEmpty ?? false) ? DecorationImage(image: NetworkImage(item.product!.photosList!.first), fit: BoxFit.cover) : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product?.name ?? "Product", style: simple_text_style(fontWeight: FontWeight.bold)),
                            Text("Qty: ${item.quantity}", style: simple_text_style(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text("₹${((item.product?.price ?? 0) * (item.quantity ?? 1)).toStringAsFixed(0)}", style: simple_text_style(fontWeight: FontWeight.bold, color: AppColour.primary)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyCouponSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))]),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, color: AppColour.primary),
              const SizedBox(width: 12),
              Text('Apply Coupon', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isCouponApplied) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _couponController,
                decoration: InputDecoration(
                  hintText: 'Enter Code', border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: IconButton(icon: Icon(Icons.arrow_forward, color: AppColour.primary), onPressed: _applyCoupon),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _navigateToMyCoupons, child: Text("See All Coupons", style: simple_text_style(color: AppColour.primary, fontWeight: FontWeight.bold))),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Coupon Applied! -₹$_discountAmount", style: simple_text_style(color: Colors.green.shade800, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: removeCoupon),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))]),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _paymentOption("Cash On Delivery", "cod", Icons.money)),
              const SizedBox(width: 12),
              Expanded(child: _paymentOption("Pay Online", "online", Icons.credit_card)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(String title, String value, IconData icon) {
    bool selected = isCOD ? (value == 'cod') : (value == 'online');
    return GestureDetector(
      onTap: () => setState(() => isCOD = (value == 'cod')),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColour.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(color: selected ? AppColour.primary : Colors.grey.shade300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColour.primary : Colors.grey),
            const SizedBox(height: 8),
            Text(title, style: simple_text_style(color: selected ? AppColour.primary : Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _row("MRP Total", "₹${widget.mrpTotal}", isThroughLine: true),
          _row("Cart Total", "₹$_originalTotal"),
          _row("Delivery Fee", _deliveryCharge == 0 ? "Free" : "₹$_deliveryCharge"),
          _row("Platform Fee", "₹$platformFee"),
          if (_isCouponApplied) _row("Coupon Discount", "-₹${_discountAmount.toStringAsFixed(2)}", color: Colors.green),
          const Divider(height: 2.5,color: Colors.black,),
          _row("Total Amount", "₹${_finalTotal.toStringAsFixed(2)}", isBold: true, size: 18),
          _row("You Save", "₹${(double.parse(widget.mrpTotal) - _finalTotal + platformFee).toStringAsFixed(2)}", isBold: true, color: AppColour.green, size: 18),

        ],
      ),
    );
  }

  Widget _row(String label, String val, {Color? color, bool isBold = false, bool isThroughLine = false, double size = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: simple_text_style(fontSize: size, color: Colors.grey[700]!)),
          Text(val, style: simple_text_style(fontSize: size, isLineThrough: isThroughLine, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black)),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: elevated_button_style(),
        onPressed: !widget.isVerified
            ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verify Account First")))
            : _isProcessingOrder
            ? null
            : () => _placeOrder(isCod: isCOD), // ✅ Always secures stock first, regardless of payment method!
        child: _isProcessingOrder
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(isCOD ? "PLACE ORDER" : "PAY & ORDER", style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}