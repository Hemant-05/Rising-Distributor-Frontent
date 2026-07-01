import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/helper_functions.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/data/services/address_service.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/banner_service.dart';
import 'package:raising_india/data/services/cart_service.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/data/services/wishlist_service.dart';

// Screens & Widgets
import 'package:raising_india/features/user/address/screens/select_address_screen.dart';
import 'package:raising_india/features/user/home/widgets/add_banner_widget.dart';
import 'package:raising_india/features/user/home/widgets/product_grid.dart';
import 'package:raising_india/features/user/home/widgets/search_bar_widget.dart';
import 'package:raising_india/features/user/order/screens/order_tracking_screen.dart';
import 'package:raising_india/models/model/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/product_card.dart';

class HomeScreenU extends StatefulWidget {
  const HomeScreenU({super.key});

  @override
  State<HomeScreenU> createState() => _HomeScreenUState();
}

class _HomeScreenUState extends State<HomeScreenU> {
  Timer? _liveRefreshTimer;

  @override
  void initState() {
    super.initState();
    fcm_token();
    // Load all data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductService>().fetchAvailableProducts();
      context.read<ProductService>().fetchBestSelling();
      context.read<BannerService>().loadHomeBanners();
      context.read<CategoryService>().loadCategories();
      context.read<BrandService>().fetchBrands();
      var authService = context.read<AuthService>();

      // Load orders only if user is logged in
      if (authService.isCustomer) {
        context.read<OrderService>().fetchMyOrders();
        context.read<CartService>().fetchCart();
        context.read<AddressService>().fetchAddresses();
        context.read<WishlistService>().fetchWishlist(
          authService.customer!.uid!,
        );
      }
    });
    _liveRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshLiveData();
    });
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshLiveData() async {
    if (!mounted) return;
    final productService = context.read<ProductService>();
    final bannerService = context.read<BannerService>();
    final orderService = context.read<OrderService>();
    final authService = context.read<AuthService>();

    await Future.wait([
      bannerService.loadHomeBanners(),
      productService.fetchAvailableProducts(forceRefresh: true, showLoader: false),
      productService.fetchBestSelling(showLoader: false),
      if (authService.isCustomer) orderService.fetchMyOrders(showLoader: false),
    ]);
  }

  Future<void> fcm_token() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('fcm_token');
    if(token != null) {
      // context.read<UserService>().updateFCM(token);
    }
  }

  Future<void> _onRefresh() async {
    final productService = context.read<ProductService>();
    final bannerService = context.read<BannerService>();
    final orderService = context.read<OrderService>();
    final categoryService = context.read<CategoryService>();
    final authService = context.read<AuthService>();
    final wishlistService = context.read<WishlistService>();
    final addressService = context.read<AddressService>();
    final cartService = context.read<CartService>();

    await Future.wait([
      bannerService.loadHomeBanners(),
      productService.fetchAvailableProducts(forceRefresh: true),
      productService.fetchBestSelling(),
      categoryService.loadCategories(),
      context.read<BrandService>().fetchBrands(),
      if (authService.isCustomer) cartService.fetchCart(),
      if (authService.isCustomer) orderService.fetchMyOrders(),
      if (authService.isCustomer) addressService.fetchAddresses(),
      if (authService.isCustomer) cartService.fetchCart(),
      if (authService.isCustomer && authService.customer?.uid != null)
        wishlistService.fetchWishlist(authService.customer!.uid!),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildModernAppBar(context),
      body: RefreshIndicator(
        color: AppColour.primary,
        backgroundColor: AppColour.white,
        onRefresh: _onRefresh,
        child: Consumer<ProductService>(
          builder: (context, productService, _) {
            if (!productService.isLoading && productService.products.isEmpty && productService.bestSelling.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No items listed yet', style: simple_text_style(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Check back later for new products', style: simple_text_style(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            }
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Sticky Search Bar Background wrapper
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: search_bar_widget(context),
                  ),
                ),

                // ✅ New: Explore Brands Horizontal Strip
                SliverToBoxAdapter(child: _buildBrandsSection()),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SliverToBoxAdapter(child: AddBannerWidget()),

                // Best Sellers Shelf
                if (productService.bestSelling.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bestsellers', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('See All', style: simple_text_style(color: AppColour.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: buildBestProductsHorizontal(context)),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // All Products Grid
                if (productService.products.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('More to Explore', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: ProductGrid(products: productService.products)),
                  ),
                ],
                
                if (productService.isLoading && productService.products.isEmpty)
                  SliverToBoxAdapter(child: SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: AppColour.primary)))),
                  
                const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for cart banner
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () => PersistentNavBarNavigator.pushNewScreen(context, screen: const SelectAddressScreen(isFromProfile: true), withNavBar: false),
        child: Row(
          children: [
            Icon(Icons.location_on, color: AppColour.primary, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Delivery in 15 mins', style: simple_text_style(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black87),
                    ],
                  ),
                  Consumer<AddressService>(
                    builder: (context, addressService, state) {
                      var list = addressService.addresses;
                      final address = list.isNotEmpty ? formatFullAddress(list.first) : 'Select a location to see products';
                      return Text(address, maxLines: 1, overflow: TextOverflow.ellipsis, style: simple_text_style(fontSize: 12, color: Colors.grey.shade600));
                    },
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: Icon(Icons.person_outline, color: Colors.grey.shade800),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBrandsSection() {
    return Consumer<BrandService>(
      builder: (context, brandService, _) {
        if (brandService.isLoading && brandService.brands.isEmpty) {
          return const SizedBox.shrink();
        }

        final brands = brandService.brands;
        if (brands.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Explore by Brand', style: simple_text_style(
                  fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                            image: brands[index].imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(brands[index].imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: brands[index].imageUrl == null
                              ? const Icon(Icons.branding_watermark, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          brands[index].name ?? "",
                          style: simple_text_style(fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget allProductsHeader() {
    return Text(
      'All Products',
      style: simple_text_style(
        color: AppColour.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _bestProductsHeader() {
    return Text(
      'Best Products',
      style: simple_text_style(
        color: AppColour.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildBestProductsHorizontal(BuildContext context) {
    return SizedBox(
      height: 240, // Taller to fit the new card design
      child: Consumer<ProductService>(
        builder: (context, productService, _) {
          final list = productService.bestSelling;
          if (list.isEmpty) return const SizedBox.shrink();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              return SizedBox(
                width: 140, // Standard quick commerce card width
                child: product_card(product: list[i], isBig: false),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGreetingSection(String name) {
    return RichText(
      text: TextSpan(
        text: 'Hey $name, ',
        style: simple_text_style(
          color: AppColour.black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: 'Welcome to Raising India',
            style: simple_text_style(
              color: AppColour.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- ORDER SECTION ---
  Widget _buildOngoingOrdersSection() {
    return Consumer<OrderService>(
      builder: (context, orderService, _) {
        if (orderService.isLoading) {
          return _buildOrderLoadingState();
        }

        // Filter for ongoing orders (Not Delivered/Cancelled)
        final ongoingOrders = orderService.orders
            .where(
              (o) =>
                  o.status != OrderStatusDeliverd &&
                  o.status != OrderStatusCancelled,
            )
            .toList();

        if (ongoingOrders.isEmpty) return const SizedBox();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ongoing Orders',
                style: simple_text_style(
                  color: AppColour.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ongoingOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _buildOrderCard(ongoingOrders[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderLoadingState() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColour.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColour.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status ?? 'PENDING');
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColour.white,
        border: Border.all(color: statusColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => PersistentNavBarNavigator.pushNewScreen(
          context,
          // Assuming you have an order tracking screen that takes ID
          screen: OrderTrackingScreen(order: order),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: simple_text_style(
                        color: AppColour.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status ?? "PENDING",
                      style: simple_text_style(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '₹${order.totalPrice?.toStringAsFixed(0) ?? "0"}',
                style: simple_text_style(
                  color: AppColour.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (order.createdAt != null)
                Text(
                  DateFormat('MMM d').format(order.createdAt!),
                  style: simple_text_style(color: Colors.grey, fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.blue;
      case 'CONFIRMED':
        return Colors.green;
      case 'SHIPPED':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green.shade700;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
