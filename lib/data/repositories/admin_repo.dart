import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/dto/dashboard_response.dart';
import 'package:raising_india/models/model/order.dart';
import 'package:raising_india/models/model/product.dart';
import '../../../data/rest_client.dart';
import '../../../services/service_locator.dart';

class AdminRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<List<Product>> getAllProducts() async{
    try {
      final response = await _client.getAllProducts();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _client.getAllAdminOrders();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }
  Future<List<Order>> getTodaysOrders() async {
    try {
      final response = await _client.getTodaysOrders();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  // Example usage inside AdminService or OrderRepository
  Future<List<Order>> fetchOrdersByStatus(String status) async {
    try {
      // Pass 'PENDING', 'SHIPPED', etc.
      final response = await _client.getOrdersByStatus(status);

      if (response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Order> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _client.updateAdminOrderStatus(orderId, status);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<double> getTotalRevenue() async {
    try {
      final response = await _client.getTotalRevenue();
      return response.data ?? 0.0;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<DashboardResponse> getDashboard() async {
    try {
      final response = await _client.getDashboard();
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }
}