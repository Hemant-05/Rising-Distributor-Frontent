import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/features/admin/order/OrderFilterType.dart';
import 'package:raising_india/models/order_model.dart';
import 'package:raising_india/models/order_with_product_model.dart';
import 'package:raising_india/models/ordered_product.dart';
import 'package:raising_india/models/product_model.dart';

class OrderRepository {
  final FirebaseFirestore firestore;

  OrderRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Get orders with real-time updates and filtering
  Stream<List<OrderWithProducts>> getOrders({
    required OrderFilterType filterType,
    DocumentSnapshot? startAfterDoc,
    int limit = 30,
  }) {
    Query query = firestore.collection('orders').orderBy('createdAt', descending: true);

    // Apply filters based on order type
    switch (filterType) {
      case OrderFilterType.running:
        query = query.where('orderStatus', whereIn: ['created', 'confirmed', 'preparing', 'dispatched']);
        break;
      case OrderFilterType.delivered:
        query = query.where('orderStatus', isEqualTo: 'delivered');
        break;
      case OrderFilterType.cancelled:
        query = query.where('orderStatus', isEqualTo: 'cancelled');
        break;
      case OrderFilterType.today:
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay));
        break;
      case OrderFilterType.all:
      // No additional filter for all orders
        break;
    }

    // Add pagination if startAfterDoc is provided
    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    query = query.limit(limit);

    return query.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return <OrderWithProducts>[];
      }

      // Convert documents to OrderModel
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Extract all unique product IDs from all orders
      final productIds = orders
          .expand((order) => order.items.map((item) => item['productId'] as String))
          .toSet()
          .toList();

      if (productIds.isEmpty) {
        // No products to fetch, return orders with empty products
        return orders.map((order) => OrderWithProducts(
            order: order,
            products: <OrderedProduct>[]
        )).toList();
      }

      // Fetch product details in batches (Firestore whereIn limit is 10)
      final products = await _fetchProductsInBatches(productIds);

      // Create a map for quick product lookup
      final productMap = {for (var product in products) product.pid: product};

      // Combine orders with their product details
      return orders.map((order) {
        final orderProducts = order.items.map((item) {
          final product = productMap[item['productId']];
          final qty = (item['quantity'] ?? 1) as int;
          return OrderedProduct(product: product, qty: qty);
        }).toList();

        return OrderWithProducts(order: order, products: orderProducts);
      }).toList();
    });
  }

  /// Fetch a single order with products
  Future<OrderWithProducts?> getOrderById(String orderId) async {
    try {
      final orderDoc = await firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        return null;
      }

      final order = OrderModel.fromMap(orderDoc.data()!);
      // Extract product IDs
      final productIds = order.items.map((item) => item['productId'] as String).toList();

      if (productIds.isEmpty) {
        return OrderWithProducts(order: order, products: <OrderedProduct>[]);
      }

      // Fetch products
      final products = await _fetchProductsInBatches(productIds);
      final productMap = {for (var product in products) product.pid: product};

      // Create ordered products
      final orderProducts = order.items.map((item) {
        final product = productMap[item['productId']];
        final qty = int.parse(item['quantity'] ?? 1);
        return OrderedProduct(product: product, qty: qty);
      }).toList();

      return OrderWithProducts(order: order, products: orderProducts);
    } catch (e) {
      print('Error fetching order $orderId: $e');
      return null;
    }
  }

  /// Fetch products in batches to handle Firestore whereIn limit
  Future<List<ProductModel>> _fetchProductsInBatches(List<String> productIds) async {
    final products = <ProductModel>[];
    const batchSize = 10; // Firestore whereIn limit

    for (var i = 0; i < productIds.length; i += batchSize) {
      final batchIds = productIds.sublist(
        i,
        i + batchSize > productIds.length ? productIds.length : i + batchSize,
      );

      try {
        final batchSnapshot = await firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        final batchProducts = batchSnapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList();

        products.addAll(batchProducts);
      } catch (e) {
        print('Error fetching product batch: $e');
        // Continue with next batch even if this one fails
      }
    }

    return products;
  }


  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await firestore.collection('orders').doc(orderId).update({
        'orderStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String orderId, String status) async {
    try {
      await firestore.collection('orders').doc(orderId).update({
        'paymentStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }
}
