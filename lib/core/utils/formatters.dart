abstract class OlozFormatters {
  /// Formats duration in milliseconds into `5h 07m`, `45m`, or `0m`.
  static String formatDurationMs(int ms) {
    if (ms <= 0) return '0m';
    final totalSeconds = (ms / 1000).round();
    final totalMinutes = (totalSeconds / 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      final paddedMinutes = minutes.toString().padLeft(2, '0');
      return '${hours}h ${paddedMinutes}m';
    }
    return '${minutes}m';
  }

  /// Formats duration breakdown into hours and minutes parts for styled rendering.
  static ({int hours, int minutes}) splitDurationMs(int ms) {
    if (ms <= 0) return (hours: 0, minutes: 0);
    final totalMinutes = (ms / 60000).round();
    return (hours: totalMinutes ~/ 60, minutes: totalMinutes % 60);
  }

  /// Formats delta percentage, e.g. `-14%` or `+8%`.
  /// Uses Unicode minus `−` for negative values.
  static String formatDelta(int percentage) {
    if (percentage == 0) return '0%';
    if (percentage < 0) {
      return '−${percentage.abs()}%';
    }
    return '+$percentage%';
  }

  /// Formats large counts with commas if needed, or simple string.
  static String formatCount(int count) {
    return count.toString();
  }
}

