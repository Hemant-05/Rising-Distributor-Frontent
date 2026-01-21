import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/features/user/address/screens/select_address_screen.dart';
import 'package:raising_india/features/user/home/bloc/user_product_bloc/category_product_bloc.dart';
import 'package:raising_india/features/user/home/widgets/add_banner_widget.dart';
import 'package:raising_india/features/user/home/widgets/categories_section.dart';
import 'package:raising_india/features/user/home/widgets/product_grid.dart';
import 'package:raising_india/features/user/home/widgets/search_bar_widget.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import 'package:raising_india/features/user/order/screens/order_tracking_screen.dart';
import 'package:raising_india/models/order_model.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../widgets/product_card.dart';

class HomeScreenU extends StatefulWidget {
  const HomeScreenU({super.key});

  @override
  State<HomeScreenU> createState() => _HomeScreenUState();
}

class _HomeScreenUState extends State<HomeScreenU> {
  AuthService authService = AuthService();
  String address = 'Fetching address...';
  String name = 'there';

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CategoryProductBloc>(
      context,
    ).add(FetchBestSellingProducts());
    BlocProvider.of<CategoryProductBloc>(context).add(FetchAllProducts());
    BlocProvider.of<OrderBloc>(context).add(LoadUserOngoingOrderEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserAuthenticated) {
          address = state.user.addressList.isNotEmpty
              ? state.user.addressList[0].streetAddress
              : '';
          name = state.user.name.split(' ').first;
        } else if (state is UserUnauthenticated) {
          return Scaffold(body: Center(child: Text('Please Restart the App')));
        } else if (state is UserError) {
          return Scaffold(body: Center(child: Text('Error: ${state.message}')));
        }
        return Scaffold(
          backgroundColor: AppColour.white,
          appBar: buildModernAppBar(context),
          body: RefreshIndicator(
            color: AppColour.primary,
            backgroundColor: AppColour.white,
            onRefresh: () async {
              context.read<CategoryProductBloc>().add(
                FetchBestSellingProducts(),
              );
              context.read<CategoryProductBloc>().add(FetchAllProducts());
              context.read<OrderBloc>().add(LoadUserOngoingOrderEvent());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildGreetingSection()),
                  SliverToBoxAdapter(child: const SizedBox(height: 10)),
                  SliverToBoxAdapter(child: search_bar_widget(context)),
                  SliverToBoxAdapter(child: const SizedBox(height: 14)),
                  SliverToBoxAdapter(child: const AddBannerWidget()),
                  SliverToBoxAdapter(child: const SizedBox(height: 10)),
                  SliverToBoxAdapter(child: _buildCategoriesStrip(context)),
                  SliverToBoxAdapter(child: const SizedBox(height: 10)),
                  SliverToBoxAdapter(child: _buildOngoingOrdersSection()),
                  SliverToBoxAdapter(child: const SizedBox(height: 10)),
                  SliverToBoxAdapter(child: _bestProductsHeader()),
                  SliverToBoxAdapter(child: const SizedBox(height: 10)),
                  SliverToBoxAdapter(
                    child: buildBestProductsHorizontal(context),
                  ),
                  SliverToBoxAdapter(child: const SizedBox(height: 18)),
                  SliverToBoxAdapter(child: allProductsHeader()),
                  BlocBuilder<CategoryProductBloc, CategoryProductState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }
                      if (state.error != null) {
                        return SliverToBoxAdapter(
                          child: Center(child: Text(state.error!)),
                        );
                      }
                      if (state.allProducts.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(child: Text('No products')),
                        );
                      }
                      // Use your existing ProductGrid here for All Products; only visuals changed via product_card below
                      return SliverToBoxAdapter(
                        child: ProductGrid(products: state.allProducts),
                      ); // ensure your bloc exposes 'products'
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColour.white,
      elevation: 0,
      titleSpacing: 12,
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
                    address.isNotEmpty ? address : 'Tap to add address...',
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
      child: BlocBuilder<CategoryProductBloc, CategoryProductState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = state.bestSellingProducts;
          if (list.isEmpty) {
            return const Center(child: Text('No Best Selling Products'));
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => SizedBox(
              width: 180,
              child: product_card(
                product: list[i],
                isBig: true,
              ), // uses redesigned card below
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesStrip(BuildContext context) {
    return categories_section(context);
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusColor = _getStatusColor(order.orderStatus);
    return Container(
      width: 180,
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
          screen: OrderTrackingScreen(orderId: order.orderId),
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
                      '#${order.orderId.substring(0, 6)}',
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
                      _getStatusText(order.orderStatus),
                      style: simple_text_style(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: simple_text_style(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, h:mm a').format(order.createdAt),
                style: simple_text_style(color: Colors.black, fontSize: 11),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: simple_text_style(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '₹${order.total.toStringAsFixed(2)}',
                    style: simple_text_style(
                      color: AppColour.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
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

  Widget _buildOngoingOrdersSection() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        return state is OrderLoadingState
            ? _buildOrderLoadingState()
            : state is OngoingOrderLoadedState
            ? Visibility(
                visible: state.orderList.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ongoing Orders',
                          style: simple_text_style(
                            color: AppColour.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildOrdersList(state.orderList),
                  ],
                ),
              )
            : SizedBox();
      },
    );
  }

  Widget _buildOrderLoadingState() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColour.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColour.primary, strokeWidth: 2),
            const SizedBox(height: 12),
            Text(
              'Loading your orders...',
              style: simple_text_style(
                color: AppColour.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  /*

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor = _getStatusColor(order.orderStatus);

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(orderId: order.orderId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.orderId.substring(0, 6)}',
                    style: simple_text_style(
                      color: AppColour.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(order.orderStatus),
                      style: simple_text_style(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Items count
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: simple_text_style(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              // Order date
              Text(
                DateFormat('MMM d, h:mm a').format(order.createdAt),
                style: simple_text_style(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),

              // Total amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: simple_text_style(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${order.total.toStringAsFixed(2)}',
                    style: simple_text_style(
                      color: AppColour.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBestProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Products',
          style: simple_text_style(
            color: AppColour.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<CategoryProductBloc, CategoryProductState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppColour.primary),
                ),
              );
            } else if (state.bestSellingProducts.isEmpty) {
              return Container(
                height: 200,
                child: Center(
                  child: Text(
                    'No Best Selling Products Available',
                    style: simple_text_style(
                      color: AppColour.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            } else if (state.error != null) {
              return Container(
                height: 200,
                child: Center(child: Text(state.error!)),
              );
            } else {
              return ProductGrid(products: state.bestSellingProducts);
            }
          },
        ),
      ],
    );
  }*/

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case OrderStatusCreated:
        return Colors.blue;
      case OrderStatusConfirmed:
        return Colors.green;
      case OrderStatusPreparing:
        return Colors.orange;
      case OrderStatusDispatch:
        return Colors.purple;
      case OrderStatusDeliverd:
        return Colors.green.shade700;
      case OrderStatusCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case OrderStatusCreated:
        return 'Placed';
      case OrderStatusConfirmed:
        return 'Confirmed';
      case OrderStatusPreparing:
        return 'Preparing';
      case OrderStatusDispatch:
        return 'Dispatched';
      case OrderStatusDeliverd:
        return 'Delivered';
      case OrderStatusCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }
}
