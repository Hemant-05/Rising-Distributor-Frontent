import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/admin_repo.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/dto/dashboard_response.dart';
import 'package:raising_india/models/model/order.dart';
import 'package:raising_india/models/model/product.dart';

class AdminService extends ChangeNotifier {
  final AdminRepository _repo = AdminRepository();

  List<Order> _orders = [];
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

  Future<void> fetchAllProducts() async{
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _repo.getAllProducts();
    } catch (e) {
      _error = e.toString();
      print("Admin Products Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _repo.getAllOrders();
    } catch (e) {
      _error = e.toString();
      print("Admin Orders Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrdersByStatus(String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      _filteredOrders = await _repo.fetchOrdersByStatus(status);
    } catch (e){
      _error = e.toString();
      print("Admin Orders Error: $e");
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
      await fetchAllOrders(); // Refresh list
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