import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/features/user/services/user_product_services.dart';
import 'package:raising_india/models/product_model.dart';

part 'product_fun_event.dart';
part 'product_fun_state.dart';

class ProductFunBloc extends Bloc<ProductFunEvent, ProductFunState> {
  final UserProductServices _services = UserProductServices();

  ProductFunBloc() : super(ProductFunState.initial()) {
    on<IncreaseQuantity>((event, emit) {
        emit(state.copyWith(quantity: state.quantity + 1));
    });

    on<DecreaseQuantity>((event, emit) {
      if (state.quantity > 1) {
        emit(state.copyWith(quantity: state.quantity - 1));
      }
    });

    on<AddToCartPressed>((event, emit) async {
      emit(state.copyWith(isAddingToCart: true));
      try{
        await _services.addProductToCart(event.productId, state.quantity);
      }catch(e){
        emit(state.copyWith(isAddingToCart: false, error: e.toString()));
        return;
      }
      emit(state.copyWith(isAddingToCart: false, isAddedToCart: true));
    });

    on<GetProductByID>((event, emit) async {
      emit(state.copyWith(isLoadingProductDetails: true));
      try{
        ProductModel product = await _services.getProductById(event.productId);
        emit(state.copyWith(product: product, isLoadingProductDetails: false));
      }catch(e){
        emit(state.copyWith(isLoadingProductDetails: false, error: e.toString()));
      }
    });

    on<RemoveFromCartPressed>((event, emit) async {
      emit(state.copyWith(isRemovingToCart: true));
      try{
        await _services.removeProductFromCart(event.productId);
        final cart = await _services.getCartProducts();
        emit(state.copyWith(isRemovingToCart: false, isRemovedToCart: true,getCartProduct: cart));
      }catch(e){
        emit(state.copyWith(isRemovingToCart: false, error: e.toString()));
      }
    });

    on<CheckIsInCart>((event, emit) async {
      emit(state.copyWith(isCheckingIsInCart: true));
      try {
        final map = await _services.isInCart(event.productId);
        final data = map['data'];
        var quantity = data['quantity'] ?? 1;
        final isInCart = data['isInCart'] ?? false;
        if(map['statusCode'] == 200){
          emit(state.copyWith(isInCart: isInCart, isCheckingIsInCart: false,quantity: quantity));
        }else{
          throw(Exception('Something went wrong...'));
        }
      } catch (e) {
        emit(state.copyWith(isCheckingIsInCart: false, error: e.toString()));
      }
    });

    on<ClearCartPressed> ((event, emit) async {
      emit(state.copyWith(isCartCleared: true));
      try {
        await _services.clearCart();
        emit(state.copyWith(isCartClearing: false, isCartCleared: true, getCartProduct: [], cartProductCount: 0));
      } catch (e) {
        emit(state.copyWith(isCartClearing: false, error: e.toString()));
      }
    });

    on<GetCartProductPressed>((event, emit) async {
      emit(state.copyWith(isLoadingCartProduct: true));
      try {
        List<Map<String, dynamic>> products = await _services.getCartProducts();
        emit(state.copyWith(getCartProduct: products, isLoadingCartProduct: false,cartProductCount: products.length));
      } catch (e) {
        emit(state.copyWith(isLoadingCartProduct: false, error: e.toString()));
      }
    });


    on<UpdateProductQuantityPressed>((event, emit) async {
      emit(state.copyWith(isUpdatingProductQuantity: true));
      try {
        List<Map<String, dynamic>> updateCartProducts = await _services.updateCartProductQuantity(event.productId, event.quantity);
        emit(state.copyWith(isUpdatingProductQuantity: false, isUpdatedProductQuantity: true, getCartProduct: updateCartProducts));
      } catch (e) {
        emit(state.copyWith(isUpdatingProductQuantity: false, error: e.toString()));
      }
    });

    on<GetCartProductCount>((event, emit) async {
      emit(state.copyWith(isGettingCartProductCount: true));
      try {
        int count = await _services.getCartProductCount();
        emit(state.copyWith(cartProductCount: count, isGettingCartProductCount: false));
      } catch (e) {
        emit(state.copyWith(isGettingCartProductCount: false, error: e.toString()));
      }
    });
  }
}
