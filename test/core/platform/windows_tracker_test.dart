import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oloz/core/platform/windows_tracker.dart';
import 'package:oloz/data/db/app_database.dart';

class FakeWindowsSystemApi implements WindowsSystemApi {
  String? currentExe = 'chrome.exe';
  int idleSeconds = 0;

  @override
  String? getForegroundProcessName() => currentExe;

  @override
  int getIdleDurationSeconds() => idleSeconds;
}

void main() {
  late AppDatabase db;
  late FakeWindowsSystemApi fakeApi;
  late WindowsForegroundTracker tracker;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeApi = FakeWindowsSystemApi();
    tracker = WindowsForegroundTracker(
      database: db,
      systemApi: fakeApi,
    );
  });

  tearDown(() async {
    await tracker.dispose();
    await db.close();
  });

  group('WindowsForegroundTracker', () {
    test('resolves friendly app labels and categories correctly', () {
      expect(
        WindowsForegroundTracker.resolveFriendlyLabel('chrome.exe'),
        equals('Google Chrome'),
      );
      expect(
        WindowsForegroundTracker.resolveCategory('chrome.exe'),
        equals('browsing'),
      );

      expect(
        WindowsForegroundTracker.resolveFriendlyLabel('Code.exe'),
        equals('Visual Studio Code'),
      );
      expect(
        WindowsForegroundTracker.resolveCategory('Code.exe'),
        equals('utility'),
      );

      expect(
        WindowsForegroundTracker.resolveFriendlyLabel('discord.exe'),
        equals('Discord'),
      );
      expect(
        WindowsForegroundTracker.resolveCategory('discord.exe'),
        equals('messaging'),
      );
    });

    test('tracks foreground sessions and writes to database', () async {
      // 1. Initial poll on chrome.exe at t=1000s
      fakeApi
        ..currentExe = 'chrome.exe'
        ..idleSeconds = 0;
      await tracker.pollOnce(nowMs: 1762416000000);

      // Verify app created
      final apps = await db.select(db.apps).get();
      expect(apps.length, equals(1));
      expect(apps.first.package, equals('chrome.exe'));
      expect(apps.first.label, equals('Google Chrome'));
      expect(apps.first.platform, equals('windows'));

      // 2. Poll 10 minutes later (600,000 ms) while switching to Code.exe
      fakeApi.currentExe = 'code.exe';
      await tracker.pollOnce(nowMs: 1762416600000);

      // Verify session for chrome.exe was flushed and recorded
      final sessions = await db.select(db.sessions).get();
      expect(sessions.length, equals(1));
      expect(sessions.first.package, equals('chrome.exe'));
      expect(sessions.first.startMs, equals(1762416000000));
      expect(sessions.first.endMs, equals(1762416600000));
      expect(sessions.first.deviceId, equals('pc'));

      // Verify daily total rolled up
      final totals = await db.select(db.dailyTotals).get();
      expect(totals.length, equals(1));
      expect(totals.first.foregroundMs, equals(600000));
      expect(totals.first.opens, equals(1));
    });

    test('pauses session when user is idle for >= 120 seconds', () async {
      // Start tracking Spotify
      fakeApi
        ..currentExe = 'spotify.exe'
        ..idleSeconds = 0;
      await tracker.pollOnce(nowMs: 1762416000000);

      // User becomes idle (> 120s) after 5 minutes
      fakeApi.idleSeconds = 150;
      await tracker.pollOnce(nowMs: 1762416300000);

      // Active session should be flushed
      final sessions = await db.select(db.sessions).get();
      expect(sessions.length, equals(1));
      expect(sessions.first.package, equals('spotify.exe'));
      expect(sessions.first.endMs, equals(1762416300000));
    });

    test('splits sessions that cross local midnight cleanly', () async {
      // Session starts at 23:50 (10 minutes before local midnight)
      final baseDate = DateTime(2026, 11, 6);
      final start = DateTime(baseDate.year, baseDate.month, baseDate.day, 23, 50).millisecondsSinceEpoch;
      // Finishes at 00:15 of the next day (25 min total)
      final finish = DateTime(baseDate.year, baseDate.month, baseDate.day + 1, 0, 15).millisecondsSinceEpoch;

      fakeApi
        ..currentExe = 'code.exe'
        ..idleSeconds = 0;
      await tracker.pollOnce(nowMs: start);

      fakeApi.currentExe = 'chrome.exe';
      await tracker.pollOnce(nowMs: finish);

      final sessions = await db.select(db.sessions).get();
      // Should have split into two records at midnight boundary
      expect(sessions.length, equals(2));
      expect(sessions.first.package, equals('code.exe'));
      expect(sessions[1].package, equals('code.exe'));
      expect(sessions.first.day, isNot(equals(sessions[1].day)));
    });
  });
}
