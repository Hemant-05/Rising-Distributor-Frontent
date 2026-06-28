import 'package:flutter/foundation.dart';
import 'package:raising_india/data/repositories/health_repo.dart';
import 'package:raising_india/error/exceptions.dart';

class HealthService extends ChangeNotifier {
  final HealthRepository _repo = HealthRepository();

  bool _isChecking = false;
  bool get isChecking => _isChecking;

  Map<String, dynamic>? _apiStatus;
  Map<String, dynamic>? get apiStatus => _apiStatus;

  Map<String, dynamic>? _databaseStatus;
  Map<String, dynamic>? get databaseStatus => _databaseStatus;

  String? _error;
  String? get error => _error;

  bool get isApiUp => _statusIsUp(_apiStatus);
  bool get isDatabaseUp => _statusIsUp(_databaseStatus);
  bool get isHealthy => isApiUp && isDatabaseUp;

  Future<bool> checkStatus() async {
    _isChecking = true;
    _error = null;
    notifyListeners();

    try {
      _apiStatus = await _repo.getApiHealth();
      _databaseStatus = await _repo.getDatabaseHealth();
      return isHealthy;
    } on AppError catch (e) {
      _apiStatus ??= {'status': 'DOWN'};
      _error = e.message;
      return false;
    } catch (e) {
      _apiStatus ??= {'status': 'DOWN'};
      _error = e.toString();
      return false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  bool _statusIsUp(Map<String, dynamic>? status) {
    return status?['status']?.toString().toUpperCase() == 'UP';
  }
}
