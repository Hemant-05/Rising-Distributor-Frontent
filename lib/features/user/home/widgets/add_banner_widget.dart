import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/banner_service.dart';

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
          return SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator(
              color: AppColour.primary,
            )),
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

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: img,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.grey.shade100),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.broken_image_outlined, size: 32)),
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 150,
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
}