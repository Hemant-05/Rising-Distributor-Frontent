import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/admin_service.dart';
import 'package:raising_india/features/admin/order/OrderFilterType.dart';
import 'package:raising_india/features/admin/order/admin_order_card.dart';
import 'package:raising_india/features/admin/widgets/admin_responsive.dart';

class OrderListScreen extends StatelessWidget {
  final String title;
  final OrderFilterType orderType;

  const OrderListScreen({
    super.key,
    required this.title,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    return OrderListView(title: title, orderType: orderType);
  }
}

class OrderListView extends StatefulWidget {
  final String title;
  final OrderFilterType orderType;

  const OrderListView({
    super.key,
    required this.title,
    required this.orderType,
  });

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        surfaceTintColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title,
                style: simple_text_style(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<AdminService>(
        builder: (context, adminService, _) {
          if (adminService.isLoading && adminService.filteredOrders.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            );
          }

          if (adminService.error != null) {
            return _buildErrorState(context, adminService.error!);
          }

          if (adminService.filteredOrders.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppColour.primary,
            backgroundColor: AppColour.white,
            onRefresh: () async {
              await context.read<AdminService>().loadOrdersByFilterType(
                widget.orderType,
              );
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop =
                    constraints.maxWidth >= AdminResponsive.desktopBreakpoint;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AdminResponsive.maxContentWidth,
                    ),
                    child: isDesktop
                        ? _buildDesktopGrid(adminService)
                        : _buildMobileList(adminService),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopGrid(AdminService adminService) {
    final itemCount =
        adminService.filteredOrders.length + (adminService.isLoading ? 1 : 0);
    return GridView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 540,
        mainAxisExtent: 260,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) => _buildOrderItem(adminService, index),
    );
  }

  Widget _buildMobileList(AdminService adminService) {
    final itemCount =
        adminService.filteredOrders.length + (adminService.isLoading ? 1 : 0);
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildOrderItem(adminService, index),
    );
  }

  Widget _buildOrderItem(AdminService adminService, int index) {
    if (index >= adminService.filteredOrders.length) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final order = adminService.filteredOrders[index];
    return AdminOrderCard(
      order: order,
      showTime: widget.orderType == OrderFilterType.today,
      isRunning: widget.orderType == OrderFilterType.running,
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return AdminPageShell(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppColour.red),
            const SizedBox(height: 12),
            Text('Error: $error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: elevated_button_style(),
              onPressed: () => context
                  .read<AdminService>()
                  .loadOrdersByFilterType(widget.orderType),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Retry',
                style: simple_text_style(color: AppColour.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AdminPageShell(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No ${widget.title} Orders Found',
              style: simple_text_style(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
