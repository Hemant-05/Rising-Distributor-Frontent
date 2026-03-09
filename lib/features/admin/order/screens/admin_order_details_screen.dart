import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/data/services/admin_service.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/models/model/order.dart';
import 'package:raising_india/models/model/order_item.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Order order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late String currentOrderStatus;
  late String currentPaymentStatus;
  late int orderId = widget.order.id!;
  late Order order = widget.order;
  late bool payIsPending = true;
  late bool orderIsRunning = true;
  bool isUpdating = false;
  final TextEditingController _cancelController = TextEditingController();

  final List<Map<String, dynamic>> orderStatusStages = [
    {
      'key': OrderStatusPlaced,
      'label': 'Placed',
      'icon': Icons.receipt_outlined,
    },
    {
      'key': OrderStatusConfirmed,
      'label': 'Confirmed',
      'icon': Icons.check_circle_outline,
    },
    {
      'key': OrderStatusPreparing,
      'label': 'Preparing',
      'icon': Icons.kitchen_outlined,
    },
    {
      'key': OrderStatusDispatch,
      'label': 'Dispatched',
      'icon': Icons.local_shipping_outlined,
    },
    {
      'key': OrderStatusDeliverd,
      'label': 'Delivered',
      'icon': Icons.done_all
    },
  ];

  @override
  void initState() {
    super.initState();
    currentOrderStatus = widget.order.status!;
    currentPaymentStatus = widget.order.payment!.paymentStatus!;
  }

  int get currentStatusIndex {
    return orderStatusStages.indexWhere(
      (stage) => stage['key'] == currentOrderStatus,
    );
  }

  bool canAdvanceToStatus(int targetIndex) {
    return targetIndex == currentStatusIndex + 1 &&
        targetIndex < orderStatusStages.length;
  }

  // Function to launch Google Maps with coordinates
  Future<void> _openGoogleMaps(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location coordinates not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Multiple URL formats for better compatibility
    final List<String> mapUrls = [
      // Google Maps app URL (preferred)
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      // Alternative Google Maps URL
      'https://maps.google.com/?q=$latitude,$longitude',
      // Geo URL for generic map apps
      'geo:$latitude,$longitude',
    ];

    bool launched = false;

    for (String url in mapUrls) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external app
        );
        if (launched) break;
      }
    }

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps application'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to show location options dialog
  void _showLocationOptions(Order order) {
    showModalBottomSheet(
      backgroundColor: AppColour.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Location Options',
              style: simple_text_style(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.map_outlined, color: Colors.blue),
              title: Text('Open in Google Maps', style: simple_text_style()),
              subtitle: Text(
                'Navigate to delivery location',
                style: simple_text_style(),
              ),
              onTap: () {
                Navigator.pop(context);
                _openGoogleMaps(
                  order.address!.latitude,
                  order.address!.longitude,
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.copy_outlined, color: Colors.green),
              title: Text('Copy Address', style: simple_text_style()),
              subtitle: Text(
                'Copy address to clipboard',
                style: simple_text_style(),
              ),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(
                  ClipboardData(text: order.address!.streetAddress!),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Address copied to clipboard',
                      style: simple_text_style(),
                    ),
                  ),
                );
              },
            ),

            if (order.address!.phoneNumber!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.phone_outlined, color: Colors.orange),
                title: Text('Call Customer', style: simple_text_style()),
                subtitle: Text(
                  order.address!.phoneNumber!,
                  style: simple_text_style(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _launchPhone(order.address!.phoneNumber);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() => isUpdating = true);

    try {
      await context.read<AdminService>().updateOrderStatus(
        order.id!,
        newStatus,
      );
      setState(() => currentOrderStatus = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order status updated to ${_getStatusLabel(newStatus)},',
            style: simple_text_style(color: AppColour.white),
          ),
          backgroundColor: AppColour.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update order status: $e',
            style: simple_text_style(color: AppColour.white),
          ),
          backgroundColor: AppColour.red,
        ),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> _updatePaymentStatus(String targetStatus) async {
    setState(() => isUpdating = true);

    try {
      final adminService = context.read<AdminService>();

      // Route the request to the correct backend method based on the status
      if (targetStatus == PayStatusPaid || targetStatus == PayStatusFailed) {
        await adminService.updatePayment(orderId, targetStatus);
      } else if (targetStatus == PayStatusRefunded) {
        await adminService.refundOrder(orderId);
      }

      // If successful, update the UI instantly
      setState(() {
        currentPaymentStatus = targetStatus;
        widget.order.payment!.paymentStatus = targetStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment marked as $targetStatus', style: simple_text_style(color: AppColour.white)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update payment: $e', style: simple_text_style(color: AppColour.white)),
          backgroundColor: AppColour.red,
        ),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  void _shareOrderDetails() {
    final order = widget.order;
    String shareContent = '';
    shareContent += '📦 Order ID: #${order.id!.toString()}\n\n';
    shareContent +=
        '🧑🏻 Name : ${order.address!.recipientName ?? 'Unknown User'}\n\n';
    shareContent += '📱 Contact: ${order.address!.phoneNumber}\n\n';
    shareContent +=
        '🏡 Address:https://www.google.com/maps/search/?api=1&query=${order.address!.latitude},${order.address!.longitude}\n\n';
    shareContent +=
        '💰 Payment Status: ${_getStatusLabel(order.payment!.paymentStatus!)}\n\n';
    shareContent +=
        '💵 Total Amount: ₹${order.totalPrice!.toStringAsFixed(2)}\n\n';
    shareContent +=
        '📅 Order Date: ${DateFormat('MMM d, yyyy • h:mm a').format(order.createdAt!)}\n\n';
    Share.share(
      shareContent,
      subject: 'Order Details - #${order.id!.toString()}',
    );
  }

  void _launchPhone(String? phone) async {
    if (phone != null && phone.isNotEmpty) {
      final Uri uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  String _getStatusLabel(String status) {
    final stage = orderStatusStages.firstWhere(
      (stage) => stage['key'] == status,
      orElse: () => {'label': status},
    );
    return stage['label'];
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final products = widget.order.orderItems;

    return Consumer<AdminService>(
      builder: (context, adminService, _) {
        if (adminService.isLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (adminService.dashboardStats == null) {
          return Scaffold(body: Center(child: Text('Some Error.....')));
        }
        return Scaffold(
          backgroundColor: AppColour.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColour.white,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                back_button(),
                SizedBox(width: 8),
                Text(
                  'Order #${order.id!.toString()}',
                  style: simple_text_style(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_rounded, color: AppColour.primary),
                onPressed: _shareOrderDetails,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Info Card
                _buildOrderInfoCard(order),
                const SizedBox(height: 16),

                // Products Section
                _buildProductsSection(products!),
                const SizedBox(height: 16),

                // Customer Details Section
                _buildCustomerDetailsSection(order),
                const SizedBox(height: 16),

                // Order Status Section
                _buildOrderStatusSection(),
                const SizedBox(height: 16),

                // Cancel Order Status Section
                if (currentOrderStatus.toUpperCase() != OrderStatusCancelled &&
                    currentOrderStatus.toUpperCase() != OrderStatusDeliverd) ...{
                  _cancelOrderStatus(),
                  const SizedBox(height: 16),
                },

                // Payment Status Section
                _buildPaymentStatusSection(),
                const SizedBox(height: 16),

                // Total Section
                _buildTotalSection(order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderInfoCard(Order order) {
    return Card(
      color: AppColour.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Date',
                      style: simple_text_style(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColour.grey,
                      ),
                    ),
                    Text(
                      DateFormat('d/MM/yy • h:mm a').format(order.createdAt!),
                      style: simple_text_style(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order.payment?.paymentMethod == 'prepaid'
                        ? Colors.blue.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.payment?.paymentMethod == 'prepaid'
                        ? 'PREPAID'
                        : 'CASH ON DELIVERY',
                    style: simple_text_style(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: order.payment?.paymentMethod == 'prepaid'
                          ? Colors.blue.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection(List<OrderItem> products) {
    return Card(
      elevation: 2,
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: AppColour.primary),
                const SizedBox(width: 8),
                Text(
                  'Order Items',
                  style: simple_text_style(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final item = products[index];
                final product = item.product;

                return Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product?.photosList!.isNotEmpty == true
                            ? product!.photosList!.first
                            : '',
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
                    ),
                    const SizedBox(width: 12),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.name ?? 'Unknown Product',
                            style: simple_text_style(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product?.quantity} ${product?.measurement ?? ''}',
                            style: simple_text_style(
                              fontSize: 12,
                              color: AppColour.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColour.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Qty: ${item.quantity}',
                                  style: simple_text_style(
                                    fontSize: 12,
                                    color: AppColour.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₹${(product?.price ?? 0).toStringAsFixed(2)}',
                                style: simple_text_style(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetailsSection(Order order) {
    final hasCoordinates = order.address!.longitude != null;

    return Card(
      color: AppColour.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  'Customer Details',
                  style: simple_text_style(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User Name
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address!.recipientName ?? 'Unknown User',
                    style: simple_text_style(),
                  ),
                ),
              ],
            ),

            // Phone Number
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address!.phoneNumber ?? 'Unknown Number',
                    style: simple_text_style(),
                  ),
                ),
                IconButton(
                  onPressed: () => _launchPhone(order.address!.phoneNumber!),
                  icon: Icon(Icons.call, color: Colors.green.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Delivery Address with Map Integration
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: simple_text_style(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),

                      // Clickable Address
                      InkWell(
                        onTap: hasCoordinates
                            ? () => _openGoogleMaps(
                                order.address!.latitude,
                                order.address!.longitude,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: hasCoordinates
                                  ? Colors.blue.shade300
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: hasCoordinates
                                ? Colors.blue.shade50
                                : Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.address!.streetAddress!,
                                style: simple_text_style(
                                  color: hasCoordinates
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              if (hasCoordinates) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.map_outlined,
                                      size: 14,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Tap to open in Google Maps',
                                      style: simple_text_style(
                                        color: Colors.blue.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action Buttons Row
                      Row(
                        children: [
                          // Map Button
                          if (hasCoordinates)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _openGoogleMaps(
                                  order.address!.latitude,
                                  order.address!.longitude,
                                ),
                                icon: const Icon(Icons.map_outlined, size: 18),
                                label: Text('Open Map',style: simple_text_style(),),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue.shade600,
                                  side: BorderSide(color: Colors.blue.shade300),
                                ),
                              ),
                            ),

                          if (hasCoordinates) const SizedBox(width: 8),

                          // More Options Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showLocationOptions(order),
                              icon: const Icon(Icons.more_horiz, size: 18),
                              label: Text('Options',style: simple_text_style(),),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange.shade600,
                                side: BorderSide(color: Colors.orange.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 1. Updated Cancel Section UI & Logic
  Widget _cancelOrderStatus() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColour.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cancel_outlined, color: AppColour.red),
                const SizedBox(width: 8),
                Text(
                  'Cancel This Order',
                  style: simple_text_style(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cancelController,
                    decoration: InputDecoration(
                      hintText: 'Enter cancellation reason...',
                      hintStyle: simple_text_style(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColour.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isUpdating ? null : () async {
                      String reason = _cancelController.text.trim();
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text('Please enter a reason to cancel the order'), backgroundColor: AppColour.red),
                        );
                        return;
                      }

                      setState(() => isUpdating = true);
                      try {
                        // ✅ Make the actual API call
                        await context.read<OrderService>().cancelOrder(orderId, reason);

                        setState(() {
                          currentOrderStatus = OrderStatusCancelled; // Force UI update
                          widget.order.status = OrderStatusCancelled;
                          widget.order.payment!.paymentStatus = PayStatusRefunding;
                          // Assuming you added cancelReason to your Flutter Order model
                          widget.order.cancelReason = reason;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order Cancelled Successfully'), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: AppColour.red),
                        );
                      } finally {
                        setState(() => isUpdating = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColour.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isUpdating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Cancel', style: simple_text_style(color: AppColour.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // ✅ Pst this method inside your State class
  Widget _buildTimeline() {
    return Column(
      children: orderStatusStages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        final isCompleted = index <= currentStatusIndex;
        final isCurrent = index == currentStatusIndex;
        final canAdvance = canAdvanceToStatus(index);

        return GestureDetector(
          onTap: canAdvance && !isUpdating
              ? () => _updateOrderStatus(stage['key'])
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                // Timeline indicator
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.orange.shade600
                            : canAdvance
                            ? Colors.orange.shade200
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(
                          color: Colors.orange.shade600,
                          width: 3,
                        )
                            : null,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : stage['icon'],
                        color: isCompleted
                            ? Colors.white
                            : canAdvance
                            ? Colors.orange.shade600
                            : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    if (index < orderStatusStages.length - 1)
                      Container(
                        width: 2,
                        height: 20,
                        color: isCompleted
                            ? Colors.orange.shade600
                            : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Status label
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage['label'],
                          style: simple_text_style(
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 16,
                            color: isCompleted ? Colors.black : Colors.grey.shade600,
                          ),
                        ),
                        if (canAdvance)
                          Text(
                            'Tap to update',
                            style: simple_text_style(
                              fontSize: 12,
                              color: AppColour.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Loading indicator
                if (isUpdating && canAdvance)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColour.primary,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  // ✅ 2. Updated Order Status Section to show the reason if cancelled
  Widget _buildOrderStatusSection() {
    // Normalize string to match backend
    final safeStatus = currentOrderStatus.toUpperCase();

    orderIsRunning = safeStatus != OrderStatusDeliverd && safeStatus != OrderStatusCancelled;

    return Card(
      elevation: 2,
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text('Order Status', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (!orderIsRunning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: safeStatus == OrderStatusDeliverd ? Colors.green.withOpacity(0.15) : AppColour.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      safeStatus,
                      style: simple_text_style(
                        fontWeight: FontWeight.bold,
                        color: safeStatus == OrderStatusDeliverd ? Colors.green.shade700 : AppColour.red,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // If running, show timeline. If finished, show conclusion.
            orderIsRunning
                ? _buildTimeline() // (Your existing timeline mapping logic goes here)
                : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    safeStatus == OrderStatusCancelled
                        ? '❌ Order was Cancelled'
                        : '✅ Delivered Successfully',
                    style: simple_text_style(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: safeStatus == OrderStatusCancelled ? AppColour.red : Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Show the date
                  Text(
                    'At: ${DateFormat('MMM d, yyyy • h:mm a').format(widget.order.createdAt ?? DateTime.now())}',
                    style: simple_text_style(color: Colors.grey.shade700),
                  ),

                  // ✅ Show Cancel Reason if available!
                  if (safeStatus == OrderStatusCancelled && widget.order.cancelReason != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColour.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColour.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: AppColour.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reason: ${widget.order.cancelReason}',
                              style: simple_text_style(color: AppColour.red, fontWeight: FontWeight.w500,isEllipsisAble: false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusSection() {
    // Normalize to uppercase to avoid case-sensitivity bugs
    final safePaymentStatus = currentPaymentStatus.toUpperCase();
    final bool isPending = safePaymentStatus == PayStatusPending;

    return Card(
      color: AppColour.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_outlined, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  'Payment Status',
                  style: simple_text_style(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),

                // --- STATUS PILL ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: safePaymentStatus == PayStatusPaid || safePaymentStatus == PayStatusRefunded
                        ? Colors.green.withOpacity(0.15)
                        : safePaymentStatus == PayStatusPending
                        ? AppColour.primary.withOpacity(0.15)
                        : safePaymentStatus == PayStatusRefunding
                        ? Colors.orange.withOpacity(0.15)
                        : AppColour.red.withOpacity(0.15), // Failed or Cancelled
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    safePaymentStatus,
                    style: simple_text_style(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: safePaymentStatus == PayStatusPaid || safePaymentStatus == PayStatusRefunded
                          ? Colors.green.shade700
                          : safePaymentStatus == PayStatusPending
                          ? AppColour.primary
                          : safePaymentStatus == PayStatusRefunding
                          ? Colors.orange.shade800
                          : AppColour.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- DYNAMIC ACTION CHIPS ---

            // Scenario A: Order is PENDING. Admin can mark as Paid (e.g., received cash) or Failed.
            if (isPending)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPaymentStatusChip(PayStatusPaid, 'Mark as Paid', Colors.green),
                  _buildPaymentStatusChip(PayStatusFailed, 'Mark as Failed', Colors.red),
                ],
              ),

            // Scenario B: Order was cancelled by Admin/User, and backend automatically set payment to REFUNDING.
            // Now the admin processes the refund in the bank, and clicks this to close the loop.
            if (safePaymentStatus == PayStatusRefunding)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPaymentStatusChip(PayStatusRefunded, 'Mark as Refunded', Colors.blue),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ✅ 4. The Updated Chip Builder
  Widget _buildPaymentStatusChip(String targetStatus, String label, Color color) {
    return GestureDetector(
      onTap: isUpdating ? null : () => _updatePaymentStatus(targetStatus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1),
        ),
        child: isUpdating
            ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(targetStatus == PayStatusPaid ? Icons.check_circle : targetStatus == PayStatusFailed ? Icons.cancel : Icons.autorenew, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: simple_text_style(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(Order order) {

    return Card(
      color: AppColour.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: simple_text_style(fontSize: 16)),
                Text(
                  '₹${(order.totalPrice! - order.deliveryFee - platformFee).toStringAsFixed(2)}', // @ sub total price
                  style: simple_text_style(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Fee:', style: simple_text_style(fontSize: 16)),
                Text(
                  (order.deliveryFee == 0)? "Free" : '₹${order.deliveryFee.toStringAsFixed(2)}', // @ Delivery fee
                  style: simple_text_style(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Platform Fee:', style: simple_text_style(fontSize: 16)),
                Text(
                  '₹$platformFee', // @ Delivery fee
                  style: simple_text_style(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Coupon (${order.couponCode}) :', style: simple_text_style(fontSize: 16,color: AppColour.red))),
                Text(
                  '-₹${order.discountAmount!.toStringAsFixed(2)}', // @ Delivery fee
                  style: simple_text_style(fontSize: 16, color: AppColour.red),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: simple_text_style(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${order.totalPrice!.toStringAsFixed(2)}', // @ total price
                  style: simple_text_style(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
