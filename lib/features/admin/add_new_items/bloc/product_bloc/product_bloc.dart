import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/features/admin/services/product_services.dart';
import 'package:raising_india/models/product_model.dart';
part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    bool isAvailable = false;

    on<ProductEvent>((event, emit) {

    });
    on<ToggleAvailabilityEvent>((event, emit) {
      isAvailable = event.isAvailable;
      emit(ProductAvailabilityToggled(isAvailable));
    });
    on<FetchProductsEvent>((event, emit) async {
      try {
        emit(ProductAddLoading());
        final products = await ProductServices(event.uid).fetchProducts();
        emit(ProductFetched(products));
      } catch (e) {
        emit(ProductFetchError(e.toString()));
      }
    });
    on<FetchProductByIdEvent>((event, emit) async {
      try {
        emit(ProductLoading());
        final product = await ProductServices(event.uid).fetchProductById(event.productId);
        emit(ProductFetchByIdLoaded(product!));
      } catch (e) {
        emit(ProductFetchByIdFailure(e.toString()));
      }
    });
    on<AddProductEvent>((event, emit) async {
      try {
        emit(ProductAddLoading());
        final message = await ProductServices(event.uid).addProduct(event.product);
        emit(ProductAdded(message));
      } catch (e) {
        emit(ProductAddError(e.toString()));
      }
    });
    on<UpdateProductEvent>((event, emit) async {
      try {
        emit(ProductLoading());
        final message = await ProductServices(event.uid).updateProduct(event.product);
        emit(ProductUpdated(message));
      } catch (e) {
        emit(ProductUpdateError(e.toString()));
      }
    });
    on<DeleteProductEvent>((event, emit) async {
      try {
        emit(ProductLoading());
        final message = await ProductServices(event.uid).deleteProduct(event.productId);
        emit(ProductDeleted(message));
      } catch (e) {
        emit(ProductDeleteError(e.toString()));
      }
    });

  }
}
