import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/features/user/services/user_product_services.dart';
import 'package:raising_india/models/category_model.dart';
import 'package:raising_india/models/product_model.dart';
part 'category_product_event.dart';
part 'category_product_state.dart';

class CategoryProductBloc extends Bloc<CategoryProductEvent, CategoryProductState> {
  final UserProductServices services;
  CategoryProductBloc({required this.services}) : super(CategoryProductState.initial()) {
    on<CategoryProductEvent>((event, emit) {});
    on<FetchCategories>(_onFetchCategories);
    on<FetchBestSellingProducts>(_onFetchBestSellingProducts);
    on<FetchProductsByCategory>(_onFetchProductsByCategory);
    on<FetchAllProducts>(_onFetchAllProducts);
  }

  FutureOr<void> _onFetchCategories(FetchCategories event, Emitter<CategoryProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final categories = await services.getCategories();
      emit(state.copyWith(isLoading: false, categories: categories));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onFetchBestSellingProducts(
    FetchBestSellingProducts event,
    Emitter<CategoryProductState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final bestSellingProducts = await services.getBestSellingProducts();
      emit(state.copyWith(
        isLoading: false,
        bestSellingProducts: bestSellingProducts,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onFetchProductsByCategory(
    FetchProductsByCategory event,
    Emitter<CategoryProductState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = await services.getProductsByCategory(event.category);
      emit(state.copyWith(
        isLoading: false,
        productsByCategory: products,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
  FutureOr<void> _onFetchAllProducts(
    FetchAllProducts event,
    Emitter<CategoryProductState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = await services.getAllProducts();
      emit(state.copyWith(
        isLoading: false,
        allProducts: products,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
