import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/models/model/order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Important for cards to pop
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColour.white,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Order Details', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatusHeaderCard(),
          const SizedBox(height: 16),
          _buildItemsCard(),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildDeliveryAddressCard(),
          const SizedBox(height: 24),

          // ✅ New Download Invoice Button
          if (order.status != 'CANCELLED')
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColour.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.download, color: AppColour.primary),
                label: Text("Download Invoice", style: simple_text_style(color: AppColour.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloading invoice...")));
                  final msg = await context.read<OrderService>().downloadInvoice(order.id!);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg ?? "Download failed")));
                },
              ),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- Card Widgets ---
  Widget _buildStatusHeaderCard() {
    bool isCancelled = order.status == 'CANCELLED';
    return Container(
      decoration: BoxDecoration(color: AppColour.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order.id}', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor(order.status!).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(order.status!, style: simple_text_style(color: _statusColor(order.status!), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(DateFormat('MMM d, yyyy | h:mm a').format(order.createdAt!), style: simple_text_style(color: Colors.grey.shade500, fontSize: 13)),

          if (isCancelled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Reason: ${order.cancelReason}', style: simple_text_style(color: Colors.red.shade700, fontSize: 13))),
                ],
              ),
            ),
          ],
          const Divider(height: 32),
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: Icon(order.payment?.paymentMethod == "prepaid" ? Icons.credit_card : Icons.money, color: Colors.grey.shade700, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Payment Info", style: simple_text_style(color: Colors.grey.shade500, fontSize: 12)),
                    Text(order.payment?.paymentMethod == "prepaid" ? "Paid Online" : "Cash on Delivery", style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Status", style: simple_text_style(color: Colors.grey.shade500, fontSize: 12)),
                  Text(_paymentStatusText(order.payment?.paymentStatus ?? ""), style: simple_text_style(color: _paymentStatusColor(order.payment?.paymentStatus ?? ""), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      decoration: BoxDecoration(color: AppColour.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Items', style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.orderItems!.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, i) {
              final product = order.orderItems![i].product;
              return Row(
                children: [
                  Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(imageUrl: product!.photosList!.isNotEmpty ? product.photosList![0] : "", fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name ?? "Unknown", style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text("Qty: ${order.orderItems![i].quantity}", style: simple_text_style(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text("Price: ${order.orderItems![i].orderedPrice}", style: simple_text_style(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text("₹${(product.price! * order.orderItems![i].quantity!).toStringAsFixed(0)}", style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(color: AppColour.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bill Details', style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _row("Item Total", "₹${(order.totalPrice! - platformFee - order.deliveryFee).toStringAsFixed(2)}"),
          _row("Delivery Fee", (order.deliveryFee == 0)? "Free" : "₹${order.deliveryFee.toStringAsFixed(2)}"),
          _row("Platform Fee", "₹${platformFee.toStringAsFixed(2)}"),
          if (order.discountAmount != null && order.discountAmount! > 0)
            _row("Coupon Discount (${order.couponCode})", "-₹${order.discountAmount!.toStringAsFixed(2)}", color: Colors.green),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹${order.totalPrice!.toStringAsFixed(2)}", style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 18, color: AppColour.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Container(
      decoration: BoxDecoration(color: AppColour.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColour.primary, size: 20),
              const SizedBox(width: 8),
              Text('Delivery Address', style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.address?.streetAddress ?? "No address provided", style: simple_text_style(color: Colors.grey.shade700, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ✅ Wrap the label in an Expanded widget
        Expanded(
          child: Text(
            label,
            style: simple_text_style(color: Colors.grey.shade600),
            // ✅ Add these two lines to handle the cutoff gracefully
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        // Add a tiny bit of spacing so the label and value don't touch if it gets long
        const SizedBox(width: 12),

        Text(
            value,
            style: simple_text_style(fontWeight: FontWeight.bold, color: color ?? Colors.black87)
        ),
      ],
    ),
  );


// Helper Enums
Color _statusColor(String s) {
  if (s == 'DELIVERED') return Colors.green;
  if (s == 'CANCELLED') return Colors.red;
  if (s == 'PREPARING') return Colors.orange;
  if (s == 'DISPATCH') return Colors.blue;
  return Colors.teal;
}

Color _paymentStatusColor(String s) {
  if (s == 'PAID') return Colors.green;
  if (s == 'PENDING') return Colors.orange;
  if (s == 'FAILED') return Colors.red;
  return Colors.blueGrey;
}
String _paymentStatusText(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;}