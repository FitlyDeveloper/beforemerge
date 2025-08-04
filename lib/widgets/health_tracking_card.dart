import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/health_service.dart';

class HealthTrackingCard extends StatefulWidget {
  final bool usePedometer;

  const HealthTrackingCard({
    Key? key,
    this.usePedometer = true,
  }) : super(key: key);

  @override
  State<HealthTrackingCard> createState() => _HealthTrackingCardState();
}

class _HealthTrackingCardState extends State<HealthTrackingCard> {
  final HealthService _healthService = HealthService();

  int _steps = 0;
  double _distance = 0.0; // in km
  double _calories = 0.0;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  @override
  void initState() {
    super.initState();
    _loadCachedData();

    try {
      if (widget.usePedometer) {
        _initPedometer();
      } else {
        _fetchHealthData();
      }
    } catch (e) {
      // Use default placeholder data if integration fails
      _setPlaceholderData();
    }
  }

  void _setPlaceholderData() {
    setState(() {
      _steps = 3568;
      _distance = 2.85;
      _calories = 143.0;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _steps = prefs.getInt('health_steps') ?? 0;
        _distance = prefs.getDouble('health_distance') ?? 0.0;
        _calories = prefs.getDouble('health_calories') ?? 0.0;
      });
    } catch (e) {
      print('Error loading cached health data: $e');
    }
  }

  Future<void> _cacheData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('health_steps', _steps);
      await prefs.setDouble('health_distance', _distance);
      await prefs.setDouble('health_calories', _calories);
    } catch (e) {
      print('Error caching health data: $e');
    }
  }

  void _initPedometer() {
    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(_onStepCount);
      _pedestrianStatusSubscription =
          Pedometer.pedestrianStatusStream.listen(_onPedestrianStatusChanged);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to initialize pedometer: $e');
      _setPlaceholderData();
    }
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
      // Approximate calculations
      _distance = _steps * 0.0008; // Average stride length in km
      _calories = _steps * 0.04; // Average calories burned per step
    });
    _cacheData();
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    // Handle status changes (walking, stopped)
    print('Pedestrian status: ${event.status}');
  }

  Future<void> _fetchHealthData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Request authorization
      bool hasPermission = await _healthService.requestAuthorization();

      if (hasPermission) {
        // Get data for today
        _steps = await _healthService.getStepCount();
        _distance = await _healthService.getDistance();
        _calories = await _healthService.getCaloriesBurned();

        _cacheData();

        setState(() {
          _isLoading = false;
        });
      } else {
        print('Health data authorization not granted');
        _setPlaceholderData();
      }
    } catch (e) {
      print('Error fetching health data: $e');
      _setPlaceholderData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextButton(
                          onPressed: widget.usePedometer
                              ? _initPedometer
                              : _fetchHealthData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMetricRow(
                        Icons.directions_walk,
                        'Steps',
                        '$_steps',
                        _steps / 10000, // Progress based on 10k goal
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        Icons.straighten,
                        'Distance',
                        '${_distance.toStringAsFixed(2)} km',
                        _distance / 5, // Progress based on 5km goal
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        Icons.local_fire_department,
                        'Calories',
                        '${_calories.toStringAsFixed(0)} kcal',
                        _calories / 500, // Progress based on 500 kcal goal
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: widget.usePedometer
                              ? _initPedometer
                              : _fetchHealthData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildMetricRow(
      IconData icon, String label, String value, double progress) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
