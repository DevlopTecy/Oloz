import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:oloz/core/platform/tracking_service.dart';
import 'package:oloz/core/platform/windows_tracker.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/daos/reel_dao.dart';
import 'package:oloz/data/db/daos/usage_dao.dart';
import 'package:oloz/data/repositories/limit_repository.dart';
import 'package:oloz/data/repositories/reel_repository.dart';
import 'package:oloz/data/repositories/settings_repository.dart';
import 'package:oloz/data/repositories/usage_repository.dart';

/// Database instance provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden');
});

/// Repositories.
final usageRepositoryProvider = Provider<UsageRepository>((ref) {
  return UsageRepository(ref.watch(databaseProvider).usageDao);
});

final reelRepositoryProvider = Provider<ReelRepository>((ref) {
  return ReelRepository(ref.watch(databaseProvider).reelDao);
});

final limitRepositoryProvider = Provider<LimitRepository>((ref) {
  return LimitRepository(ref.watch(databaseProvider).limitDao);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider).settingsDao);
});

/// Native tracking service.
final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService();
});

/// Native app icon bytes provider (family by package name).
final appIconBytesProvider =
    FutureProvider.family<Uint8List?, String>((ref, package) async {
  final tracking = ref.watch(trackingServiceProvider);
  return await tracking.getAppIcon(package);
});

/// Windows Foreground Tracker provider.
final windowsTrackerProvider = Provider<WindowsForegroundTracker>((ref) {
  final db = ref.watch(databaseProvider);
  final tracker = WindowsForegroundTracker(database: db);
  ref.onDispose(tracker.dispose);
  return tracker;
});

/// Time range selection (Day, Week, Month).
enum TimeRange {
  day,
  week,
  month;

  String get label => switch (this) {
        TimeRange.day => 'Day',
        TimeRange.week => 'Week',
        TimeRange.month => 'Month',
      };
}

class RangeNotifier extends Notifier<TimeRange> {
  @override
  TimeRange build() => TimeRange.day;

  void select(TimeRange range) => state = range;
}

final rangeProvider =
    NotifierProvider<RangeNotifier, TimeRange>(RangeNotifier.new);

/// Device filter selection ('all', 'phone', 'pc').
class DeviceFilterNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void select(String filter) => state = filter;
}

final deviceFilterProvider =
    NotifierProvider<DeviceFilterNotifier, String>(DeviceFilterNotifier.new);

/// Category filter selection ('All', 'Social', 'Browsing', 'Utility').
class CategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void select(String category) => state = category;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, String>(CategoryFilterNotifier.new);

/// Search query notifier for apps list.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Reference date anchor (defaults to current local date).
final referenceDateProvider =
    Provider<DateTime>((ref) => DateTime.now());

/// Computed (startDay, endDay) string tuple based on range selection.
final dateRangeProvider = Provider<(String start, String end)>((ref) {
  final range = ref.watch(rangeProvider);
  final refDate = ref.watch(referenceDateProvider);
  final fmt = DateFormat('yyyy-MM-dd');
  final endStr = fmt.format(refDate);

  final startStr = switch (range) {
    TimeRange.day => endStr,
    TimeRange.week => fmt.format(refDate.subtract(const Duration(days: 6))),
    TimeRange.month => fmt.format(refDate.subtract(const Duration(days: 29))),
  };

  return (startStr, endStr);
});

/// Total foreground time (ms) for selected date range and device filter.
final totalTimeProvider = StreamProvider<int>((ref) {
  final range = ref.watch(dateRangeProvider);
  final device = ref.watch(deviceFilterProvider);
  final deviceId = device == 'all'
      ? null
      : (device == 'phone' ? 'phone-device-id' : 'pc-device-id');

  return ref.watch(usageRepositoryProvider).watchTotalTimeForRange(
        startDay: range.$1,
        endDay: range.$2,
        deviceId: deviceId,
      );
});

/// Total reels count for selected date range and device filter.
final totalReelsProvider = StreamProvider<int>((ref) {
  final range = ref.watch(dateRangeProvider);
  final device = ref.watch(deviceFilterProvider);
  final deviceId = device == 'all'
      ? null
      : (device == 'phone' ? 'phone-device-id' : 'pc-device-id');

  return ref.watch(reelRepositoryProvider).watchTotalReelsForRange(
        startDay: range.$1,
        endDay: range.$2,
        deviceId: deviceId,
      );
});

