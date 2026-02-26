import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/notification_service.dart';
import 'package:raising_india/models/model/notification.dart';

class NotificationScreenA extends StatefulWidget {
  const NotificationScreenA({super.key});

  @override
  State<NotificationScreenA> createState() => _NotificationScreenAState();
}

class _NotificationScreenAState extends State<NotificationScreenA> {

  @override
  void initState() {
    super.initState();
    // Fetch fresh notifications from the backend when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().fetchAdminNotifications();
    });
  }

  // ✅ Helper to assign correct icons based on the backend 'type' string
  IconData _iconFor(String? type) {
    switch (type) {
      case 'order_placed':
        return Icons.shopping_bag_outlined;
      case 'order_confirmed':
      case 'order_preparing':
        return Icons.local_dining_outlined;
      case 'out_for_delivery':
        return Icons.local_shipping_outlined;
      case 'order_delivered':
        return Icons.check_circle_outlined;
      case 'order_cancelled':
      case 'order_cancelled_admin':
        return Icons.cancel_outlined;
      case 'payment_success':
        return Icons.payments_outlined;
      case 'payment_failed':
        return Icons.report_gmailerrorred_outlined;
      case 'payment_refund':
        return Icons.autorenew_outlined;
      case 'new_order_admin':
        return Icons.admin_panel_settings_outlined;
      case 'low_stock_alert':
        return Icons.inventory_2_outlined;
      case 'BROADCAST':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  // ✅ Helper to format the ISO time string into human-readable text
  String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';

    try {
      final dt = DateTime.parse(isoString);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Notifications', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: AppColour.white,
        elevation: 0,
        actions: [
          // ✅ Optional: A button to mark all as read (if you add that to your backend later)
          Consumer<NotificationService>(
            builder: (context, service, _) {
              if (service.unreadCount > 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      '${service.unreadCount} Unread',
                      style: simple_text_style(color: AppColour.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, _) {

          // 1. Loading State
          if (notificationService.isLoading && notificationService.notifications.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }

          // 2. Empty State
          if (notificationService.notifications.isEmpty) {
            return RefreshIndicator(
              color: AppColour.primary,
              onRefresh: () => notificationService.fetchAdminNotifications(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  _EmptyState(onBrowse: () {}), // No need for onBrowse function here anymore
                ],
              ),
            );
          }

          // 3. Loaded State
          return RefreshIndicator(
            color: AppColour.primary,
            onRefresh: () => notificationService.fetchAdminNotifications(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notificationService.notifications.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final NotificationModel notif = notificationService.notifications[index];
                final bool isUnread = !notif.isRead;

                return InkWell(
                  onTap: () {
                    if (isUnread) {
                      notificationService.markAsRead(notif.id!);
                    }
                    // TODO: Implement navigation based on notif.type later
                    // e.g., if (notif.type == 'new_order_admin') navigate to Order Details
                  },
                  child: Container(
                    color: isUnread ? Colors.blue.withOpacity(0.05) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Bubble
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isUnread ? AppColour.primary.withOpacity(0.15) : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _iconFor(notif.type),
                            color: isUnread ? AppColour.primary : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title ?? 'Alert',
                                      style: simple_text_style(
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 16,
                                        color: isUnread ? Colors.black : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTime(notif.createdAt),
                                    style: simple_text_style(
                                      color: isUnread ? AppColour.primary : Colors.grey.shade500,
                                      fontSize: 12,
                                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif.message ?? '',
                                style: simple_text_style(
                                  fontSize: 14,
                                  color: isUnread ? Colors.black87 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Unread Indicator Dot
                        if (isUnread) ...[
                          const SizedBox(width: 12),
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColour.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ✅ Extracted Empty State Widget
class _EmptyState extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyState({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
                'No notifications yet',
                style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)
            ),
            const SizedBox(height: 8),
            Text(
              'Orders, alerts, and system broadcasts will appear here when you receive them.',
              textAlign: TextAlign.center,
              style: simple_text_style(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}