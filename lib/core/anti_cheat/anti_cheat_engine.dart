import 'dart:math';

/// Anti-Time-Travel & Sensor Verification Engine
class AntiCheatEngine {
  /// Maximum allowed offline earnings duration (12 hours in seconds)
  static const int maxOfflineSeconds = 12 * 3600;

  /// Calculate valid elapsed time between two sessions, preventing clock rollback
  static int calculateValidElapsedTime({
    required int lastActiveTimestampMs,
    required int currentTimestampMs,
    int? lastUptimeMs,
    int? currentUptimeMs,
  }) {
    final int deltaMs = currentTimestampMs - lastActiveTimestampMs;

    // Detect time travel backwards (User moved system clock to the past)
    if (deltaMs < 0) {
      return 0; // Freeze rewards
    }

    final int deltaSeconds = deltaMs ~/ 1000;

    // If hardware uptime is available, cross-check
    if (lastUptimeMs != null && currentUptimeMs != null) {
      final int uptimeDeltaMs = currentUptimeMs - lastUptimeMs;
      // If system was not rebooted and wall-time jumped ahead of uptime by > 5 minutes
      if (uptimeDeltaMs > 0 && (deltaMs - uptimeDeltaMs) > 300000) {
        return min(maxOfflineSeconds, uptimeDeltaMs ~/ 1000);
      }
    }

    return min(maxOfflineSeconds, deltaSeconds);
  }

  /// Filter out unnatural pedometer frequencies (shake cheat)
  /// Valid human step frequency is between 1.0 Hz and 4.0 Hz
  static bool isValidStepFrequency(double stepsPerSecond) {
    return stepsPerSecond >= 0.5 && stepsPerSecond <= 4.0;
  }
}
