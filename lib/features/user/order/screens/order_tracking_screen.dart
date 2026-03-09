import 'package:flutter/material.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/models/model/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    bool isCancelled = order.status!.toUpperCase() == OrderStatusCancelled;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Track Order', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Order ID Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColour.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text('Order #${order.id}', style: simple_text_style(fontSize: 16, fontWeight: FontWeight.bold, color: AppColour.primary), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),

            if (isCancelled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade200)),
                child: Column(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 48),
                    const SizedBox(height: 12),
                    Text('Order Cancelled', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                    const SizedBox(height: 8),
                    Text(order.cancelReason ?? 'No reason provided', textAlign: TextAlign.center, style: simple_text_style(fontSize: 14, color: Colors.red.shade900)),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                padding: const EdgeInsets.all(24),
                child: _buildStepperTimeline(order.status ?? "PENDING"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperTimeline(String currentStatus) {
    final statuses = [
      {'title': 'Order Placed', 'key': OrderStatusPlaced, 'desc': 'We have received your order'},
      {'title': 'Confirmed', 'key': OrderStatusConfirmed, 'desc': 'Order has been confirmed'},
      {'title': 'Preparing', 'key': OrderStatusPreparing, 'desc': 'Seller is packing your items'},
      {'title': 'Out for Delivery', 'key': OrderStatusDispatch, 'desc': 'Order is on the way'},
      {'title': 'Delivered', 'key': OrderStatusDeliverd, 'desc': 'Package arrived safely'},
    ];

    int currentIndex = statuses.indexWhere((s) => s['key'] == currentStatus.toUpperCase());
    if (currentIndex == -1) currentIndex = 0;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final step = statuses[index];
        final isCompleted = index <= currentIndex;
        final isActive = index == currentIndex;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Column
            Column(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? AppColour.primary : (isCompleted ? AppColour.primary : Colors.grey.shade200),
                    shape: BoxShape.circle,
                    border: isActive ? Border.all(color: AppColour.primary.withOpacity(0.3), width: 4) : null,
                  ),
                  child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                if (!isLast)
                  Container(
                    width: 2, height: 50,
                    color: isCompleted && index < currentIndex ? AppColour.primary : Colors.grey.shade200,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Text Column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24), // Matches the line height
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step['title']!, style: simple_text_style(fontSize: 16, fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500, color: isActive || isCompleted ? Colors.black87 : Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Text(step['desc']!, style: simple_text_style(fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}