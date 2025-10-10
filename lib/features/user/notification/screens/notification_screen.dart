import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;
  const NotificationsScreen({super.key, required this.userId});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _pageSize = 20;
  DocumentSnapshot? _last;
  bool _loading = false;
  bool _done = false;
  String userId = '';
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];

  @override
  void initState() {
    super.initState();
    getId();
    _loadMore();
  }

  void getId() async {
    userId = widget.userId.isEmpty ? FirebaseAuth.instance.currentUser!.uid : widget.userId;
  }

  Future<void> _loadMore() async {
    if (_loading || _done) return;
    setState(() => _loading = true);

    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection('notifications_queue') // or 'notifications'
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(_pageSize);

    if (_last != null) q = q.startAfterDocument(_last!);

    final snap = await q.get();
    if (snap.docs.isNotEmpty) {
      _last = snap.docs.last;
      _docs.addAll(snap.docs);
    }
    if (snap.docs.length < _pageSize) _done = true;

    setState(() => _loading = false);
  }

  Color _colorFor(Map<String, dynamic> data) {
    final t = (data['type'] ?? data['data']?['type'] ?? '').toString();
    switch (t) {
      case 'order_placed':
      case 'new_order_admin':
        return AppColour.primary;
      case 'order_confirmed':
      case 'order_preparing':
        return Colors.orange;
      case 'out_for_delivery':
        return Colors.blue;
      case 'order_delivered':
        return AppColour.green;
      case 'order_cancelled':
      case 'order_cancelled_admin':
        return Colors.red;
      case 'payment_success':
      case 'payment_refund':
        return Colors.green;
      case 'payment_failed':
        return Colors.red;
      case 'low_stock_alert':
        return Colors.amber;
      default:
        return AppColour.lightGrey;
    }
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

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(1, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Notifications',
          style: simple_text_style(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColour.black,
          ),
        ),
        backgroundColor: AppColour.white,
        elevation: 0,
        shadowColor: AppColour.black.withOpacity(0.05),
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
        color: AppColour.primary,
        child: _docs.isEmpty && !_loading
            ? _EmptyState(onBrowse: _loadMore)
            : NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) _loadMore();
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _docs.length + (_loading ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index >= _docs.length) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: AppColour.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              final doc = _docs[index];
              final data = doc.data();
              final createdAt = data['createdAt'] as Timestamp?;
              final isAdmin = data['isAdminNotification'] == true;
              final title = (data['title'] ?? '').toString();
              final body = (data['body'] ?? '').toString();
              final iconColor = _colorFor(data['data'] is Map ? Map<String, dynamic>.from(data['data']) : data);

              return Card(
                elevation: 2,
                color: AppColour.white,
                shadowColor: iconColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColour.primary.withOpacity(0.4),width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {}, // Placeholder for future interactivity; no functionality added
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                iconColor.withOpacity(0.2),
                                iconColor.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: iconColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _iconFor(data['data'] is Map ? Map<String, dynamic>.from(data['data']) : data),
                            color: iconColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColour.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: iconColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatTime(createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                body,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColour.lightGrey,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isAdmin)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Admin Update',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColour.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 48,
                color: AppColour.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No notifications yet',
              style: simple_text_style(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColour.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders, payments and alerts will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColour.lightGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onBrowse,
                icon: const Icon(Icons.storefront_outlined, size: 20),
                label: const Text('Refresh Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColour.primary,
                  foregroundColor: AppColour.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
