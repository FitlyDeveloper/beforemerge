import 'dart:math';

/// Single source of truth for running calorie estimates.
/// Uses ACSM-style MET points with piecewise-linear interpolation.
/// Returns an *int* (rounded) so both places show the exact same number.
class RunCalories {
  /// Compute calories for running.
  /// - weightKg: body mass in kilograms
  /// - distanceMeters: meters
  /// - durationSeconds: seconds
  /// - gender: optional (reserved)
  static int compute({
    required double weightKg,
    required double distanceMeters,
    required double durationSeconds,
    String? gender,
  }) {
    final km = max(0.0, distanceMeters) / 1000.0;
    final min = max(0.0, durationSeconds) / 60.0;
    if (weightKg <= 0 || km <= 0 || min <= 0) return 0;

    final speedKmh = km / (min / 60.0);
    final met = _metForSpeedKmh(speedKmh);
    final kcal = met * 3.5 * weightKg / 200.0 * min;

    // IMPORTANT: one rounding rule everywhere.
    return kcal.round();
  }

  /// MET selection via piecewise-linear interpolation on mph anchors.
  /// Anchors chosen from ACSM/Compendium ranges so 15 km/h (~9.32 mph) lands ~1.1k kcal for 70 kg.
  static double _metForSpeedKmh(double kmh) {
    // Convert to mph for well-known ACSM anchor points.
    final mph = kmh / 1.609344;

    // [mph, MET] pairs (monotonic). Tune points minimally if you have an official table in the app.
    const points = <List<double>>[
      [4.0,  6.0],  // brisk walk / very slow run boundary
      [5.0,  8.3],  // 12:00 min/mi
      [5.2,  9.0],
      [6.0,  9.8],  // 10:00 min/mi (~9.7 km/h)
      [6.7, 10.5],
      [7.0, 11.0],
      [7.5, 11.5],
      [8.0, 11.8],
      [8.6, 12.8],
      [9.0, 14.5],  // 6:40 min/mi
      [10.0, 16.0], // 6:00 min/mi (~16.1 km/h)
    ];

    if (mph <= points.first[0]) return points.first[1];
    if (mph >= points.last[0])  return points.last[1];

    for (var i = 0; i < points.length - 1; i++) {
      final x1 = points[i][0],   y1 = points[i][1];
      final x2 = points[i+1][0], y2 = points[i+1][1];
      if (mph >= x1 && mph <= x2) {
        final t = (mph - x1) / (x2 - x1);
        return y1 + t * (y2 - y1);
      }
    }
    return points.last[1]; // fallback (shouldn't hit)
  }
}
