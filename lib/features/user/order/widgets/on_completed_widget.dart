import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/order/screens/order_details_screen.dart';
import 'package:raising_india/models/model/order.dart';

Widget onCompletedWidget(List<Order> list) {
  if (list.isEmpty) {
    return const Center(child: Text('No history orders..'));
  }

  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: list.length,
    itemBuilder: (context, index) {
      final order = list[index];
      final items = order.orderItems ?? [];

      String title = items.map((i) => i.product?.name ?? "Item").join(", ");

      final String? firstImage = (items.isNotEmpty && items[0].product?.photosList != null)
          ? items[0].product!.photosList!.first
          : null;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColour.lightGrey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: firstImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: firstImage,
                      fit: BoxFit.cover,
                      errorWidget: (_,__,___) => const Icon(Icons.history),
                    ),
                  )
                      : const Center(child: Icon(Icons.history)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: simple_text_style(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${order.totalPrice?.toStringAsFixed(0)}',
                        style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.status ?? "UNKNOWN",
                        style: simple_text_style(
                          color: order.status == 'DELIVERED' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (order.createdAt != null)
                        Text(
                          DateFormat('d MMM yyyy').format(order.createdAt!),
                          style: simple_text_style(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: elevated_button_style(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsScreen(order: order),
                        ),
                      );
                    },
                    child: Text(
                      'Details',
                      style: simple_text_style(color: AppColour.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Add Review Button logic here if needed
              ],
            ),
            const Divider(),
          ],
        ),
      );
    },
  );
}