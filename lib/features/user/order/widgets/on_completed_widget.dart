import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/order/screens/order_details_screen.dart';
import 'package:raising_india/features/user/review/screens/review_screen.dart';
import 'package:raising_india/models/model/order.dart';

Widget onCompletedWidget(List<Order> list) {
  if (list.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No past orders', style: simple_text_style(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
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
      final String? firstImage = (items.isNotEmpty && items[0].product?.photosList != null && items[0].product!.photosList!.isNotEmpty)
          ? items[0].product!.photosList!.first : null;

      final isDelivered = order.status == 'DELIVERED';

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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.createdAt != null ? DateFormat('d MMM yyyy, h:mm a').format(order.createdAt!) : '', style: simple_text_style(color: Colors.grey.shade600, fontSize: 12)),
                  _buildHistoryStatusPill(order.status ?? 'UNKNOWN', isDelivered),
                ],
              ),
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60, width: 60,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: firstImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: firstImage, fit: BoxFit.cover, errorWidget: (_,__,___) => const Icon(Icons.image_not_supported, color: Colors.grey)))
                        : const Icon(Icons.history, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text('₹${order.totalPrice?.toStringAsFixed(0)} • ${items.length} Items', style: simple_text_style(color: Colors.grey.shade700, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: Colors.grey.shade300)),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order))),
                      child: Text('View Details', style: simple_text_style(color: Colors.black87, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (isDelivered) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColour.primary, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewScreen(orderId: order.id.toString()))),
                        child: Text('Rate & Review', style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildHistoryStatusPill(String status, bool isDelivered) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: isDelivered ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isDelivered ? Icons.check_circle : Icons.cancel, size: 12, color: isDelivered ? Colors.green.shade700 : Colors.red.shade700),
        const SizedBox(width: 4),
        Text(status, style: simple_text_style(color: isDelivered ? Colors.green.shade700 : Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}