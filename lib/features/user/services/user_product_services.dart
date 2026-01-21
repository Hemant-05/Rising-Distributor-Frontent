import 'package:dio/dio.dart';
import 'package:raising_india/config/api_endpoints.dart';
import 'package:raising_india/models/category_model.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:raising_india/network/dio_client.dart';
import 'package:raising_india/services/service_locator.dart';

class UserProductServices {
  final DioClient _dioClient = getIt<DioClient>();

  Future<bool> addProductToCart(String productId, int quantity) async {
    final data = {'productId': productId, 'quantity': quantity};
    try {
      final response = await _dioClient.post(ApiEndpoints.addToCart,data: data);
      if(response.statusCode == 200){
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to add product to cart: $e');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      // final querySnapshot = await _firestore.collection('categories').get();
      // return querySnapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
      List<CategoryModel> categories = [];
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCartProducts() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.getCartItems);
      final resp = response.data as Map<String, dynamic>;
      if(response.statusCode == 200){
        final payloadData = resp['data'];
        List<Map<String, dynamic>> cartProducts = [];
        for(var data in payloadData){
          final productId = data['productId'];
          final model = await getProductById(productId);
          cartProducts.add({
            'productId': productId,
            'product': ProductModel.fromMap(model.toMap(), productId),
            'quantity': data['quantity'],
          });
        }
        return cartProducts;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch cart products: $e');
    }
  }

  Future<ProductModel> getProductById(String productId) async {
    try {
      ProductModel product;
      Response response = await _dioClient.get(ApiEndpoints.getProductsById(productId));
      final resp = response.data as Map<String, dynamic>;
      if(response.statusCode == 200){
        product = ProductModel.fromMap(resp['data'], resp['data']['pid']);
      }else{
        throw Exception('Product Not Found...');
      }
      return product;
    } catch (e) {
      throw Exception('Failed to fetch product by ID: $e');
    }
  }

  Future<bool> removeProductFromCart(String productId) async {
    try {
      final response = await _dioClient.delete(ApiEndpoints.removeCartItem(productId));
      if(response.statusCode == 200){
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to remove product from cart: $e');
    }
  }

  Future<Map<String, dynamic>> isInCart(
    String productId,
  ) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.isInCart(productId));
      final resp = response.data as Map<String, dynamic>;
      return resp;
    } catch (e) {
      throw Exception('Failed to check if product is in cart: $e');
    }
  }

  Future<bool> clearCart() async {
    try {
      final response = await _dioClient.delete(ApiEndpoints.clearCart);
      print(response);
      if(response.statusCode == 200){
        return true;
      }
      return true;
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  Future<int> getCartProductCount() async {
    try {
      int count = 0;
      final response = await _dioClient.get(ApiEndpoints.getCartItems);
      if(response.statusCode == 200){
        final resp = response.data as Map<String, dynamic>;
        count = resp['data'];
      }
      return count;
    } catch (e) {
      throw Exception('Failed to fetch cart product count: $e');
    }
  }

  Future<List<Map<String, dynamic>>> updateCartProductQuantity(
    String productId,
    int quantity,
  ) async {
    final data = {'productId': productId, 'quantity': quantity};
    try {
      List<Map<String, dynamic>> updateCartProducts = [];
      final response = await _dioClient.put(ApiEndpoints.updateCartProductQty, data: data);
      if(response.statusCode == 200){
        final resp = response.data as Map<String, dynamic>;
        final isUpdated = resp['data'];
        if(isUpdated){
          updateCartProducts = await getCartProducts();
        }
      }
      return updateCartProducts;
    } catch (e) {
      throw Exception('Failed to update product quantity in cart: $e');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      /*final querySnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();*/
      List<ProductModel> products = [];
      return products;
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  Future<List<ProductModel>> getBestSellingProducts() async {
    try {
      Response response = await _dioClient.get(ApiEndpoints.getProducts);
      final resp = response.data as Map<String, dynamic>;
      if(response.statusCode == 200) {
        final payloadData = resp['data'];
        List<ProductModel> productList = [];
        for(int i = 0; i < payloadData.length; i++){
          productList.add(ProductModel.fromMap(payloadData[i], payloadData[i]['pid']));
        }
        return productList;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch best selling products: $e');
    }
  }

  Future<List<ProductModel>> getAllProducts() async{
    try {
      Response response = await _dioClient.get(ApiEndpoints.getProducts);
      final resp = response.data as Map<String, dynamic>;
      if(response.statusCode == 200) {
        final payloadData = resp['data'];
        List<ProductModel> productList = [];
        for(int i = 0; i < payloadData.length; i++){
          productList.add(ProductModel.fromMap(payloadData[i], payloadData[i]['pid']));
        }
        return productList;
      }
      return [];
    }catch(e){
      throw Exception('Failed to fetch products: $e');
    }
  }
}