import 'package:bloc/bloc.dart';
import 'package:raising_india/features/admin/services/sales_analytics_repository.dart';
import 'package:raising_india/models/period_stats_model.dart';
import 'package:raising_india/models/sales_data_model.dart';

part 'sales_analytics_event.dart';
part 'sales_analytics_state.dart';

class SalesAnalyticsBloc extends Bloc<SalesAnalyticsEvent, SalesAnalyticsState> {
  final SalesAnalyticsRepository _repository;

  SalesAnalyticsBloc({required SalesAnalyticsRepository repository})
      : _repository = repository,
        super(SalesAnalyticsInitial()) {

    on<LoadSalesAnalytics>(_onLoadSalesAnalytics);
    on<ChangeSalesTimePeriod>(_onChangeSalesTimePeriod);
    on<RefreshSalesData>(_onRefreshSalesData);
    on<LoadCustomPeriodSales>(_onLoadCustomPeriodSales);
  }

  Future<void> _onLoadSalesAnalytics(
      LoadSalesAnalytics event,
      Emitter<SalesAnalyticsState> emit,
      ) async {
    emit(SalesAnalyticsLoading());

    try {
      final analytics = await _repository.getSalesAnalytics();
      final initialPeriodStats = await _repository.getStatsForPeriod(
        SalesTimePeriod.day,
        DateTime.now(),
      );

      emit(SalesAnalyticsLoaded(
        analytics: analytics,
        currentPeriod: SalesTimePeriod.day,
        currentPeriodData: analytics.dailySales,
        currentPeriodStats: initialPeriodStats,
      ));
    } catch (e) {
      emit(SalesAnalyticsError('Failed to load sales analytics: $e'));
    }
  }

  Future<void> _onChangeSalesTimePeriod(
      ChangeSalesTimePeriod event,
      Emitter<SalesAnalyticsState> emit,
      ) async {
    if (state is SalesAnalyticsLoaded) {
      final currentState = state as SalesAnalyticsLoaded;

      // ✅ Show loading state for period change
      emit(SalesAnalyticsLoading());

      try {
        // ✅ Get period-specific data AND stats
        List<SalesDataModel> periodData;
        switch (event.period) {
          case SalesTimePeriod.day:
            periodData = currentState.analytics.dailySales;
            break;
          case SalesTimePeriod.week:
            periodData = currentState.analytics.weeklySales;
            break;
          case SalesTimePeriod.month:
            periodData = currentState.analytics.monthlySales;
            break;
        }

        // ✅ Fetch stats for the selected period
        final periodStats = await _repository.getStatsForPeriod(
          event.period,
          DateTime.now(),
        );

        emit(currentState.copyWith(
          currentPeriod: event.period,
          currentPeriodData: periodData,
          currentPeriodStats: periodStats, // ✅ Update period-specific stats
        ));
      } catch (e) {
        emit(SalesAnalyticsError('Failed to load period data: $e'));
      }
    }
  }

  Future<void> _onRefreshSalesData(
      RefreshSalesData event,
      Emitter<SalesAnalyticsState> emit,
      ) async {
    add(LoadSalesAnalytics());
  }

  Future<void> _onLoadCustomPeriodSales(
      LoadCustomPeriodSales event,
      Emitter<SalesAnalyticsState> emit,
      ) async {
    if (state is SalesAnalyticsLoaded) {
      emit(SalesAnalyticsLoading());

      try {
        final periodData = await _repository.getSalesForPeriod(
          event.period,
          event.startDate,
          event.endDate,
        );

        final currentState = state as SalesAnalyticsLoaded;
        emit(currentState.copyWith(
          currentPeriod: event.period,
          currentPeriodData: periodData,
        ));
      } catch (e) {
        emit(SalesAnalyticsError('Failed to load custom period data: $e'));
      }
    }
  }
}
