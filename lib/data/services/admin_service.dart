import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/admin_repo.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/features/admin/order/OrderFilterType.dart';
import 'package:raising_india/models/dto/dashboard_response.dart';
import 'package:raising_india/models/model/order.dart';
import 'package:raising_india/models/model/product.dart';

class AdminService extends ChangeNotifier {
  final AdminRepository _repo = AdminRepository();

  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  List<Order> _filteredOrders = [];
  List<Order> get filteredOrders => _filteredOrders;

  String? _error;
  String? get error => _error;

  List<Product> _products = [];
  List<Product> get products => _products;


  DashboardResponse? _dashboardStats;
  DashboardResponse? get dashboardStats => _dashboardStats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadOrdersByFilterType(OrderFilterType type) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Assuming you added `getTodaysOrders` to your RestClient as discussed previously
      switch (type) {
        case OrderFilterType.today:
          _filteredOrders = (await _repo.getTodaysOrders()) ?? []; // Map this to your RestClient's "today" endpoint
          break;
        case OrderFilterType.all:
          _filteredOrders = (await _repo.getAllOrders()) ?? []; // Ensure _repo.getAllOrders returns ApiResponse
          break;
        case OrderFilterType.running:
          _filteredOrders = (await _repo.fetchOrdersByStatus("RUNNING")) ?? [];
          break;
        case OrderFilterType.cancelled:
          _filteredOrders = (await _repo.fetchOrdersByStatus("CANCELLED")) ?? [];
          break;
        case OrderFilterType.delivered:
          _filteredOrders = (await _repo.fetchOrdersByStatus("DELIVERED")) ?? [];
          break;
        default :
          _filteredOrders = [];
      }
    } catch (e) {
      _error = e.toString();
      print("Admin Fetch Filtered Orders Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> refundOrder(int orderId) async{
    _isLoading = true;
    notifyListeners();
    try {
      Order order = await _repo.refundOrder(orderId);
      _error = null;
      return order;
      } catch (e) {
      _error = e.toString();
      print("Admin Refund Order Error: $e");
    }finally{
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<Order?> updatePayment(int orderId, String paymentStatus) async {
    _isLoading = true;
    notifyListeners();
    try {
      Order order = await _repo.updatePayment(orderId, paymentStatus);
      _error = null;
      return order;
    } catch (e) {
      _error = e.toString();
      print("Admin Refund Order Error: $e");
    }finally{
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> fetchAllProducts() async{
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _repo.getAllProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print("Admin Products Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      _dashboardStats = await _repo.getDashboard();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print("Dashboard Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateOrderStatus(int orderId, String status) async {
    try {
      await _repo.updateOrderStatus(orderId, status);
      await _repo.getAllOrders();
      _error = null;
      return null;
    } on AppError catch (e) {
      _error = e.message;
      return e.message;
    } catch (e) {
      _error = "Failed to update status. ${e.toString()}";
      return "Failed to update status.";
    }
  }
}