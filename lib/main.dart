import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oloz/app/app.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  // Clean any old legacy fake data (TikTok, 2026 mock dates)
  await (db.delete(db.sessions)
        ..where((tbl) =>
            tbl.package.equals('com.zhiliaoapp.musically') |
            tbl.day.equals('2026-11-06')))
      .go();
  await (db.delete(db.dailyTotals)
        ..where((tbl) =>
            tbl.package.equals('com.zhiliaoapp.musically') |
            tbl.day.equals('2026-11-06')))
      .go();
  await (db.delete(db.apps)
        ..where((tbl) => tbl.package.equals('com.zhiliaoapp.musically')))
      .go();

  final onboardedVal = await db.settingsDao.getSetting('onboarded');
  final initialLocation =
      onboardedVal == 'true' ? '/home' : '/onboarding/welcome';

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: OlozApp(initialLocation: initialLocation),
    ),
  );
}
