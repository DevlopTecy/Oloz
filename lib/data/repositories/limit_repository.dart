import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/daos/limit_dao.dart';

class LimitRepository {
  const LimitRepository(this._limitDao);

  final LimitDao _limitDao;

  Stream<List<AppLimit>> watchAllLimits() => _limitDao.watchAllLimits();

  Stream<AppLimit?> watchLimit({required String scope, String? package}) {
    return _limitDao.watchLimit(scope: scope, package: package);
  }

  Future<AppLimit?> getLimit({required String scope, String? package}) {
    return _limitDao.getLimit(scope: scope, package: package);
  }

  Future<void> setLimit({
    required String scope,
    String? package,
    int? dailyLimitMs,
    int? dailyLimitReels,
    bool remind = true,
  }) {
    return _limitDao.setLimit(
      scope: scope,
      package: package,
      dailyLimitMs: dailyLimitMs,
      dailyLimitReels: dailyLimitReels,
      remind: remind,
    );
  }

  Future<void> snoozeLimit(int id, int untilMs) {
    return _limitDao.snoozeLimit(id, untilMs);
  }
}
