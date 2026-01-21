import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:raising_india/config/api_endpoints.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/category_model.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:raising_india/network/dio_client.dart';
import 'package:raising_india/services/service_locator.dart';

class ProductServices {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final String _uid;

  final DioClient _dioClient = getIt<DioClient>();

  ProductServices(this._uid);

  Future<List<ProductModel>> fetchProducts() async {
    if (_uid.isEmpty) {
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _firebase
          .collection('products')
          .get();
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, _uid);
      }).toList();
    } on FirebaseException catch (e) {
      return Future.error('Error fetching products: ${e.message}');
    }
    return [];
  }

  Future<List<CategoryModel>> fetchCategories() async {
    if (_uid.isEmpty) {
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _firebase
          .collection('categories')
          .get();
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } on FirebaseException catch (e) {
      return Future.error('Error fetching categories: ${e.message}');
    }
  }

  // Example method to fetch products by user ID
  Future<List<ProductModel>> fetchProductsByAdminId(String userId) async {
    if (_uid.isEmpty || userId.isEmpty) {
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _firebase
          .collection('products')
          .where('uid', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, _uid);
      }).toList();
    } on FirebaseException catch (e) {
      return Future.error('Error fetching products by user ID: ${e.message}');
    }
  }

  // Example method to fetch products by category
  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    if (_uid.isEmpty || category.isEmpty) {
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _firebase
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, _uid);
      }).toList();
    } on FirebaseException catch (e) {
      return Future.error('Error fetching products by category: ${e.message}');
    }
  }

  Future<ProductModel?> fetchProductById(String productId) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.getProductsById(productId));

      final resp = response.data as Map<String, dynamic>;
      final statusCode = response.statusCode;
      if(statusCode == 200) {
        final payloadData = resp['data'] ?? resp;
        
      }
      return null;
    } on DioException catch (e) {
      final ex = mapDioException(e);
      if (ex is ServerException) {
        print(ex.message);
        return null;
      }
      if (ex is AuthenticationException) {
        print(ex.message);
        return null;
      }
      if (ex is ValidationException) {
        print(ex.message);
        return null;
      }
      if (ex is NetworkException) {
        print(ex.message);
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Example method to add a new product
  Future<String> addProduct(ProductModel product) async {
    try {
      final data =
      {
        "name": product.name,
        "category": product.category,
        "price": product.price,
        "description": product.description,
        "quantity": product.quantity,
        "measurement": product.measurement,
        "mrp": product.mrp,
        "stockQuantity": product.stockQuantity,
        "lowStockQuantity": product.lowStockQuantity,
        "isAvailable": product.isAvailable,
        "photosList": product.photosList,
        "rating": product.rating
      };
      Response response = await _dioClient.post(ApiEndpoints.addProducts,data: data);
      final resp = response.data as Map<String, dynamic>;
      if(response.statusCode == 201){
        final payloadData = resp['data'] ?? resp;
        print('=========================== $data');
        final productMap = payloadData['product'] ?? payloadData['data'] ?? payloadData;
        if(productMap == null){
          throw ServerException(message: 'Product Data Not Found...');
        }
        return 'Product added successfully';
      }
      return 'Error while adding product.. ${response.statusMessage}';
    } on DioException catch (e) {
     return 'Error adding product: ${e.message}';
    }
  }

  // Example method to update an existing product
  Future<String> updateProduct(ProductModel product) async {
    try {
      await _firebase.collection('products').doc(product.pid).update(product.toMap());
      return 'Product updated successfully';
    } on FirebaseException catch (e) {
      return Future.error('Error updating product: ${e.message}');
    }
  }

  // Example method to delete a product
  Future<String> deleteProduct(String productId) async {
    try {
      await _firebase.collection('products').doc(productId).delete();
      return 'Product deleted successfully';
    } on FirebaseException catch (e) {
      return Future.error('Error deleting product: ${e.message}');
    }
  }
}