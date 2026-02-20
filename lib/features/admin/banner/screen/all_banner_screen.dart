import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/banner_service.dart';
import 'package:raising_india/features/admin/banner/screen/add_banner_screen.dart';

class AllBannerScreen extends StatefulWidget {
  const AllBannerScreen({super.key});

  @override
  State<AllBannerScreen> createState() => _AllBannerScreenState();
}

class _AllBannerScreenState extends State<AllBannerScreen> {
  @override
  void initState() {
    super.initState();
    // Load banners when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerService>().loadHomeBanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('All Banners', style: simple_text_style(fontSize: 18)),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBannerScreen()),
                );
              },
              child: Text(
                'Add',
                style: simple_text_style(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColour.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Consumer<BannerService>(
        builder: (context, bannerService, child) {
          if (bannerService.isLoading && bannerService.banners.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            );
          }

          if (bannerService.banners.isEmpty) {
            return Center(
              child: Text('No Banner Added yet!!', style: simple_text_style()),
            );
          }

          return ListView.builder(
            itemCount: bannerService.banners.length,
            itemBuilder: (context, index) {
              final banner = bannerService.banners[index];
              final imageUrl = banner.imageUrl;
              final bannerId = banner.id;

              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColour.grey, width: 1),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColour.black, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColour.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: InkWell(
                        onTap: () async {
                          final error = await context
                              .read<BannerService>()
                              .deleteBanner(banner.id!);
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Icon(
                          Icons.delete_forever_outlined,
                          color: AppColour.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
