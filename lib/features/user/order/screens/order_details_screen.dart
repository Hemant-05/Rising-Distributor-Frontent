import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.orderStatus);
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Order Details', style: simple_text_style(fontSize: 20)),
            const Spacer(),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Order Status & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _statusText(order.orderStatus),
                style: simple_text_style()
              ),
              Text(DateFormat('MMM d, h:mm a').format(order.createdAt),
                  style: simple_text_style(color: AppColour.grey)),
            ],
          ),
          if (order.orderStatus == 'cancelled' && order.cancellationReason != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppColour.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cancelled: ${order.cancellationReason}',
                        style: simple_text_style(color: AppColour.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 18),
          // Payment Status
          Row(
            children: [
              Icon(order.paymentMethod == "prepaid"
                  ? Icons.credit_card
                  : Icons.money,
                  color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                order.paymentMethod == "prepaid" ? "Prepaid" : "COD",
                style: simple_text_style(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 14),
              Icon(
                _paymentStatusIcon(order.paymentStatus),
                size: 18,
                color: _paymentStatusColor(order.paymentStatus),
              ),
              const SizedBox(width: 5),
              Text(
                _paymentStatusText(order.paymentStatus),
                style: simple_text_style(
                    color: _paymentStatusColor(order.paymentStatus),
                    fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 32),
          // Items List
          Text('Items', style: simple_text_style(fontWeight: FontWeight.bold,fontSize: 18)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (context, i) {
              final product = order.items[i];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl : product["image"] ?? "",
                      width: 48, height: 48, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      product["name"] ?? "Unknown",
                      style: simple_text_style(),
                    ),
                  ),
                  Text("x${product["quantity"]}", style: simple_text_style(color: AppColour.grey)),
                ],
              );
            },
          ),
          const Divider(height: 12),
          // Price Details
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Order Summary', style: simple_text_style(fontWeight: FontWeight.bold,fontSize: 18),
            ),
          ),
          _orderSummaryRow("Subtotal", order.subtotal.toStringAsFixed(1)),
          _orderSummaryRow("Delivery Fee", '0' == order.deliveryFee.toStringAsFixed(0)? 'Free' : order.deliveryFee.toStringAsFixed(0)),
          _orderSummaryRow("Platform Fee", platformFee.toStringAsFixed(0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: simple_text_style(fontWeight: FontWeight.bold,fontSize: 18)),
              Text("₹${order.total.toStringAsFixed(2)}",
                  style: simple_text_style(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30),
          // Address
          Text('Delivery Address', style: simple_text_style(fontWeight: FontWeight.bold,fontSize: 18)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
                color: Colors.grey[100], borderRadius: BorderRadius.circular(7)),
            child: Text(
              order.address.streetAddress,  // make sure your DeliveryAddress has a `fullAddress` getter
              style: simple_text_style(),
            ),
          ),
          // Transaction & timestamps (optional)
          if (order.transactionId != null)
            _keyValueRow("Transaction ID", order.transactionId!),
          if (order.paidAt != null)
            _keyValueRow("Paid At", DateFormat('MMM d, h:mm a').format(order.paidAt!)),
          if (order.deliveredAt != null)
            _keyValueRow("Delivered At", DateFormat('MMM d, h:mm a').format(order.deliveredAt!)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- UI Helpers ---
  Widget _orderSummaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: simple_text_style()),
        Text(value, style: simple_text_style(fontSize: 14,color: AppColour.grey)),
      ],
    ),
  );

  Widget _keyValueRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text("$label: ", style: simple_text_style(fontSize: 13),),
          Expanded(child: Text(value, style: simple_text_style(fontSize: 13),)),
        ],
      ));
}

// --- Helper utils for status/icons/text/colors ---
String _statusText(String s) {
  switch (s) {
    case OrderStatusCreated : return "Order Placed At";
    case OrderStatusConfirmed : return "Order Confirmed";
    case OrderStatusPreparing : return "Preparing";
    case OrderStatusDispatch : return "Out For Delivery";
    case OrderStatusDeliverd : return "Delivered";
    case OrderStatusCancelled : return "Cancelled";
    default: return s;
  }
}

Color _statusColor(String s) {
  switch (s) {
    case OrderStatusDeliverd : return Colors.green;
    case OrderStatusCancelled : return Colors.red;
    case OrderStatusPreparing : return Colors.orange;
    case OrderStatusDispatch : return Colors.blue;
    case OrderStatusConfirmed : return Colors.teal;
    default: return Colors.grey;
  }
}

IconData _paymentStatusIcon(String s) {
  switch (s) {
    case PayStatusPaid : return Icons.check_circle;
    case PayStatusPending : return Icons.hourglass_empty;
    case PayStatusFailed : return Icons.cancel;
    case PayStatusRefunded : return Icons.refresh;
    default: return Icons.info;
  }
}

Color _paymentStatusColor(String s) {
  switch (s) {
    case PayStatusPaid : return Colors.green;
    case PayStatusPending : return Colors.orange;
    case PayStatusFailed : return Colors.red;
    case PayStatusRefunded : return Colors.blueGrey;
    default: return Colors.grey;
  }
}

String _paymentStatusText(String s) {
  switch (s) {
    case PayStatusPaid : return "Paid";
    case PayStatusPending : return "Pending";
    case PayStatusFailed : return "Failed";
    case PayStatusRefunded : return "Refunded";
    default: return s;
  }
}
