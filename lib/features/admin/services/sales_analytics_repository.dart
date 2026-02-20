/*
// lib/repositories/sales_analytics_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/models/period_stats_model.dart';
import 'package:raising_india/models/sales_data_model.dart';

abstract class SalesAnalyticsRepository {
  Future<SalesAnalyticsModel> getSalesAnalytics();
  Future<List<SalesDataModel>> getSalesForPeriod(SalesTimePeriod period, DateTime startDate, DateTime endDate);
  Future<double> getTotalRevenueForPeriod(DateTime startDate, DateTime endDate);
  Future<SalesAnalyticsModel> getSalesAnalyticsForPeriod(SalesTimePeriod period);
  Future<PeriodStatsModel> getStatsForPeriod(SalesTimePeriod period, DateTime referenceDate);
}

class SalesAnalyticsRepositoryImpl implements SalesAnalyticsRepository {
  final FirebaseFirestore _firestore;

  SalesAnalyticsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<SalesAnalyticsModel> getSalesAnalyticsForPeriod(SalesTimePeriod period) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      List<SalesDataModel> periodData;
      switch (period) {
        case SalesTimePeriod.day:
          periodData = await _getDailySalesForWeek(today);
          break;
        case SalesTimePeriod.week:
          periodData = await _getWeeklySalesForMonth(today);
          break;
        case SalesTimePeriod.month:
          periodData = await _getMonthlySalesForYear(today);
          break;
      }

      final periodStats = await getStatsForPeriod(period, today);

      return SalesAnalyticsModel(
        dailySales: period == SalesTimePeriod.day ? periodData : [],
        weeklySales: period == SalesTimePeriod.week ? periodData : [],
        monthlySales: period == SalesTimePeriod.month ? periodData : [],
        totalRevenue: periodStats.totalRevenue,
        averageOrderValue: periodStats.averageOrderValue,
        totalOrders: periodStats.totalOrders,
        growthPercentage: periodStats.growthPercentage,
      );
    } catch (e) {
      throw Exception('Failed to get sales analytics for period: $e');
    }
  }

  @override
  Future<PeriodStatsModel> getStatsForPeriod(SalesTimePeriod period, DateTime referenceDate) async {
    try {
      DateTime startDate, endDate, previousStartDate, previousEndDate;
      String periodLabel;

      switch (period) {
        case SalesTimePeriod.day:
        // Last 7 days
          startDate = referenceDate.subtract(const Duration(days: 6));
          endDate = referenceDate;
          previousStartDate = referenceDate.subtract(const Duration(days: 13));
          previousEndDate = referenceDate.subtract(const Duration(days: 7));
          periodLabel = 'Last 7 days';
          break;

        case SalesTimePeriod.week:
        // This month (4 weeks)
          startDate = DateTime(referenceDate.year, referenceDate.month, 1);
          endDate = DateTime(referenceDate.year, referenceDate.month + 1, 0);
          previousStartDate = DateTime(referenceDate.year, referenceDate.month - 1, 1);
          previousEndDate = DateTime(referenceDate.year, referenceDate.month, 0);
          periodLabel = 'This month';
          break;

        case SalesTimePeriod.month:
        // This year (12 months)
          startDate = DateTime(referenceDate.year, 1, 1);
          endDate = DateTime(referenceDate.year, 12, 31);
          previousStartDate = DateTime(referenceDate.year - 1, 1, 1);
          previousEndDate = DateTime(referenceDate.year - 1, 12, 31);
          periodLabel = 'This year';
          break;
      }

      // Get current period stats
      final totalRevenue = await getTotalRevenueForPeriod(startDate, endDate);
      final totalOrders = await _getTotalOrdersForPeriod(startDate, endDate);
      final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

      // Get previous period stats for growth calculation
      final previousRevenue = await getTotalRevenueForPeriod(previousStartDate, previousEndDate);
      final growthPercentage = previousRevenue > 0
          ? ((totalRevenue - previousRevenue) / previousRevenue) * 100
          : 0.0;

      return PeriodStatsModel(
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        averageOrderValue: averageOrderValue,
        growthPercentage: growthPercentage,
        periodLabel: periodLabel,
      );
    } catch (e) {
      throw Exception('Failed to get stats for period: $e');
    }
  }

  @override
  Future<SalesAnalyticsModel> getSalesAnalytics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get data for different periods
      final dailySales = await _getDailySalesForWeek(today);
      final weeklySales = await _getWeeklySalesForMonth(today);
      final monthlySales = await _getMonthlySalesForYear(today);

      // Calculate totals
      final totalRevenue = await getTotalRevenueForPeriod(
        today.subtract(const Duration(days: 30)),
        today,
      );

      final totalOrders = await _getTotalOrdersForPeriod(
        today.subtract(const Duration(days: 30)),
        today,
      );

      final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
      final growthPercentage = await _calculateGrowthPercentage(today);

      return SalesAnalyticsModel(
        dailySales: dailySales,
        weeklySales: weeklySales,
        monthlySales: monthlySales,
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
        totalOrders: totalOrders,
        growthPercentage: growthPercentage,
      );
    } catch (e) {
      throw Exception('Failed to get sales analytics: $e');
    }
  }

  Future<List<SalesDataModel>> _getDailySalesForWeek(DateTime today) async {
    final List<SalesDataModel> dailySales = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('paymentStatus', isEqualTo: PayStatusPaid)
          .get();

      double dayTotal = 0.0;
      int ordersCount = querySnapshot.docs.length;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        dayTotal += (data['total'] ?? 0).toDouble();
      }

      dailySales.add(SalesDataModel(
        date: startOfDay,
        amount: dayTotal,
        ordersCount: ordersCount,
      ));
    }

    return dailySales;
  }

  Future<List<SalesDataModel>> _getWeeklySalesForMonth(DateTime today) async {
    final List<SalesDataModel> weeklySales = [];
    final startOfMonth = DateTime(today.year, today.month, 1);

    for (int week = 0; week < 4; week++) {
      final weekStart = startOfMonth.add(Duration(days: week * 7));
      final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final querySnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(weekEnd))
          .where('paymentStatus', isEqualTo: PayStatusPaid)
          .get();

      double weekTotal = 0.0;
      int ordersCount = querySnapshot.docs.length;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        weekTotal += (data['total'] ?? 0).toDouble();
      }

      weeklySales.add(SalesDataModel(
        date: weekStart,
        amount: weekTotal,
        ordersCount: ordersCount,
      ));
    }

    return weeklySales;
  }

  Future<List<SalesDataModel>> _getMonthlySalesForYear(DateTime today) async {
    final List<SalesDataModel> monthlySales = [];

    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(today.year, today.month - i, 1);
      final monthStart = DateTime(monthDate.year, monthDate.month, 1);
      final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(monthEnd))
          .where('paymentStatus', isEqualTo: PayStatusPaid)
          .get();

      double monthTotal = 0.0;
      int ordersCount = querySnapshot.docs.length;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        monthTotal += (data['total'] ?? 0).toDouble();
      }

      monthlySales.add(SalesDataModel(
        date: monthStart,
        amount: monthTotal,
        ordersCount: ordersCount,
      ));
    }

    return monthlySales;
  }

  @override
  Future<List<SalesDataModel>> getSalesForPeriod(SalesTimePeriod period, DateTime startDate, DateTime endDate) async {
    switch (period) {
      case SalesTimePeriod.day:
        return _getDailySalesForWeek(endDate);
      case SalesTimePeriod.week:
        return _getWeeklySalesForMonth(endDate);
      case SalesTimePeriod.month:
        return _getMonthlySalesForYear(endDate);
    }
  }

  @override
  Future<double> getTotalRevenueForPeriod(DateTime startDate, DateTime endDate) async {
    final querySnapshot = await _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('paymentStatus', isEqualTo: PayStatusPaid)
        .get();

    double total = 0.0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      total += (data['total'] ?? 0).toDouble();
    }

    return total;
  }

  Future<int> _getTotalOrdersForPeriod(DateTime startDate, DateTime endDate) async {
    final querySnapshot = await _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('paymentStatus', isEqualTo: PayStatusPaid)
        .get();

    return querySnapshot.docs.length;
  }

  Future<double> _calculateGrowthPercentage(DateTime today) async {
    final thisMonthStart = DateTime(today.year, today.month, 1);
    final lastMonthStart = DateTime(today.year, today.month - 1, 1);
    final lastMonthEnd = DateTime(today.year, today.month, 0, 23, 59, 59);

    final thisMonthRevenue = await getTotalRevenueForPeriod(thisMonthStart, today);
    final lastMonthRevenue = await getTotalRevenueForPeriod(lastMonthStart, lastMonthEnd);

    if (lastMonthRevenue == 0) return 0.0;

    return ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
  }
}
*/
