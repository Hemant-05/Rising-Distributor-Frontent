import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/models/order_model.dart';

part 'admin_order_details_state.dart';

// Cubit for managing admin order details
class AdminOrderDetailsCubit extends Cubit<AdminOrderDetailsState> {
  StreamSubscription? _subscription;

  AdminOrderDetailsCubit() : super(AdminOrderDetailsState());

  void loadOrderDetails(String orderId) {
    emit(state.copyWith(loading: true));
    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              final order = OrderModel.fromMap(doc.data()!);
              emit(state.copyWith(order: order, loading: false));
            }
          },
          onError: (error) =>
              emit(state.copyWith(error: error.toString(), loading: false)),
        );
  }

  Future<void> updateOrderStatus(OrderModel order, String status) async {
    try {
      bool isDelivered = status == OrderStatusDeliverd;
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderId)
          .update({
            'orderStatus': status,
            'deliveredAt': isDelivered ? DateTime.now() : null,
          });
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  Future<void> cancelOrder(
    String orderId,
    String reason,
    String paymentStatus,
  ) async {
    emit(state.copyWith(loading: true));
    String payStatus = '';
    if (paymentStatus == PayStatusPending) {
      payStatus = PayStatusNotPaid;
    }
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
            'orderStatus': OrderStatusCancelled,
            'cancellationReason': reason,
            'paymentStatus': payStatus.isEmpty? paymentStatus : payStatus,
          });
      emit(state.copyWith(loading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  Future<void> updatePaymentStatus(String orderId, String status) async {
    try {
      bool isPaid = status == PayStatusPaid;
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'paymentStatus': status, 'paidAt': isPaid ? DateTime.now() : null},
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
