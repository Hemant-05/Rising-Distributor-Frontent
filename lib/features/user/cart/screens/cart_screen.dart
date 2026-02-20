import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/cart_service.dart';
import 'package:raising_india/features/user/address/screens/select_address_screen.dart';
import 'package:raising_india/features/user/payment/screens/payment_checkout_screen.dart';
import 'package:raising_india/models/model/address.dart';
import 'package:raising_india/models/model/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // 1. Fetch Cart on Init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartService>().fetchCart();
    });
  }

  // Helper to calculate totals
  double _calculateTotal(var items) {
    double total = 0;
    for (var item in items) {
      // Assuming item.product.price is available
      total += (item.product!.price! * item.quantity!);
    }
    return total;
  }

  // Helper to calculate MRP totals (for savings)
  double _calculateMRPTotal(var items) {
    double total = 0;
    for (var item in items) {
      // Logic from your old code: Use MRP if available, else Price + 5
      double mrp = item.product!.mrp ?? (item.product!.price! + 5);
      total += (mrp * item.quantity!);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // 2. Consume the Service
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        List<CartItem> cartItems = cartService.cartItems;

        // Calculations
        double total = _calculateTotal(cartItems);
        double mrpTotal = _calculateMRPTotal(cartItems);
        double save = mrpTotal - total;

        return Scaffold(
          backgroundColor: AppColour.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Text(
                  'Cart',
                  style: simple_text_style(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColour.black,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      if (cartItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cart is already Empty')),
                        );
                        return;
                      }
                      // 3. Clear Cart Action
                      context.read<CartService>().clearCart();
                    },
                    child: Text(
                      'CLEAR CART',
                      style: simple_text_style(
                        color: AppColour.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColour.white,
          ),
          body: Center(
            child: cartService.isLoading
                ? CircularProgressIndicator(color: AppColour.primary)
                : Column(
              children: [
                Expanded(
                  flex: 4,
                  child: cartItems.isEmpty
                      ? Center(
                    child: Text(
                      'Your cart is empty',
                      style: simple_text_style(fontSize: 24),
                    ),
                  )
                      : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = item.product!; // Assuming populated

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColour.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColour.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product.photosList?.first ?? "", // Handle list
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, error, stackTrace) =>
                                  const Icon(Icons.error_outline_rounded),
                                ),
                              ),
                              title: Text(
                                product.name ?? "Product",
                                style: simple_text_style(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    '₹${product.price}',
                                    style: simple_text_style(fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${product.mrp ?? (product.price! + 5)}',
                                    style: const TextStyle(
                                      fontFamily: 'Sen',
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Remove Button (-)
                                  _buildQtyBtn(
                                    icon: Icons.remove,
                                    onTap: () {
                                      if (item.quantity! > 1) {
                                        context.read<CartService>().updateQuantity(
                                          product.pid!,
                                          item.quantity! - 1,
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${item.quantity}',
                                    style: simple_text_style(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Add Button (+)
                                  _buildQtyBtn(
                                    icon: Icons.add,
                                    onTap: () {
                                      context.read<CartService>().updateQuantity(
                                        product.pid!,
                                        item.quantity! + 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            InkWell(
                              onTap: () {
                                // 4. Remove Item Action
                                context.read<CartService>().removeFromCart(product.pid!);
                              },
                              child: Text(
                                'Remove from cart',
                                style: simple_text_style(
                                  color: AppColour.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Bottom Summary Section
                Visibility(
                  visible: cartItems.isNotEmpty,
                  child: Container(
                    height: 120, // Increased slightly for spacing
                    decoration: BoxDecoration(
                      color: AppColour.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColour.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Free Delivery Above ₹99',
                          style: simple_text_style(
                            fontSize: 14,
                            color: total > 99 ? AppColour.green : AppColour.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cart Total', style: simple_text_style(fontSize: 20)),
                                Row(
                                  children: [
                                    Text(
                                      '₹${total.toStringAsFixed(0)}',
                                      style: simple_text_style(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₹${mrpTotal.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontFamily: 'Sen',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                if (save > 0)
                                  Text(
                                    'You Save: ₹${save.toStringAsFixed(0)}',
                                    style: simple_text_style(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColour.green,
                                    ),
                                  ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                // 5. Checkout Logic
                                if (cartItems.isNotEmpty) {
                                  final result = await PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: SelectAddressScreen(isFromProfile: false),
                                    withNavBar: false,
                                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                  );

                                  if (result != null) {
                                    final user = context.read<AuthService>().customer;

                                    if(user == null) return;

                                    Address resAdd = result['address'];

                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: PaymentCheckoutScreen(
                                        address: resAdd,
                                        total: total.toString(),
                                        mrpTotal: mrpTotal.toString(),
                                        email: user.email!,
                                        cartProductList: cartItems, // Pass list
                                        isVerified: user.isMobileVerified ?? false,
                                      ),
                                      withNavBar: false,
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                  }
                                }
                              },
                              style: elevated_button_style(width: 120),
                              child: Text(
                                'CONTINUE',
                                style: simple_text_style(
                                  color: AppColour.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQtyBtn({required IconData icon, required VoidCallback onTap}) {
    return Container(
      height: 26,
      width: 26,
      decoration: BoxDecoration(
        color: AppColour.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, color: AppColour.white, size: 18),
      ),
    );
  }
}