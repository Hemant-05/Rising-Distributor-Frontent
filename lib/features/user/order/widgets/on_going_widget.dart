import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/features/user/order/screens/order_details_screen.dart';
import 'package:raising_india/features/user/order/screens/order_tracking_screen.dart';
import 'package:raising_india/features/user/order/widgets/order_cancel_dialog.dart';
import 'package:raising_india/models/model/order.dart';

Widget onGoingWidget(List<Order> list) {
  if (list.isEmpty) {
    return const Center(child: Text('No ongoing orders..'));
  }

  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: list.length,
    itemBuilder: (context, index) {
      final order = list[index];

      // Prepare Items Data
      final items = order.orderItems ?? [];
      String title = items.map((i) => i.product?.name ?? "Item").join(", ");
      if (title.length > 50) title = "${title.substring(0, 50)}...";

      final String? firstImage = (items.isNotEmpty && items[0].product?.photosList != null)
          ? items[0].product!.photosList!.first
          : null;

      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                children: [
                  // Image Box
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
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: firstImage,
                            fit: BoxFit.cover,
                            errorWidget: (_,__,___) => const Icon(Icons.error),
                          ),
                          if (items.length > 1)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 20,
                                width: 80,
                                alignment: Alignment.center,
                                color: Colors.black54,
                                child: Text(
                                  '+${items.length - 1} more',
                                  style: simple_text_style(fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                        : const Center(child: Icon(Icons.shopping_bag)),
                  ),

                  // Details
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
                        Row(
                          children: [
                            Text(
                              '₹${order.totalPrice?.toStringAsFixed(0) ?? "0"}',
                              style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            _verticalDivider(),
                            Text(
                              '${items.length} ${(items.length > 1) ? 'Items' : 'Item'}',
                              style: simple_text_style(color: AppColour.lightGrey, fontSize: 12),
                            ),
                            _verticalDivider(),
                            if (order.createdAt != null)
                              Text(
                                DateFormat('hh:mm a').format(order.createdAt!),
                                style: simple_text_style(color: AppColour.lightGrey, fontSize: 12),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Status : ${order.status}',
                          style: simple_text_style(color: AppColour.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: ElevatedButton(
                      style: elevated_button_style(),
                      onPressed: () {
                        showCancelOrderDialog(context, (reason) async {
                          // Call Service to Cancel
                          final error = await context.read<OrderService>().cancelOrder(order.id!, reason);
                          if (error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Order Cancelled")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error)),
                            );
                          }
                        });
                      },
                      child: Text(
                        'Cancel',
                        style: simple_text_style(color: AppColour.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Track Button
                  Expanded(
                    child: ElevatedButton(
                      style: elevated_button_style(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order,)),
                        );
                      },
                      child: Text(
                        'Track',
                        style: simple_text_style(color: AppColour.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      );
    },
  );
}

Widget _verticalDivider() {
  return Container(
    height: 12,
    width: 1,
    color: Colors.grey,
    margin: const EdgeInsets.symmetric(horizontal: 6),
  );
}