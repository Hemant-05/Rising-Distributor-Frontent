import 'package:bloc/bloc.dart';
import 'package:raising_india/features/admin/services/order_repository.dart';
import 'package:raising_india/features/services/review_repository.dart';
import 'package:raising_india/models/order_model.dart';
import 'package:raising_india/models/review_model.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository _reviewRepository;
  final OrderRepository _orderRepository;

  ReviewBloc({
    required ReviewRepository reviewRepository,
    required OrderRepository orderRepository,
  })  : _reviewRepository = reviewRepository,
        _orderRepository = orderRepository,
        super(ReviewInitial()) {

    on<LoadOrderForReview>(_onLoadOrderForReview);
    on<UpdateServiceRating>(_onUpdateServiceRating);
    on<UpdateProductRating>(_onUpdateProductRating);
    on<UpdateServiceReview>(_onUpdateServiceReview);
    on<UpdateProductReview>(_onUpdateProductReview);
    on<SubmitReview>(_onSubmitReview);
    on<UpdateExistingReview>(_onUpdateExistingReview);
    on<CheckOrderReviewStatus>(_onCheckOrderReviewStatus);
  }

  Future<void> _onLoadOrderForReview(
      LoadOrderForReview event,
      Emitter<ReviewState> emit,
      ) async {
    emit(ReviewLoading());

    try {
      final order = await _orderRepository.getOrderById(event.orderId);
      if (order != null) {
        // Check if review already exists
        final existingReview = await _reviewRepository.getOrderReview(event.orderId);

        if (existingReview != null) {
          emit(OrderLoadedForReview(
            order: order.order,
            serviceRating: existingReview.serviceRating,
            productRating: existingReview.productRating,
            serviceReview: existingReview.serviceReview,
            productReview: existingReview.productReview,
            hasExistingReview: true,
            existingReviewId: existingReview.id, // ✅ Store existing review ID
          ));
        } else {
          emit(OrderLoadedForReview(order: order.order));
        }
      } else {
        emit(ReviewError('Order not found'));
      }
    } catch (e) {
      emit(ReviewError('Failed to load order: $e'));
    }
  }

  void _onUpdateServiceRating(
      UpdateServiceRating event,
      Emitter<ReviewState> emit,
      ) {
    if (state is OrderLoadedForReview) {
      final currentState = state as OrderLoadedForReview;
      emit(currentState.copyWith(serviceRating: event.rating));
    }
  }

  void _onUpdateProductRating(
      UpdateProductRating event,
      Emitter<ReviewState> emit,
      ) {
    if (state is OrderLoadedForReview) {
      final currentState = state as OrderLoadedForReview;
      emit(currentState.copyWith(productRating: event.rating));
    }
  }

  void _onUpdateServiceReview(
      UpdateServiceReview event,
      Emitter<ReviewState> emit,
      ) {
    if (state is OrderLoadedForReview) {
      final currentState = state as OrderLoadedForReview;
      emit(currentState.copyWith(serviceReview: event.review));
    }
  }

  void _onUpdateProductReview(
      UpdateProductReview event,
      Emitter<ReviewState> emit,
      ) {
    if (state is OrderLoadedForReview) {
      final currentState = state as OrderLoadedForReview;
      emit(currentState.copyWith(productReview: event.review));
    }
  }

  Future<void> _onUpdateExistingReview(
      UpdateExistingReview event,
      Emitter<ReviewState> emit,
      ) async {
    if (state is! OrderLoadedForReview) return;

    final currentState = state as OrderLoadedForReview;

    // Validation
    if (currentState.serviceRating == 0.0 || currentState.productRating == 0.0) {
      emit(ReviewError('Please provide both service and product ratings'));
      return;
    }

    emit(ReviewSubmitting());

    try {
      final review = ReviewModel(
        id: event.reviewId,
        orderId: event.orderId,
        userId: event.userId,
        userName: event.userName,
        serviceRating: currentState.serviceRating,
        productRating: currentState.productRating,
        serviceReview: currentState.serviceReview,
        productReview: currentState.productReview,
        createdAt: DateTime.now(),
        productIds: event.productIds,
      );

      await _reviewRepository.updateReview(review);
      emit(ReviewSubmitted('Your review has been updated successfully!'));
    } catch (e) {
      emit(ReviewError('Failed to update review: $e'));
    }
  }

  Future<void> _onSubmitReview(
      SubmitReview event,
      Emitter<ReviewState> emit,
      ) async {
    if (state is! OrderLoadedForReview) return;

    final currentState = state as OrderLoadedForReview;

    // Validation
    if (currentState.serviceRating == 0.0 || currentState.productRating == 0.0) {
      emit(ReviewError('Please provide both service and product ratings'));
      return;
    }

    emit(ReviewSubmitting());

    try {
      final review = ReviewModel(
        id: currentState.existingReviewId ?? '', // ✅ Use existing ID if available
        orderId: event.orderId,
        userId: event.userId,
        userName: event.userName,
        serviceRating: currentState.serviceRating,
        productRating: currentState.productRating,
        serviceReview: currentState.serviceReview,
        productReview: currentState.productReview,
        createdAt: DateTime.now(),
        productIds: event.productIds,
      );

      await _reviewRepository.submitReview(review);

      // ✅ Different success messages for create vs update
      final successMessage = currentState.hasExistingReview
          ? 'Your review has been updated successfully!'
          : 'Thank you for your review! Your feedback helps us improve.';

      emit(ReviewSubmitted(successMessage));
    } catch (e) {
      emit(ReviewError('Failed to ${currentState.hasExistingReview ? "update" : "submit"} review: $e'));
    }
  }

  Future<void> _onCheckOrderReviewStatus(
      CheckOrderReviewStatus event,
      Emitter<ReviewState> emit,
      ) async {
    try {
      final hasReviewed = await _reviewRepository.hasUserReviewedOrder(
        event.userId,
        event.orderId,
      );
      // You can emit a specific state here if needed
    } catch (e) {
      // Handle error silently
    }
  }
}
