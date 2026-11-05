import 'package:oloz/data/db/daos/usage_dao.dart';

class UsageRepository {
  const UsageRepository(this._usageDao);

  final UsageDao _usageDao;

  Stream<int> watchTotalTimeForRange({
    required String startDay,
    required String endDay,
    String? platform,
    String? deviceId,
  }) {
    return _usageDao.watchTotalTimeForRange(
      startDay: startDay,
      endDay: endDay,
      platform: platform,
      deviceId: deviceId,
    );
  }

  Future<int> getTotalTimeForRange({
    required String startDay,
    required String endDay,
    String? platform,
    String? deviceId,
  }) {
    return _usageDao.getTotalTimeForRange(
      startDay: startDay,
      endDay: endDay,
      platform: platform,
      deviceId: deviceId,
    );
  }

  Stream<List<AppUsageSummary>> watchAppsSummaryForRange({
    required String startDay,
    required String endDay,
    String? platform,
    int? limit,
  }) {
    return _usageDao.watchAppsSummaryForRange(
      startDay: startDay,
      endDay: endDay,
      platform: platform,
      limit: limit,
    );
  }

  Stream<List<DailyUsagePoint>> watchDailySeries(List<String> days) {
    return _usageDao.watchDailySeries(days);
  }

  Future<void> recordSession({
    required String package,
    required String deviceId,
    required int startMs,
    required int endMs,
    required String day,
  }) {
    return _usageDao.recordSession(
      package: package,
      deviceId: deviceId,
      startMs: startMs,
      endMs: endMs,
      day: day,
    );
  }
}
