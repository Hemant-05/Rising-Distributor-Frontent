import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/health_service.dart';
import 'package:raising_india/services/service_locator.dart';

class ServerDownScreen extends StatefulWidget {
  const ServerDownScreen({super.key});

  @override
  State<ServerDownScreen> createState() => _ServerDownScreenState();
}

class _ServerDownScreenState extends State<ServerDownScreen> {
  final HealthService _healthService = getIt<HealthService>();

  bool _isChecking = false;
  bool? _apiUp;
  bool? _databaseUp;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStatus());
  }

  Future<void> _checkStatus({bool closeWhenHealthy = false}) async {
    setState(() {
      _isChecking = true;
      _error = null;
    });

    final isHealthy = await _healthService.checkStatus();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      _apiUp = _healthService.isApiUp;
      _databaseUp = _healthService.isDatabaseUp;
      _error = _healthService.error;
    });

    if (isHealthy && closeWhenHealthy && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = _apiUp == true && _databaseUp == true;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isHealthy
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_off_rounded,
                  size: 96,
                  color: isHealthy ? Colors.green : Colors.orange.shade300,
                ),
                const SizedBox(height: 24),
                Text(
                  isHealthy ? 'Server is Back Online' : 'Server is Unreachable',
                  style: simple_text_style(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColour.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We could not reach the backend right now. The checks below test the API and database connection directly.',
                  style: simple_text_style(
                    isEllipsisAble: false,
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _StatusTile(label: 'API service', isUp: _apiUp),
                const SizedBox(height: 12),
                _StatusTile(label: 'Database connection', isUp: _databaseUp),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: simple_text_style(
                      isEllipsisAble: false,
                      fontSize: 13,
                      color: Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColour.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isChecking
                        ? null
                        : () => _checkStatus(closeWhenHealthy: true),
                    child: _isChecking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isHealthy ? 'Continue' : 'Try Again',
                            style: simple_text_style(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.label, required this.isUp});

  final String label;
  final bool? isUp;

  @override
  Widget build(BuildContext context) {
    final icon = isUp == null
        ? Icons.sync_rounded
        : isUp!
        ? Icons.check_circle_rounded
        : Icons.error_rounded;
    final color = isUp == null
        ? Colors.grey
        : isUp!
        ? Colors.green
        : Colors.red;
    final text = isUp == null
        ? 'Checking'
        : isUp!
        ? 'UP'
        : 'DOWN';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: simple_text_style(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            text,
            style: simple_text_style(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
