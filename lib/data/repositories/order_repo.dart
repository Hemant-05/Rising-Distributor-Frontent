import 'dart:typed_data';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/order.dart';

import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class OrderRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  // 1. Get My Orders
  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _client.getMyOrders();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  // 2. Get Single Order
  Future<Order> getOrderById(int id) async {
    try {
      final response = await _client.getOrderById(id);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // 3. Place Order
  Future<Order> placeOrder(int addressId, String paymentMethod) async {
    try {
      final response = await _client.placeOrder(addressId, paymentMethod);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // 4. Confirm Online Payment (Razorpay)
  Future<Order> confirmPayment({
    required int orderId,
    required String transactionId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final payload = {
        "orderId": orderId,
        "transactionId": transactionId,
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
      };
      final response = await _client.confirmPayment(payload);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // 5. Cancel Order
  Future<Order> cancelOrder(int orderId) async {
    try {
      final response = await _client.cancelOrder(orderId);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  // 6. Download Invoice (Returns Bytes)
  Future<Uint8List> downloadInvoice(int orderId) async {
    try {
      // Dio returns List<int>, convert to Uint8List for file writing
      final bytes = await _client.downloadInvoice(orderId);
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw handleError(e);
    }
  }

  // 7. Update Status (Admin Only)
  Future<Order> updateOrderStatus(int id, String status) async {
    try {
      final response = await _client.updateAdminOrderStatus(id, status);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }
}