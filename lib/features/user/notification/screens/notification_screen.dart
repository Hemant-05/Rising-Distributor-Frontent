import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Safely fetch the user ID without crashing if the user is null
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customer = context.read<AuthService>().customer;
      if (customer != null && customer.uid != null) {
        context.read<NotificationService>().fetchUserNotifications(customer.uid!);
      }
    });
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'order_placed': return Icons.shopping_bag_outlined;
      case 'order_confirmed': return Icons.thumb_up_outlined;
      case 'out_for_delivery': return Icons.local_shipping_outlined;
      case 'order_delivered': return Icons.check_circle_outlined;
      case 'order_cancelled': return Icons.cancel_outlined;
      case 'payment_success': return Icons.payments_outlined;
      case 'BROADCAST': return Icons.campaign_outlined;
      default: return Icons.notifications_none_outlined;
    }
  }

  Color _colorFor(String? type) {
    switch (type) {
      case 'order_placed': return AppColour.primary;
      case 'out_for_delivery': return Colors.blue;
      case 'order_delivered': return Colors.green;
      case 'order_cancelled': return Colors.red;
      case 'payment_success': return Colors.green.shade700;
      case 'BROADCAST': return Colors.orange;
      default: return AppColour.primary;
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString);
      final diff = DateTime.now().difference(dt);
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
      ),
      body: Consumer<NotificationService>(
        builder: (context, notifService, _) {

          if (notifService.isLoading && notifService.notifications.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }

          if (notifService.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                    ),
                    const SizedBox(height: 16),
                    Text(
                        "You're all caught up!",
                        style: simple_text_style(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Updates about your orders and special offers will appear here.",
                      textAlign: TextAlign.center,
                      style: simple_text_style(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            backgroundColor: AppColour.white,
            color: AppColour.primary,
            // ✅ Fetch the user ID directly from AuthService on pull-to-refresh
            onRefresh: () async {
              final customer = context.read<AuthService>().customer;
              if (customer != null && customer.uid != null) {
                await notifService.fetchUserNotifications(customer.uid!);
              }
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              itemCount: notifService.notifications.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200, indent: 80),
              itemBuilder: (context, index) {
                final notif = notifService.notifications[index];
                final iconColor = _colorFor(notif.type);
                final bool isUnread = !notif.read;

                return InkWell(
                  onTap: () {
                    if (isUnread) {
                      notifService.markAsRead(notif.id!);
                    }
                  },
                  child: Container(
                    color: isUnread ? Colors.blue.withOpacity(0.05) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Icon Bubble
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_iconFor(notif.type), color: iconColor),
                        ),
                        const SizedBox(width: 16),

                        // 2. Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                        notif.title ?? '',
                                        style: simple_text_style(
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                          fontSize: 15,
                                          color: isUnread ? Colors.black : Colors.black87,
                                        )
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      _formatTime(notif.createdAt),
                                      style: simple_text_style(
                                        fontSize: 12,
                                        color: isUnread ? AppColour.primary : Colors.grey.shade500,
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                      )
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  notif.message ?? '',
                                  style: simple_text_style(
                                    color: isUnread ? Colors.black87 : Colors.grey.shade600,
                                    fontSize: 13,
                                  )
                              ),
                            ],
                          ),
                        ),

                        // 3. Unread Indicator Dot
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