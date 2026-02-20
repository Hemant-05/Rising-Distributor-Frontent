import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/models/model/order.dart';
import 'package:raising_india/models/model/order_item.dart';

import 'screens/admin_order_details_screen.dart';

class AdminOrderCard extends StatelessWidget {
  final Order order;
  final bool showTime;
  final bool isRunning;

  const AdminOrderCard({
    super.key,
    required this.order,
    this.showTime = false,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    final order = this.order;
    final items = this.order.orderItems;

    return Card(
      margin: EdgeInsets.zero,
      color: AppColour.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminOrderDetailScreen(
                order: this.order,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id!.toString()}',
                    style: simple_text_style(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        order.status!,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(order.status!),
                      ),
                    ),
                    child: Text(
                      _getStatusText(order.status!),
                      style: simple_text_style(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Items Row
              Row(
                children: [
                  _buildItemImages(items!),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _buildItemsText(items),
                          style: simple_text_style(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${items.length} items • ₹${order.totalPrice!.toStringAsFixed(0)}',
                          style: simple_text_style(
                            color: AppColour.lightGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Status Row
              Row(
                children: [
                  // Payment Status
                  _buildStatusChip(
                    icon: _getPaymentIcon(order.payment!.paymentStatus!),
                    label: _getPaymentText(order.payment!.paymentStatus!),
                    color: _getPaymentColor(order.payment!.paymentStatus!),
                  ),
                  const SizedBox(width: 8),

                  // Payment Method
                  _buildStatusChip(
                    icon: order.payment?.paymentMethod == 'prepaid'
                        ? Icons.credit_card
                        : Icons.money,
                    label: order.payment?.paymentMethod == 'prepaid' ? 'Prepaid' : 'COD',
                    color: Colors.blue,
                  ),

                  const Spacer(),

                  // Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showTime) ...[
                        Text(
                          DateFormat('h:mm a').format(order.createdAt!),
                          style: simple_text_style(
                            fontSize: 14,
                            color: AppColour.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d').format(order.createdAt!),
                          style: simple_text_style(
                            fontSize: 12,
                            color: AppColour.grey,
                          ),
                        ),
                      ] else ...[
                        Text(
                          DateFormat('MMM d, h:mm a').format(order.createdAt!),
                          style: simple_text_style(
                            fontSize: 12,
                            color: AppColour.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImages(List<OrderItem> items) {
    final imagesToShow = items.take(4).toList();

    return SizedBox(
      width: 60,
      height: 60,
      child: imagesToShow.length == 1
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imagesToShow.first.product?.photosList!.first ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            )
          : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: imagesToShow.length,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  imagesToShow[i].product?.photosList!.first ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.fastfood,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: simple_text_style(fontSize: 12)),
        ],
      ),
    );
  }

  String _buildItemsText(List<OrderItem> items) {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) return items.first.product?.name ?? 'Unknown item';
    if (items.length == 2) {
      return '${items[0].product?.name ?? 'Item'}, ${items[1].product?.name ?? 'Item'}';
    }
    return '${items[0].product?.name ?? 'Item'}, ${items[1].product?.name ?? 'Item'} +${items.length - 2} more';
  }

  // Helper methods for status colors and text
  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'dispatched':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'confirmed':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'created':
        return 'Placed';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'dispatched':
        return 'Dispatched';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  IconData _getPaymentIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.cancel;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.info;
    }
  }

  Color _getPaymentColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
}
