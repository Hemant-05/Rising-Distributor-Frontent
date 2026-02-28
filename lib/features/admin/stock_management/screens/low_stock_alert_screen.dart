import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/admin_service.dart';
import 'package:raising_india/models/model/product.dart';

class LowStockAlertScreen extends StatefulWidget {
  const LowStockAlertScreen({super.key});

  @override
  State<LowStockAlertScreen> createState() => _LowStockAlertScreenState();
}

class _LowStockAlertScreenState extends State<LowStockAlertScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  List<Product> _lowStockProducts = [];

  @override
  void initState() {
    super.initState();

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLowStockProducts();
    });

    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadLowStockProducts() async {
    context.read<AdminService>().fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminService>(
      builder: (context, adminService, _) {
        _lowStockProducts = adminService.dashboardStats!.lowStockProducts!;
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: _buildStunningAppBar(),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: adminService.isLoading
                ? _buildLoadingState()
                : _lowStockProducts.isEmpty
                ? _buildEmptyState()
                : _buildLowStockList(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _loadLowStockProducts,
            backgroundColor: AppColour.red.withOpacity(0.8),
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Refresh',
              style: simple_text_style(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildStunningAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade600, Colors.red.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          back_button(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Low Stock Alerts',
                  style: simple_text_style(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Monitor inventory levels',
                  style: simple_text_style(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Alert count badge
          if (_lowStockProducts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_lowStockProducts.length}',
                style: simple_text_style(
                  color: Colors.red.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            'Checking Stock Levels...',
            style: simple_text_style(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All Good! 🎉',
            style: simple_text_style(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No products are running low on stock.\nYour inventory levels look healthy!',
            style: simple_text_style(
              color: Colors.green.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockList() {
    return Column(
      children: [
        // Summary Header
        _buildSummaryHeader(),

        // Products List
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _lowStockProducts.length,
            itemBuilder: (context, index) {
              final product = _lowStockProducts[index];
              return _buildLowStockCard(product, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    final outOfStockCount = _lowStockProducts
        .where((p) => !p.available!)
        .length;
    final lowStockCount = _lowStockProducts.length - outOfStockCount;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Out of Stock',
                outOfStockCount.toString(),
                Icons.highlight_off,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Low Stock',
                lowStockCount.toString(),
                Icons.warning,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Total Alerts',
                _lowStockProducts.length.toString(),
                Icons.notifications_active,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: simple_text_style(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: simple_text_style(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLowStockCard(Product product, int index) {
    final isOutOfStock = !product.available!;
    final urgencyColor = isOutOfStock ? Colors.red : Colors.orange;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: urgencyColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: urgencyColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Product Image
                  _buildProductImage(product),
                  const SizedBox(width: 16),

                  // Product Info
                  Expanded(child: _buildProductInfo(product)),

                  // Stock Status
                  _buildStockStatus(product),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: product.photosList!.isNotEmpty
            ? Image.network(
                product.photosList!.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                ),
              )
            : Container(
                color: Colors.grey.shade100,
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade400,
                  size: 32,
                ),
              ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name!,
          style: simple_text_style(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        Row(
          children: [
            Icon(Icons.category, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              product.category!.name!,
              style: simple_text_style(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '₹${product.price!.toStringAsFixed(0)} • ${product.quantity!.toStringAsFixed(0)} ${product.measurement}',
            style: simple_text_style(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockStatus(Product product) {
    final isOutOfStock = !product.available!;
    final urgencyColor = isOutOfStock ? Colors.red : Colors.orange;
    final stockPercentage = product.lowStockQuantity! > 0
        ? (product.stockQuantity! / product.lowStockQuantity!).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: urgencyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: urgencyColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                isOutOfStock ? Icons.highlight_off : Icons.warning,
                color: urgencyColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                isOutOfStock ? 'OUT' : 'LOW',
                style: simple_text_style(
                  color: urgencyColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Stock Numbers
        Column(
          children: [
            Text(
              '${product.stockQuantity!.toInt()}',
              style: simple_text_style(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: urgencyColor,
              ),
            ),
            Text(
              'of ${product.lowStockQuantity!.toInt()}',
              style: simple_text_style(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
