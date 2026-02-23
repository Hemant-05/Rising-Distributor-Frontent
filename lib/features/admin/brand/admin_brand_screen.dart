import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/features/admin/brand/add_brand_screen.dart';
import 'package:raising_india/features/admin/brand/brand_products_screen.dart';
import 'package:raising_india/models/model/brand.dart';

class AdminBrandScreen extends StatefulWidget {
  const AdminBrandScreen({super.key});

  @override
  State<AdminBrandScreen> createState() => _AdminBrandScreenState();
}

class _AdminBrandScreenState extends State<AdminBrandScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandService>().fetchBrands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text(
              'Brands',
              style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _navigateToAddBrand(context),
            icon: Icon(Icons.add_circle, color: AppColour.primary, size: 28),
            tooltip: 'Add Brand',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<BrandService>(
        builder: (context, brandService, child) {
          if (brandService.isLoading && brandService.brands.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }
          
          if(brandService.error.isNotEmpty){
            return _buildErrorState(context,brandService.error);
          }

          if (brandService.brands.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => brandService.fetchBrands(),
            color: AppColour.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: brandService.brands.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildBrandTile(context, brandService.brands[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandTile(BuildContext context, Brand brand) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (brand.imageUrl != null && brand.imageUrl!.isNotEmpty)
                ? CachedNetworkImage(
              imageUrl: brand.imageUrl!,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => Icon(Icons.broken_image, color: Colors.grey),
            )
                : Icon(Icons.branding_watermark, color: AppColour.primary),
          ),
        ),
        title: Text(
          brand.name ?? "Unnamed Brand",
          style: simple_text_style(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _navigateToBrandProducts(context, brand),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.branding_watermark_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Some Error Occurred',
            style: simple_text_style(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Error : $error',
            style: simple_text_style(color: Colors.redAccent),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _retryFetchBrands(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColour.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Retry',
              style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.branding_watermark_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No Brands Found',
            style: simple_text_style(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first brand to get started.',
            style: simple_text_style(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddBrand(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColour.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Brand',
              style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddBrand(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBrandScreen()),
    );
  }

  void _retryFetchBrands(BuildContext context) {
    context.read<BrandService>().fetchBrands();
  }


  void _navigateToBrandProducts(BuildContext context, Brand brand) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrandProductsScreen(brand: brand)),
    );
  }
}