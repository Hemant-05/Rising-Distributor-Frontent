import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/features/user/order/screens/order_details_screen.dart';
import 'package:raising_india/features/user/order/screens/order_tracking_screen.dart';
import 'package:raising_india/features/user/order/widgets/order_cancel_dialog.dart';
import 'package:raising_india/models/model/order.dart';

Widget onGoingWidget(List<Order> list) {
  if (list.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No ongoing orders', style: simple_text_style(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    itemCount: list.length,
    separatorBuilder: (_, __) => const SizedBox(height: 16),
    itemBuilder: (context, index) {
      final order = list[index];
      final items = order.orderItems ?? [];

      String title = items.map((i) => i.product?.name ?? "Item").join(", ");
      if (title.length > 40) title = "${title.substring(0, 40)}...";

      final String? firstImage = (items.isNotEmpty && items[0].product?.photosList != null && items[0].product!.photosList!.isNotEmpty)
          ? items[0].product!.photosList!.first
          : null;

      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order))),
        child: Container(
          decoration: BoxDecoration(
            color: AppColour.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID & Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${order.id}', style: simple_text_style(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  _buildStatusPill(order.status ?? 'UNKNOWN'),
                ],
              ),
              const Divider(height: 24),

              // Body: Image & Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70, width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: firstImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(imageUrl: firstImage, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey)),
                    )
                        : const Icon(Icons.shopping_bag, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('₹${order.totalPrice?.toStringAsFixed(0) ?? "0"}', style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16, color: AppColour.primary)),
                            _verticalDivider(),
                            Text('${items.length} ${items.length > 1 ? 'Items' : 'Item'}', style: simple_text_style(color: Colors.grey.shade600, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Footer: Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      onPressed: () {
                        showCancelOrderDialog(context, (reason) async {
                          final error = await context.read<OrderService>().cancelOrder(order.id!, reason);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(error ?? "Order Cancelled"),
                              backgroundColor: error == null ? Colors.green : Colors.red,
                            ));
                          }
                        });
                      },
                      child: Text('Cancel', style: simple_text_style(color: Colors.red.shade600, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColour.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order))),
                      child: Text('Track Order', style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _verticalDivider() => Container(height: 12, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8));

Widget _buildStatusPill(String status) {
  Color bgColor = Colors.blue.shade50;
  Color textColor = Colors.blue.shade700;
  if (status == 'PREPARING') { bgColor = Colors.orange.shade50; textColor = Colors.orange.shade800; }
  else if (status == 'CONFIRMED') { bgColor = Colors.teal.shade50; textColor = Colors.teal.shade700; }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
    child: Text(status, style: simple_text_style(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
  );
}