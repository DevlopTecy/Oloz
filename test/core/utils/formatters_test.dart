import 'package:flutter_test/flutter_test.dart';
import 'package:oloz/core/utils/formatters.dart';

void main() {
  group('OlozFormatters', () {
    test('formatDurationMs formats hours and minutes', () {
      // 5h 07m = (5 * 60 + 7) * 60 * 1000 = 18420000 ms
      const ms = (5 * 60 + 7) * 60 * 1000;
      expect(OlozFormatters.formatDurationMs(ms), equals('5h 07m'));
    });

    test('formatDurationMs formats minutes only', () {
      const ms = 45 * 60 * 1000;
      expect(OlozFormatters.formatDurationMs(ms), equals('45m'));
    });

    test('formatDurationMs formats zero', () {
      expect(OlozFormatters.formatDurationMs(0), equals('0m'));
      expect(OlozFormatters.formatDurationMs(-100), equals('0m'));
    });

    test('formatDelta formats positive, negative and zero', () {
      expect(OlozFormatters.formatDelta(-14), equals('−14%'));
      expect(OlozFormatters.formatDelta(8), equals('+8%'));
      expect(OlozFormatters.formatDelta(0), equals('0%'));
    });

    test('splitDurationMs splits correctly', () {
      const ms = (2 * 60 + 15) * 60 * 1000;
      final split = OlozFormatters.splitDurationMs(ms);
      expect(split.hours, equals(2));
      expect(split.minutes, equals(15));
    });
  });
}

