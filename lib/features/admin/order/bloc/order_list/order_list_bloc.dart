import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/admin/order/OrderFilterType.dart';
import 'package:raising_india/features/admin/services/order_repository.dart';
import 'package:raising_india/models/order_model.dart';
import 'package:raising_india/models/order_with_product_model.dart';
import 'package:raising_india/models/ordered_product.dart';
import 'package:raising_india/models/product_model.dart';

part 'order_list_event.dart';
part 'order_list_state.dart';

class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  final FirebaseFirestore firestore;
  final OrderRepository orderRepository;
  StreamSubscription? _subscription;
  OrderFilterType? _currentFilter;

  OrderListBloc(this.firestore, this.orderRepository) : super(OrderListState(orders: [])) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadMoreOrders>(_onLoadMoreOrders);
    on<RefreshOrders>(_onRefreshOrders);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderListState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    _currentFilter = event.filterType;

    try {
      // Cancel previous subscription
      await _subscription?.cancel();

      final query = _buildQuery(event.filterType);

      // ✅ FIXED: Proper async stream handling
      await for (final snapshot in query.snapshots()) {
        if (emit.isDone) break; // Check if emit is still valid

        try {
          final orders = await _convertToOrderWithProducts(snapshot.docs);

          if (!emit.isDone) { // Double-check before emitting
            emit(state.copyWith(
              orders: orders,
              loading: false,
              hasMore: event.filterType == OrderFilterType.all ? snapshot.docs.length >= 30 : false,
              lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
            ));
          }
        } catch (e) {
          if (!emit.isDone) {
            emit(state.copyWith(error: e.toString(), loading: false));
          }
          break;
        }
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(error: e.toString(), loading: false));
      }
    }
  }

  Future<void> _onLoadMoreOrders(LoadMoreOrders event, Emitter<OrderListState> emit) async {
    if (!state.hasMore || state.loadingMore || _currentFilter != OrderFilterType.all) return;

    emit(state.copyWith(loadingMore: true));

    try {
      Query query = _buildQuery(OrderFilterType.all);
      final snapshot = await query
          .startAfterDocument(state.lastDocument!)
          .limit(20)
          .get();

      final newOrders = await _convertToOrderWithProducts(snapshot.docs);
      final allOrders = [...state.orders, ...newOrders];

      emit(state.copyWith(
        orders: allOrders,
        loadingMore: false,
        hasMore: snapshot.docs.length == 20,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : state.lastDocument,
      ));
    } catch (e) {
      emit(state.copyWith(loadingMore: false, error: e.toString()));
    }
  }

  void _onRefreshOrders(RefreshOrders event, Emitter<OrderListState> emit) {
    if (_currentFilter != null) {
      add(LoadOrders(_currentFilter!));
    }
  }

  Query _buildQuery(OrderFilterType filterType) {
    Query query = firestore.collection('orders').orderBy('createdAt', descending: true);

    switch (filterType) {
      case OrderFilterType.running:
        return query.where('orderStatus', whereIn: [OrderStatusCreated, OrderStatusConfirmed, OrderStatusPreparing, OrderStatusDispatch]);
      case OrderFilterType.delivered:
        return query.where('orderStatus', isEqualTo: OrderStatusDeliverd);
      case OrderFilterType.cancelled:
        return query.where('orderStatus', isEqualTo: OrderStatusCancelled);
      case OrderFilterType.today:
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        return query
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay));
      case OrderFilterType.all:
        return query;
    }
  }

  Future<List<OrderWithProducts>> _convertToOrderWithProducts(List<QueryDocumentSnapshot> docs) async {
    final orders = docs.map((d) => OrderModel.fromMap(d.data() as Map<String, dynamic>)).toList();

    // Get product details for each order
    final productIds = orders
        .expand((o) => o.items.map((i) => i['productId'] as String))
        .toSet()
        .toList();

    final productDocs = await Future.wait(productIds.chunked(10).map((chunk) {
      return firestore.collection('products')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
    }));

    final productMap = {
      for (var doc in productDocs.expand((q) => q.docs))
        doc.id: ProductModel.fromMap(doc.data(), doc.id)
    };

    return orders.map((o) => OrderWithProducts(
        order: o,
        products: o.items.map((i) {
          final p = productMap[i['productId']];
          return OrderedProduct(product: p, qty: int.parse(i['quantity'].toString()));
        }).toList()
    )).toList();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

// Extension for chunking
extension ListExtensions<T> on List<T> {
  List<List<T>> chunked(int chunkSize) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(i, i + chunkSize > length ? length : i + chunkSize));
    }
    return chunks;
  }
}