import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/features/user/order/widgets/on_completed_widget.dart';
import 'package:raising_india/features/user/order/widgets/on_going_widget.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _selectedIndex = 0; // Default to Ongoing (0)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderService>().fetchMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Professional soft background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 12),
            Text('My Orders', style: simple_text_style(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Consumer<OrderService>(
        builder: (context, orderService, child) {
          if (orderService.isLoading) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }

          final allOrders = orderService.orders;
          final ongoingOrders = allOrders.where((o) => o.status != 'DELIVERED' && o.status != 'CANCELLED').toList();
          final historyOrders = allOrders.where((o) => o.status == 'DELIVERED' || o.status == 'CANCELLED').toList();

          return Column(
            children: [
              // Custom Pill-Shaped Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildTab('Ongoing', 0, ongoingOrders.length),
                    _buildTab('History', 1, historyOrders.length),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: _selectedIndex == 0
                    ? onGoingWidget(ongoingOrders)
                    : onCompletedWidget(historyOrders),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, int tabIndex, int count) {
    final isSelected = _selectedIndex == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = tabIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColour.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            '$title ($count)',
            style: simple_text_style(
              color: isSelected ? AppColour.primary : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}