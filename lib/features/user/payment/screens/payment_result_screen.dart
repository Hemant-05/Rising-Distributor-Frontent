import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/order_service.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String transactionId;

  const PaymentResultScreen({
    super.key,
    required this.isSuccess,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Text(isSuccess ? "Payment Success" : "Payment Failed"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess ? "Payment Successful!" : "Payment Failed!",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text("Transaction ID: $transactionId"),
            const SizedBox(height: 24),
            ElevatedButton(
              style: elevated_button_style(),
              onPressed: () {
                // Refresh order list if success (or failure, to show cancelled state)
                context.read<OrderService>().fetchMyOrders();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(
                isSuccess ? "Continue Shopping" : "Back to Home",
                style: simple_text_style(
                  color: AppColour.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}