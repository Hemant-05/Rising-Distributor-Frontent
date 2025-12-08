import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'dart:async';

class NotificationScreenA extends StatefulWidget {
  const NotificationScreenA({super.key});

  @override
  State<NotificationScreenA> createState() => _NotificationScreenAState();
}

class _NotificationScreenAState extends State<NotificationScreenA> {
  final _pageSize = 20;
  // TODO: Replace with a mechanism to store the last fetched item for pagination from your backend
  dynamic _last;
  bool _loading = false;
  bool _done = false;
  final List<Map<String, dynamic>> _docs = []; // Changed to a generic list of maps

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _done) return;
    setState(() => _loading = true);

    // TODO: Replace with logic to get user ID from your custom authentication system
    final userId = "admin_user_id"; // Placeholder user ID

    // TODO: Implement fetching notifications from your custom backend
    // This is a placeholder for your backend API call
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final List<Map<String, dynamic>> fetchedNotifications = [
      // Example dummy notification data
      {
        'title': 'Welcome!',
        'body': 'Welcome to your admin panel.',
        'createdAt': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
        'data': {'type': 'general'},
      },
      {
        'title': 'New Order',
        'body': 'A new order has been placed.',
        'createdAt': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
        'data': {'type': 'new_order_admin'},
      },
    ];

    if (fetchedNotifications.isNotEmpty) {
      // TODO: Update _last based on your backend's pagination strategy
      _docs.addAll(fetchedNotifications);
    }
    if (fetchedNotifications.length < _pageSize) _done = true;

    setState(() => _loading = false);
  }

  IconData _iconFor(Map<String, dynamic> data) {
    final t = (data['type'] ?? data['data']?['type'] ?? '').toString();
    switch (t) {
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
      default:
        return Icons.notifications_none_outlined;
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.parse(isoString);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Notifications', style: simple_text_style(fontSize: 20)),
        backgroundColor: AppColour.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _docs.clear();
            _last = null;
            _done = false;
          });
          await _loadMore();
        },
        child: _docs.isEmpty && !_loading
            ? _EmptyState(onBrowse: () => Navigator.of(context).pushNamed('/home'))
            : NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) _loadMore();
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _docs.length + (_loading ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              if (index >= _docs.length) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(color: AppColour.primary,)),
                );
              }
              final data = _docs[index];
              final createdAt = data['createdAt'] as String?;
              final title = (data['title'] ?? '').toString();
              final body = (data['body'] ?? '').toString();

              return Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconFor(data['data'] is Map ? Map<String, dynamic>.from(data['data']) : data),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title.isEmpty ? 'Notification' : title,
                                  style: simple_text_style(
                                      fontWeight: FontWeight.bold
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  _formatTime(createdAt),
                                  style: simple_text_style(
                                      color: AppColour.lightGrey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: simple_text_style(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

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
            const Icon(Icons.notifications_none_outlined, size: 72),
            const SizedBox(height: 8),
            Text('No notifications yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Orders, payments and alerts will show up here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
