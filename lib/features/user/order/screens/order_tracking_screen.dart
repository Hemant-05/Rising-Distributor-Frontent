import 'package:flutter/material.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/models/model/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order order; // Pass full object

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Track Order', style: simple_text_style(fontSize: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Timeline
          _buildStatusTimeline(order.status ?? "PENDING"),

          // Payment Info Card
          Card(
            color: AppColour.white,
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: Icon(
                _getPaymentIcon(order.payment?.paymentMethod ?? ""),
                color: Colors.green,
              ),
              title: Text('Payment Method', style: simple_text_style()),
              subtitle: Text(
                (order.payment?.paymentMethod ?? "Unknown").toUpperCase(),
                style: simple_text_style(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final statuses = [
      'PENDING',
      'CONFIRMED',
      'PREPARING', // Optional, depends on your backend enums
      'SHIPPED',
      'DELIVERED',
    ];

    // Simple index mapping
    int currentIndex = statuses.indexOf(currentStatus.toUpperCase());
    if (currentIndex == -1) currentIndex = 0; // Default

    return Card(
      color: AppColour.white,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status: $currentStatus',
              style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Draw Timeline
            ...List.generate(statuses.length, (index) {
              final status = statuses[index];
              final isCompleted = index <= currentIndex;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                      ),
                      if (index < statuses.length - 1)
                        Container(
                          width: 2, height: 30,
                          color: isCompleted ? Colors.green : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    status,
                    style: simple_text_style(
                      color: isCompleted ? Colors.black : Colors.grey,
                      fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    if (method.toLowerCase().contains('cod')) return Icons.money;
    return Icons.credit_card;
  }
}