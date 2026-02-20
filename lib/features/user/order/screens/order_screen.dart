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
  int index = 0; // Default to Ongoing (0)

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
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('My Orders', style: simple_text_style(fontSize: 20)),
            const Spacer(),
          ],
        ),
      ),
      body: Consumer<OrderService>(
        builder: (context, orderService, child) {
          if (orderService.isLoading) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }

          // Filter Orders Locally
          final allOrders = orderService.orders;

          final ongoingOrders = allOrders.where((o) =>
          o.status != 'DELIVERED' && o.status != 'CANCELLED'
          ).toList();

          final historyOrders = allOrders.where((o) =>
          o.status == 'DELIVERED' || o.status == 'CANCELLED'
          ).toList();

          return Column(
            children: [
              // Tabs
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Row(
                  children: [
                    _buildTab('Ongoing', 0, ongoingOrders.length),
                    _buildTab('History', 1, historyOrders.length),
                  ],
                ),
              ),
              Divider(color: AppColour.lightGrey.withOpacity(0.5)),

              // Content
              Expanded(
                child: index == 0
                    ? onGoingWidget(ongoingOrders) // Pass filtered list
                    : onCompletedWidget(historyOrders), // Pass filtered list
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, int tabIndex, int count) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => index = tabIndex),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            '$title ($count)',
            style: simple_text_style(
              color: index == tabIndex ? AppColour.primary : AppColour.lightGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}