import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/services/order_processing_service.dart';
import 'package:raising_india/models/order_model.dart';

class OrderServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrderProcessingService _service = OrderProcessingService();

  Future<List<OrderModel>> getAllDeliveredOrders() async {
    List<OrderModel> list = [];
    var res = await _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: OrderStatusDeliverd)
        .orderBy('createdAt', descending: false)
        .get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      list.add(model);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<OrderModel>> getAllCancelledOrders() async {
    List<OrderModel> list = [];
    var res = await _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: OrderStatusCancelled)
        .orderBy('createdAt', descending: false)
        .get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      list.add(model);
    }

    return list;
  }

  Future<List<OrderModel>> getAllOnGoingOrders() async {
    List<OrderModel> list = [];
    var res = await _firestore
        .collection('orders')
        .where('orderStatus', isNotEqualTo: OrderStatusCancelled)
        .where('orderStatus', isNotEqualTo: OrderStatusDeliverd)
        .orderBy('createdAt', descending: false)
        .get();
    for (var element in res.docs) {
      final model = OrderModel.fromMap(element.data());
      list.add(model);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<OrderModel>> fetchUserHistoryOrders() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .where(
            'orderStatus',
            whereIn: [OrderStatusDeliverd, OrderStatusCancelled],
          ) // ✅ Efficient whereIn query
          .orderBy(
            'createdAt',
            descending: true,
          ) // ✅ Direct ordering by timestamp
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()..['orderId'] = doc.id))
          .toList();
    } catch (e) {
      print('Error fetching history orders: $e');
      return [];
    }
  }

  Future<List<OrderModel>> fetchUserOngoingOrders() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .where(
            'orderStatus',
            whereIn: [OrderStatusCreated, OrderStatusConfirmed, OrderStatusPreparing, OrderStatusDispatch],
          ) //
          .orderBy('createdAt', descending: true) //
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()..['orderId'] = doc.id))
          .toList();
    } catch (e) {
      print('Error fetching ongoing orders: $e');
      return [];
    }
  }

  Future<void> placeOrder(OrderModel model) async {

  }

  Future<OrderModel> getOrderById(String orderId) async {
    OrderModel model;
    var res = await _firestore.collection('orders').doc(orderId).get();
    model = OrderModel.fromMap(res.data()!);
    return model;
  }

  Future<void>  cancelOrder(String orderId, String cancellationReason,String payStatus) async {
    final order = await getOrderById(orderId);
    await _service.cancelOrder(order);
    String paymentStatus = '';
    if(payStatus == PayStatusPending){
      paymentStatus = PayStatusNotPaid;
    }
    await _firestore.collection('orders').doc(orderId).update({
      'orderStatus': OrderStatusCancelled,
      'cancellationReason': cancellationReason,
      'paymentStatus': paymentStatus.isEmpty? payStatus : paymentStatus,
    });
  }
}
