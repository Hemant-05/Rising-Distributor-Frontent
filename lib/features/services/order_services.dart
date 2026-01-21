import 'package:raising_india/config/api_endpoints.dart';
import 'package:raising_india/models/order_model.dart';
import 'package:raising_india/network/dio_client.dart';

import '../../services/service_locator.dart';

class OrderServices {
  final DioClient _dioClient = getIt<DioClient>();

  Future<List<OrderModel>> getAllDeliveredOrders() async {
    List<OrderModel> list = [];
    final response = await _dioClient.get("");

    return list;
  }

  Future<List<OrderModel>> getAllCancelledOrders() async {
    List<OrderModel> list = [];

    return list;
  }

  Future<List<OrderModel>> fetchUserHistoryOrders() async {
    try {
      List<OrderModel> list = [];
      final response = await _dioClient.get(ApiEndpoints.getMyOrders);
      final resp = response.data as Map<String, dynamic>;
      final statusCode = resp['statusCode'];
      if (statusCode == 200) {
        final payloadData = resp['data'] ?? resp;
        for (var item in payloadData) {
          OrderModel model = OrderModel.fromMap(item);
          list.add(model);
        }
      }
      return list;
    } catch (e) {
      print('Error fetching history orders: $e');
      return [];
    }
  }

  Future<List<OrderModel>> fetchUserOngoingOrders() async {
    try {
      List<OrderModel> list = [];

      return list;
    } catch (e) {
      print('Error fetching ongoing orders: $e');
      return [];
    }
  }

  Future<void> placeOrder(OrderModel model) async {
    /*try {
      final response = await _dioClient.post(
        ApiEndpoints.placeOrder(model.addressId, model.paymentMethod),
        data: model.toMap(),
      );
    }*/
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    OrderModel model;
    final response = await _dioClient.get(ApiEndpoints.getOrderById(orderId));
    final resp = response.data as Map<String, dynamic>;
    final statusCode = resp['statusCode'];
    if (statusCode == 200) {
      final payloadData = resp['data'] ?? resp;
      model = OrderModel.fromMap(payloadData);
      return model;
    } else {
      return null;
    }
  }

  Future<void>  cancelOrder(String orderId, String cancellationReason,String payStatus) async {
    final order = await getOrderById(orderId);
    final response = await _dioClient.post(ApiEndpoints.cancelOrder(orderId));
    final resp = response.data as Map<String, dynamic>;
    final statusCode = resp['statusCode'];
    if (statusCode == 200) {
      final payloadData = resp['data'] ?? resp;
      // model = OrderModel.fromMap(payload_data);
    } else {
      // return null;
    }
  }
}
