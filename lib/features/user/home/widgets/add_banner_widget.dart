import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/banner_service.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/features/user/products/screens/product_collection_screen.dart';

class AddBannerWidget extends StatefulWidget {
  const AddBannerWidget({super.key});
  @override
  State<AddBannerWidget> createState() => _AddBannerWidgetState();
}

class _AddBannerWidgetState extends State<AddBannerWidget> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Consumer<BannerService>(
      builder: (context, bannerService, child) {
        if (bannerService.isLoading && bannerService.homeBanners.isEmpty) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColour.primary,
              ),
            ),
          );
        }

        final items = bannerService.homeBanners;

        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: radius,
                child: CarouselSlider.builder(
                  carouselController: _controller,
                  itemCount: items.length,
                  itemBuilder: (context, i, realIdx) {
                    final banner = items[i];
                    final img = banner.imageUrl ?? '';

                    return InkWell(
                      onTap: () => _openBannerTarget(context, banner),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: img,
                            fit: BoxFit.fill,
                            placeholder: (_, __) => Container(color: Colors.grey.shade100),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(child: Icon(Icons.broken_image_outlined, size: 32)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.92,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.16,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(milliseconds: 600),
                    onPageChanged: (i, reason) => setState(() => _index = i),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (i) {
                final selected = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: selected ? 18 : 6,
                  decoration: BoxDecoration(
                    color: selected ? AppColour.primary : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  void _openBannerTarget(BuildContext context, dynamic banner) {
    final rawRoute = banner.redirectRoute?.toString().trim();
    if (rawRoute == null || rawRoute.isEmpty) return;

    final route = rawRoute.replaceFirst(RegExp(r'^/+'), '').trim();
    Widget? target;

    if (route == 'sales' || route == 'sale') {
      target = const ProductCollectionScreen.sale();
    } else if (route.startsWith('category:')) {
      final categoryName = Uri.decodeComponent(route.substring('category:'.length).trim());
      if (categoryName.isNotEmpty) {
        target = ProductCollectionScreen.category(categoryName: categoryName);
      }
    } else if (route.startsWith('category/')) {
      final categoryName = Uri.decodeComponent(route.substring('category/'.length).trim());
      if (categoryName.isNotEmpty) {
        target = ProductCollectionScreen.category(categoryName: categoryName);
      }
    } else if (route.startsWith('brand:') || route.startsWith('brand/')) {
      final value = route.contains(':')
          ? route.substring(route.indexOf(':') + 1).trim()
          : route.substring('brand/'.length).trim();
      final brandId = int.tryParse(value);
      if (brandId != null) {
        final brands = context.read<BrandService>().brands;
        final brandIndex = brands.indexWhere((brand) => brand.id == brandId);
        target = ProductCollectionScreen.brand(
          brand: brandIndex == -1 ? null : brands[brandIndex],
          brandId: brandId,
        );
      }
    }

    if (target == null) return;

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: target,
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
