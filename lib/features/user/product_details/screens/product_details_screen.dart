import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/auth_gate.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/helper_functions.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/data/services/cart_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/data/services/review_service.dart';
import 'package:raising_india/features/user/cart/screens/cart_screen.dart';
import 'package:raising_india/features/user/product_details/widgets/build_detail_chip.dart';
import 'package:raising_india/features/user/product_details/widgets/favorite_button.dart';
import 'package:raising_india/models/model/product.dart';
import 'package:raising_india/models/model/product_review.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  Timer? _refreshTimer;
  late Product _product;
  List<ProductReview> _reviews = [];
  int _currentQuantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProductService>().fetchAvailableProducts();
      await _refreshProduct(showLoader: false);
      await _loadReviews();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 12), (_) async {
      await _refreshProduct(showLoader: false);
      await _loadReviews();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshProduct({required bool showLoader}) async {
    final pid = _product.pid;
    if (!mounted || pid == null) return;

    final updated = await context.read<ProductService>().refreshProduct(pid);
    if (mounted && updated != null) {
      setState(() => _product = updated);
    }
  }

  Future<void> _loadReviews() async {
    final pid = _product.pid;
    if (!mounted || pid == null) return;

    final reviews = await context.read<ReviewService>().getProductReviews(pid);
    if (mounted) {
      setState(() => _reviews = reviews);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double price = _product.price ?? 0;
    final double mrp = _product.mrp ?? price;
    final bool hasDiscount = mrp > price;
    final bool isOutOfStock = (_product.stockQuantity ?? 0) <= 0;
    final bool isAvailable = _product.available ?? true;

    final allProducts = context.watch<ProductService>().products;
    final similarCategoryProducts = allProducts
        .where(
          (p) =>
              p.category?.id == _product.category?.id && p.pid != _product.pid,
        )
        .toList();
    final similarBrandProducts = allProducts
        .where(
          (p) => p.brand?.id == _product.brand?.id && p.pid != _product.pid,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 10),
            Text(
              'Product Details',
              style: simple_text_style(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColour.black,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: AppColour.primary,
              onRefresh: () async {
                await _refreshProduct(showLoader: false);
                await _loadReviews();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSlider(),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _product.name ?? 'Unknown Product',
                                      style: simple_text_style(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColour.black,
                                      ),
                                    ),
                                    if (_product.brand?.name != null ||
                                        _product.category?.name != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        [
                                          if (_product.brand?.name != null)
                                            'Brand: ${_product.brand!.name}',
                                          if (_product.category?.name != null)
                                            'Category: ${_product.category!.name}',
                                        ].join('  •  '),
                                        style: simple_text_style(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColour.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              FavoriteButton(product: _product),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildRatingRow(),
                          const SizedBox(height: 18),
                          _buildDetailChips(),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Description',
                                style: simple_text_style(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColour.black,
                                ),
                              ),
                              if (!isOutOfStock && isAvailable)
                                _buildQuantityControl(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _product.description ?? 'No description available.',
                            style: TextStyle(
                              fontFamily: 'Sen',
                              fontSize: 16,
                              color: AppColour.lightGrey,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  if (similarCategoryProducts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildHorizontalProductList(
                        'Similar in ${_product.category?.name ?? 'Category'}',
                        similarCategoryProducts,
                      ),
                    ),
                  if (similarBrandProducts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildHorizontalProductList(
                        'More from ${_product.brand?.name ?? 'this Brand'}',
                        similarBrandProducts,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            ),
          ),
          _buildBottomBar(price, mrp, hasDiscount, isOutOfStock, isAvailable),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    final images = _product.photosList ?? [];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColour.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.isEmpty ? 1 : images.length,
                  itemBuilder: (context, index) {
                    if (images.isEmpty) return _buildPlaceholderImage();
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      ),
                    );
                  },
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: images.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: AppColour.primary,
                          dotColor: Colors.white.withOpacity(0.5),
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 60,
          color: AppColour.lightGrey,
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    final double rating = _product.rating ?? 0.0;
    final int count = _product.reviewCount ?? _reviews.length;
    return Row(
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < rating.round() ? Icons.star : Icons.star_border,
              color: AppColour.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'Sen',
            fontSize: 14,
            color: AppColour.lightGrey,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColour.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count User${count == 1 ? '' : 's'} Rated',
            style: TextStyle(
              fontFamily: 'Sen',
              fontSize: 12,
              color: AppColour.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        buildDetailChip(
          icon: delivery_svg,
          label: 'Fast Delivery',
          isIcon: true,
          color: AppColour.primary.withOpacity(0.1),
        ),
        if (_product.quantity != null)
          buildDetailChip(
            label: '${_product.quantity} ${_product.measurement ?? ''}'.trim(),
            isIcon: false,
            color: AppColour.lightGrey.withOpacity(0.1),
            icon: '',
          ),
        if (_product.category?.name?.isNotEmpty == true)
          buildDetailChip(
            icon: '',
            label: 'Category: ${_product.category!.name}',
            isIcon: false,
            color: Colors.green.withOpacity(0.1),
          ),
        if (_product.brand?.name?.isNotEmpty == true)
          buildDetailChip(
            icon: '',
            label: 'Brand: ${_product.brand!.name}',
            isIcon: false,
            color: Colors.blue.withOpacity(0.1),
          ),
      ],
    );
  }

  Widget _buildHorizontalProductList(String title, List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: simple_text_style(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColour.black,
            ),
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            itemBuilder: (context, index) =>
                _buildMiniProductCard(products[index]),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMiniProductCard(Product product) {
    final imageUrl = product.photosList?.isNotEmpty == true
        ? product.photosList!.first
        : '';
    final price = product.price ?? 0;
    final mrp = product.mrp ?? price;

    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ProductDetailsScreen(product: product),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: simple_text_style(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rs.${price.toStringAsFixed(0)}',
                        style: simple_text_style(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColour.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (mrp > price)
                        Expanded(
                          child: Text(
                            'Rs.${mrp.toStringAsFixed(0)}',
                            style: simple_text_style(
                              fontSize: 12,
                              color: Colors.grey,
                              isEllipsisAble: true,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Consumer<CartService>(
      builder: (context, cartService, _) {
        final cartItemIndex = cartService.cartItems.indexWhere(
          (item) => item.product?.pid == _product.pid,
        );
        final bool isInCart = cartItemIndex != -1;
        final int displayQty = isInCart
            ? (cartService.cartItems[cartItemIndex].quantity ?? 1)
            : _currentQuantity;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColour.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColour.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final signedIn = await ensureCustomerSignedIn(context);
                  if (!signedIn || !context.mounted) return;
                  if (isInCart) {
                    if (displayQty > 1) {
                      cartService.updateQuantity(_product.pid!, displayQty - 1);
                    } else {
                      cartService.removeFromCart(_product.pid!);
                    }
                  } else if (_currentQuantity > 1) {
                    setState(() => _currentQuantity--);
                  }
                },
                child: _qtyIcon(Icons.remove),
              ),
              const SizedBox(width: 12),
              Text(
                displayQty.toString(),
                style: simple_text_style(
                  fontSize: 18,
                  color: AppColour.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  final signedIn = await ensureCustomerSignedIn(context);
                  if (!signedIn || !context.mounted) return;
                  if (isInCart) {
                    cartService.updateQuantity(_product.pid!, displayQty + 1);
                  } else {
                    setState(() => _currentQuantity++);
                  }
                },
                child: _qtyIcon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _qtyIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColour.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: AppColour.primary, size: 18),
    );
  }

  Widget _buildBottomBar(
    double price,
    double mrp,
    bool hasDiscount,
    bool isOutOfStock,
    bool isAvailable,
  ) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColour.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColour.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: (isOutOfStock || !isAvailable)
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: AppColour.lightGrey,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Out of Stock',
                    style: simple_text_style(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColour.lightGrey,
                    ),
                  ),
                ],
              ),
            )
          : Consumer<CartService>(
              builder: (context, cartService, _) {
                final isInCart = cartService.cartItems.any(
                  (item) => item.product?.pid == _product.pid,
                );
                final int qty = isInCart
                    ? (cartService.cartItems
                              .firstWhere(
                                (item) => item.product?.pid == _product.pid,
                              )
                              .quantity ??
                          1)
                    : _currentQuantity;
                final double finalTotal = price * qty;
                final double finalMrpTotal = mrp * qty;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price', style: simple_text_style()),
                          Row(
                            children: [
                              Text(
                                'Rs.${finalTotal.toStringAsFixed(0)}',
                                style: simple_text_style(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColour.black,
                                ),
                              ),
                              if (hasDiscount) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'Rs.${finalMrpTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontFamily: 'Sen',
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    decorationThickness: 2,
                                    color: AppColour.lightGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColour.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${calculatePercentage(mrp, price).toStringAsFixed(0)}% OFF',
                                    style: TextStyle(
                                      fontFamily: 'Sen',
                                      fontSize: 12,
                                      color: AppColour.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColour.primary,
                          foregroundColor: AppColour.white,
                          elevation: 8,
                          shadowColor: AppColour.primary.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final signedIn = await ensureCustomerSignedIn(
                            context,
                          );
                          if (!signedIn || !context.mounted) return;
                          if (isInCart) {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: const CartScreen(),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          } else {
                            cartService.addToCart(
                              _product.pid!,
                              _currentQuantity,
                            );
                          }
                        },
                        child: cartService.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isInCart ? 'View Cart' : 'Add to Cart',
                                style: simple_text_style(
                                  color: AppColour.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
