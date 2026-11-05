import 'package:oloz/data/db/daos/reel_dao.dart';

class ReelRepository {
  const ReelRepository(this._reelDao);

  final ReelDao _reelDao;

  Stream<int> watchTotalReelsForRange({
    required String startDay,
    required String endDay,
    String? deviceId,
  }) {
    return _reelDao.watchTotalReelsForRange(
      startDay: startDay,
      endDay: endDay,
      deviceId: deviceId,
    );
  }

  Stream<List<PlatformReelSummary>> watchReelsByPlatformForRange({
    required String startDay,
    required String endDay,
  }) {
    return _reelDao.watchReelsByPlatformForRange(
      startDay: startDay,
      endDay: endDay,
    );
  }

  Stream<List<DailyReelPoint>> watchDailyReelSeries(List<String> days) {
    return _reelDao.watchDailyReelSeries(days);
  }

  Future<void> recordReelEvent({
    required String package,
    required String deviceId,
    required int atMs,
    required int dwellMs,
    required String day,
  }) {
    return _reelDao.recordReelEvent(
      package: package,
      deviceId: deviceId,
      atMs: atMs,
      dwellMs: dwellMs,
      day: day,
    );
  }
}

