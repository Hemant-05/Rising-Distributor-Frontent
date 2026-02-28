import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/banner_service.dart';
import 'package:raising_india/data/services/cart_service.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/data/services/product_service.dart';

// Screens & Widgets
import 'package:raising_india/features/user/address/screens/select_address_screen.dart';
import 'package:raising_india/features/user/home/widgets/add_banner_widget.dart';
import 'package:raising_india/features/user/home/widgets/categories_section.dart';
import 'package:raising_india/features/user/home/widgets/product_grid.dart';
import 'package:raising_india/features/user/home/widgets/search_bar_widget.dart';
import 'package:raising_india/features/user/order/screens/order_tracking_screen.dart';
import 'package:raising_india/models/model/order.dart';
import '../widgets/product_card.dart';

class HomeScreenU extends StatefulWidget {
  const HomeScreenU({super.key});

  @override
  State<HomeScreenU> createState() => _HomeScreenUState();
}

class _HomeScreenUState extends State<HomeScreenU> {

  @override
  void initState() {
    super.initState();
    // Load all data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductService>().fetchAvailableProducts();
      context.read<ProductService>().fetchBestSelling();
      context.read<BannerService>().loadHomeBanners();
      context.read<CategoryService>().loadCategories();

      // Load orders only if user is logged in
      if (context.read<AuthService>().isCustomer) {
        context.read<OrderService>().fetchMyOrders();
        context.read<CartService>().fetchCart();
      }
    });
  }

  Future<void> _onRefresh() async {
    final productService = context.read<ProductService>();
    final bannerService = context.read<BannerService>();
    final orderService = context.read<OrderService>();
    final categoryService = context.read<CategoryService>();

    await Future.wait([
      bannerService.loadHomeBanners(),
      productService.fetchAvailableProducts(),
      productService.fetchBestSelling(),
      categoryService.loadCategories(),
      if (context.read<AuthService>().isCustomer)
        orderService.fetchMyOrders(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Access User Data
    final authService = context.watch<AuthService>();
    final user = authService.customer;

    // Fallback if not logged in (though Splash Screen prevents this)
    String addressDisplay = 'Tap to add address...';
    String nameDisplay = 'there';

    if (user != null) {
      nameDisplay = user.name?.split(' ').first ?? 'User';
    }

    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: buildModernAppBar(context, addressDisplay),
      body: RefreshIndicator(
        color: AppColour.primary,
        backgroundColor: AppColour.white,
        onRefresh: _onRefresh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildGreetingSection(nameDisplay)),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: search_bar_widget(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              const SliverToBoxAdapter(child: AddBannerWidget()),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: categories_section(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: _buildOngoingOrdersSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: _bestProductsHeader()),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: buildBestProductsHorizontal(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(child: allProductsHeader()),

              // All Products Grid
              Consumer<ProductService>(
                builder: (context, productService, _) {
                  if (productService.isLoading && productService.products.isEmpty) {
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator(
                          color: AppColour.primary ,
                        )),
                      ),
                    );
                  }
                  if (productService.products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text('No products available')),
                    );
                  }
                  return SliverToBoxAdapter(
                    child: ProductGrid(products: productService.products),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildModernAppBar(BuildContext context, String address) {
    return AppBar(
      backgroundColor: AppColour.white,
      elevation: 0,
      titleSpacing: 12,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColour.primary,
            child: const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DELIVER TO',
                  style: simple_text_style(
                    color: AppColour.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const SelectAddressScreen(isFromProfile: true),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  ),
                  child: Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: simple_text_style(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      height: 250,
      child: Consumer<ProductService>(
        builder: (context, productService, _) {
          if (productService.isLoading && productService.bestSelling.isEmpty) {
            if(productService.isLoading){
              return SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator(
                  color: AppColour.primary,
                )),
              );
            }
          }
          final list = productService.bestSelling;
          if (list.isEmpty) {
            return const Center(child: Text('No Best Selling Products'));
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              return SizedBox(
              width: 180,
              child: product_card(
                product: list[i],
                isBig: true,
              ),
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
        final ongoingOrders = orderService.orders.where((o) =>
        o.status != 'DELIVERED' && o.status != 'CANCELLED'
        ).toList();

        if (ongoingOrders.isEmpty) return const SizedBox();

        return Column(
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
        child: CircularProgressIndicator(color: AppColour.primary, strokeWidth: 2),
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
                '₹${order.totalPrice?.toStringAsFixed(2) ?? "0.00"}',
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
      case 'PENDING': return Colors.blue;
      case 'CONFIRMED': return Colors.green;
      case 'SHIPPED': return Colors.purple;
      case 'DELIVERED': return Colors.green.shade700;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }
}