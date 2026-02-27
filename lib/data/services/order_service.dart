import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raising_india/data/repositories/order_repo.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/order.dart';
import 'package:retrofit/dio.dart';
// import 'package:open_filex/open_filex.dart'; // Add this if you want to auto-open PDF


class OrderService extends ChangeNotifier {
  final OrderRepository _repo = OrderRepository();

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- 1. Fetch Orders ---
  Future<void> fetchMyOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _repo.getMyOrders();
      // Sort by newest first (optional)
      _orders.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    } catch (e) {
      print("Order Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. Place Order ---
  Future<String?> placeOrder({required int addressId, required String paymentMethod}) async {
    try {
      await _repo.placeOrder(addressId, paymentMethod);
      await fetchMyOrders(); // Refresh list to show new order
      return null; // Success
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to place order.";
    }
  }

  // --- 3. Confirm Payment ---
  Future<String?> confirmPayment({
    required int orderId,
    required String transactionId,
    required String payId,
    required String signature,
  }) async {
    try {
      await _repo.confirmPayment(
        orderId: orderId,
        transactionId: transactionId,
        razorpayPaymentId: payId,
        razorpaySignature: signature,
      );
      await fetchMyOrders(); // Update status in UI
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Payment confirmation failed.";
    }
  }

  // --- 4. Cancel Order ---
  Future<String?> cancelOrder(int orderId, String reason) async {
    try {
      await _repo.cancelOrder(orderId, reason);
      await fetchMyOrders(); // Refresh UI
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to cancel order.";
    }
  }

  // --- 5. Download Invoice ---
  Future<String?> downloadInvoice(int orderId) async {
    try {
      final bytes = await _repo.downloadInvoice(orderId);

      // Save file to temporary directory
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_$orderId.pdf');

      await file.writeAsBytes(bytes, flush: true);

      // Optional: Open the file immediately
      // await OpenFilex.open(file.path);

      return "Invoice saved to ${file.path}";
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to download invoice.";
    }
  }
}