/// Week offset for historical weekly chart browsing (0 = current week, -1 = last week, etc.)
class WeekOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void nextWeek() {
    if (state < 0) state++;
  }

  void previousWeek() {
    state--;
  }

  void reset() {
    state = 0;
  }
}

final weekOffsetProvider =
    NotifierProvider<WeekOffsetNotifier, int>(WeekOffsetNotifier.new);

/// 7-day daily series ending on reference date + week offset.
final weekSeriesProvider = StreamProvider<List<DailyUsagePoint>>((ref) {
  final refDate = ref.watch(referenceDateProvider);
  final offset = ref.watch(weekOffsetProvider);
  final anchor = refDate.add(Duration(days: offset * 7));
  final fmt = DateFormat('yyyy-MM-dd');
  final days = List.generate(
    7,
    (i) => fmt.format(anchor.subtract(Duration(days: 6 - i))),
  );
  return ref.watch(usageRepositoryProvider).watchDailySeries(days);
});

/// 30-day daily reels count ending on reference date.
final thirtyDayReelsProvider = StreamProvider<List<DailyReelPoint>>((ref) {
  final refDate = ref.watch(referenceDateProvider);
  final fmt = DateFormat('yyyy-MM-dd');
  final days = List.generate(
    30,
    (i) => fmt.format(refDate.subtract(Duration(days: 29 - i))),
  );
  return ref.watch(reelRepositoryProvider).watchDailyReelSeries(days);
});

/// Platform split for reels during selected range.
final platformSplitProvider =
    StreamProvider<List<PlatformReelSummary>>((ref) {
  final range = ref.watch(dateRangeProvider);
  return ref.watch(reelRepositoryProvider).watchReelsByPlatformForRange(
        startDay: range.$1,
        endDay: range.$2,
      );
});

/// Apps summary list for selected range and device filter.
final appsSummaryProvider = StreamProvider<List<AppUsageSummary>>((ref) {
  final range = ref.watch(dateRangeProvider);
  final device = ref.watch(deviceFilterProvider);
  final platform = device == 'phone' ? 'android' : (device == 'pc' ? 'windows' : null);

  return ref.watch(usageRepositoryProvider).watchAppsSummaryForRange(
        startDay: range.$1,
        endDay: range.$2,
        platform: platform,
      );
});

/// All configured limits.
final limitsProvider = StreamProvider<List<AppLimit>>((ref) {
  return ref.watch(limitRepositoryProvider).watchAllLimits();
});

/// Daily reels limit provider (defaults to 350).
final reelsLimitProvider = StreamProvider<int>((ref) {
  return ref
      .watch(limitRepositoryProvider)
      .watchLimit(scope: 'reels_total')
      .map((limit) => limit?.dailyLimitReels ?? 350);
});

/// Daily total screen time limit provider in ms (defaults to 6 hours = 360m).
final screenTimeLimitProvider = StreamProvider<int>((ref) {
  return ref
      .watch(limitRepositoryProvider)
      .watchLimit(scope: 'total')
      .map((limit) => limit?.dailyLimitMs ?? (6 * 60 * 60 * 1000));
});

/// Limit for a specific package.
final appLimitProvider =
    StreamProvider.family<AppLimit?, String>((ref, package) {
  return ref.watch(limitRepositoryProvider).watchLimit(
        scope: 'app',
        package: package,
      );
});

/// Daily 7-day usage series for a specific app package ending on reference date.
final appDailySeriesProvider =
    StreamProvider.family<List<DailyUsagePoint>, String>((ref, package) {
  final refDate = ref.watch(referenceDateProvider);
  final fmt = DateFormat('yyyy-MM-dd');
  final days = List.generate(
    7,
    (i) => fmt.format(refDate.subtract(Duration(days: 6 - i))),
  );
  return ref
      .watch(usageRepositoryProvider)
      .watchDailySeriesForPackage(package, days);
});

/// Usage summary for a specific app package on referenceDate (Today).
final appDetailSummaryProvider =
    StreamProvider.family<AppUsageSummary?, String>((ref, package) {
  final refDate = ref.watch(referenceDateProvider);
  final fmt = DateFormat('yyyy-MM-dd');
  final todayStr = fmt.format(refDate);
  return ref.watch(usageRepositoryProvider).watchAppSummaryForPackage(
        package: package,
        startDay: todayStr,
        endDay: todayStr,
      );
});

/// Theme mode notifier (Light / Dark / System).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void setThemeMode(ThemeMode mode) => state = mode;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
