import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/analytics_repo.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/analytics_response.dart';

// Enum to keep UI consistent and type-safe
enum AnalyticsFilter { DAILY, WEEKLY, MONTHLY, ALL_TIME }

class AnalyticsService extends ChangeNotifier {
  final AnalyticsRepository _repo = AnalyticsRepository();

  // State
  AnalyticsResponse? _analyticsData;
  AnalyticsResponse? get analyticsData => _analyticsData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Track current filter to avoid unnecessary reloads
  AnalyticsFilter _currentFilter = AnalyticsFilter.ALL_TIME;
  AnalyticsFilter get currentFilter => _currentFilter;

  // --- Actions ---

  /// Load data based on the selected filter
  Future<void> fetchAnalytics([AnalyticsFilter? filter]) async {
    if (filter != null) {
      _currentFilter = filter;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Convert Enum to String for API (e.g. AnalyticsFilter.ALL_TIME -> "ALL_TIME")
      final String filterString = _currentFilter.name;

      _analyticsData = await _repo.getAnalytics(filterString);

    } on AppError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "Failed to load analytics.";
      debugPrint("Analytics Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper to update filter from UI
  void setFilter(AnalyticsFilter filter) {
    if (_currentFilter == filter) return;
    fetchAnalytics(filter);
  }
}