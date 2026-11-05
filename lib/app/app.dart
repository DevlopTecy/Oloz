import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oloz/app/router.dart';
import 'package:oloz/core/theme/oloz_theme.dart';
import 'package:oloz/data/providers/app_providers.dart';

class OlozApp extends ConsumerWidget {
  const OlozApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Oloz',
      debugShowCheckedModeBanner: false,
      theme: OlozTheme.lightTheme(),
      darkTheme: OlozTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}
