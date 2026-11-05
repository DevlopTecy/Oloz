import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oloz/app/app.dart';
import 'package:oloz/data/db/app_database.dart';
import 'package:oloz/data/db/fake_data_generator.dart';
import 'package:oloz/data/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final generator = FakeDataGenerator(db);
  await generator.populate();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const OlozApp(),
    ),
  );
}
