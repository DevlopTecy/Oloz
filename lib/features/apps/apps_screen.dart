import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/utils/formatters.dart';
import 'package:oloz/core/widgets/app_icon_tile.dart';
import 'package:oloz/core/widgets/app_row.dart';
import 'package:oloz/core/widgets/week_bars.dart';
import 'package:oloz/data/db/daos/usage_dao.dart';
import 'package:oloz/data/providers/app_providers.dart';
import 'package:oloz/features/apps/set_limit_sheet.dart';

class AppsScreen extends ConsumerStatefulWidget {
  const AppsScreen({super.key});

  @override
  ConsumerState<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends ConsumerState<AppsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedPackage = 'com.instagram.android';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;

    final appsSummaryAsync = ref.watch(appsSummaryProvider);
    final totalTimeAsync = ref.watch(totalTimeProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final selectedDevice = ref.watch(deviceFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final totalMs = totalTimeAsync.value ?? 0;
    const limitMs = 6 * 60 * 60 * 1000; // 6h 00m

    final allApps = appsSummaryAsync.value ?? const <AppUsageSummary>[];
    final filteredApps = allApps.where((app) {
      final name = (app as dynamic).label.toString().toLowerCase();
      final cat = (app as dynamic).category.toString().toLowerCase();
      final platform = (app as dynamic).platform.toString().toLowerCase();

      // Search match
      if (searchQuery.isNotEmpty && !name.contains(searchQuery.toLowerCase())) {
        return false;
      }

      // Device filter match ('all', 'phone', 'pc')
      if (selectedDevice == 'phone' && platform != 'android') return false;
      if (selectedDevice == 'pc' && platform != 'windows') return false;

      // Category filter match ('All', 'Social', 'Browsing', 'Utility')
      if (selectedCategory != 'All') {
        final targetCat = selectedCategory.toLowerCase();
        if (targetCat == 'social' && cat != 'social' && cat != 'video') {
          return false;
        }
        if (targetCat == 'browsing' && cat != 'browsing') return false;
        if (targetCat == 'utility' && cat != 'messaging' && cat != 'utility') {
          return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: isDesktop
            ? _DesktopAppsContent(
                totalMs: totalMs,
                limitMs: limitMs,
                filteredApps: filteredApps,
                selectedPackage: _selectedPackage,
                onSelectPackage: (pkg) =>
                    setState(() => _selectedPackage = pkg),
              )
            : _MobileAppsContent(
                totalMs: totalMs,
                limitMs: limitMs,
                searchCtrl: _searchCtrl,
                filteredApps: filteredApps,
              ),
      ),
    );
  }
}

class _MobileAppsContent extends ConsumerWidget {
  const _MobileAppsContent({
    required this.totalMs,
    required this.limitMs,
    required this.searchCtrl,
    required this.filteredApps,
  });

  final int totalMs;
  final int limitMs;
  final TextEditingController searchCtrl;
  final List<AppUsageSummary> filteredApps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olozColors;
    final selectedCategory = ref.watch(categoryFilterProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: OlozSpacing.screenPaddingMobile,
        vertical: OlozSpacing.s16,
      ),
      children: [
        // Title: "Apps"
        Text(
          'Apps',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: colors.text,
          ),
        ),

        const SizedBox(height: OlozSpacing.s16),

        // Summary row card: "5h 07m" large, single indigo progress bar toward 6h limit, "6h limit"
        Container(
          padding: const EdgeInsets.all(OlozSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      OlozFormatters.formatDurationMs(totalMs),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: colors.text,
                      ),
                    ),
                  ),
                  Text(
                    '6h limit',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OlozSpacing.s12),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 6,
                  color: colors.chartSoft,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (totalMs / limitMs).clamp(0.05, 1.0),
                    child: Container(color: colors.chart),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s16),

        // Search field
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: colors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).setQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search apps',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: colors.text,
                  ),
                ),
              ),
              if (searchCtrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    searchCtrl.clear();
                    ref.read(searchQueryProvider.notifier).setQuery('');
                  },
                  child: Icon(Icons.close, size: 16, color: colors.textSecondary),
                ),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s12),

        // Filter chips (All, Social, Browsing, Utility) - selected chip uses #E3E8F8 with indigo text
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Social', 'Browsing', 'Utility'].map((category) {
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    ref.read(categoryFilterProvider.notifier).select(category);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.chartSoft : colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? colors.chartSoft : colors.border,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? colors.primary : colors.text,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: OlozSpacing.s20),

        if (filteredApps.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: OlozSpacing.s32),
            child: Center(
              child: Text(
                'No apps found',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...filteredApps.map((app) {
          final pkg = (app as dynamic).package as String;
          final name = (app as dynamic).label as String;
          final ms = (app as dynamic).foregroundMs as int;
          final reels = (app as dynamic).reels as int;

          return Padding(
            padding: const EdgeInsets.only(bottom: OlozSpacing.s16),
            child: AppRow(
              name: name,
              package: pkg,
              formattedTime: OlozFormatters.formatDurationMs(ms),
              progress: (ms / (108 * 60 * 1000)).clamp(0.05, 1.0),
              reelsCount: reels > 0 ? reels : null,
              appIcon: _getAppIcon(pkg),
              onTap: () => context.push('/apps/$pkg'),
            ),
          );
        }),
      ],
    );
  }
}

class _DesktopAppsContent extends ConsumerWidget {
  const _DesktopAppsContent({
    required this.totalMs,
    required this.limitMs,
    required this.filteredApps,
    required this.selectedPackage,
    required this.onSelectPackage,
  });

  final int totalMs;
  final int limitMs;
  final List<AppUsageSummary> filteredApps;
  final String selectedPackage;
  final ValueChanged<String> onSelectPackage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olozColors;
    final selectedDevice = ref.watch(deviceFilterProvider);

    // Selected app info
    final selectedApp = filteredApps.firstWhere(
      (a) => a.package == selectedPackage,
      orElse: () => filteredApps.isNotEmpty
          ? filteredApps.first
          : const AppUsageSummary(
              package: 'com.instagram.android',
              label: 'Instagram',
              platform: 'android',
              category: 'social',
              foregroundMs: 108 * 60 * 1000,
              opens: 23,
              reels: 142,
            ),
    );

    final selPkg = (selectedApp as dynamic).package as String;
    final selName = (selectedApp as dynamic).label as String;
    final selMs = (selectedApp as dynamic).foregroundMs as int;
    final selReels = (selectedApp as dynamic).reels as int;
    final selOpens = (selectedApp as dynamic).opens as int;

    const weekBars = [
      DailyBarItem(dayLabel: 'S', value: 1.6, semanticLabel: 'Sat 1h 36m'),
      DailyBarItem(dayLabel: 'S', value: 2.1, semanticLabel: 'Sun 2h 06m'),
      DailyBarItem(dayLabel: 'M', value: 1.8, semanticLabel: 'Mon 1h 48m'),
      DailyBarItem(dayLabel: 'T', value: 1.2, semanticLabel: 'Tue 1h 12m'),
      DailyBarItem(dayLabel: 'W', value: 2.4, semanticLabel: 'Wed 2h 24m'),
      DailyBarItem(dayLabel: 'T', value: 1.9, semanticLabel: 'Thu 1h 54m'),
      DailyBarItem(dayLabel: 'F', value: 1.8, semanticLabel: 'Fri (Today) 1h 48m'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OlozSpacing.screenPaddingDesktop,
        vertical: OlozSpacing.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: "Apps" and "Export" text button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apps',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colors.text,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exported usage summary')),
                  );
                },
                child: Text(
                  'Export',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: OlozSpacing.s16),

          // Device Filter pills: "All", "Phone", "PC"
          Row(
            children: [
              _DesktopFilterPill(
                label: 'All',
                isSelected: selectedDevice == 'all',
                onTap: () =>
                    ref.read(deviceFilterProvider.notifier).select('all'),
                colors: colors,
              ),
              const SizedBox(width: 8),
              _DesktopFilterPill(
                label: 'Phone',
                isSelected: selectedDevice == 'phone',
                onTap: () =>
                    ref.read(deviceFilterProvider.notifier).select('phone'),
                colors: colors,
              ),
              const SizedBox(width: 8),
              _DesktopFilterPill(
                label: 'PC',
                isSelected: selectedDevice == 'pc',
                onTap: () =>
                    ref.read(deviceFilterProvider.notifier).select('pc'),
                colors: colors,
              ),
            ],
          ),

          const SizedBox(height: OlozSpacing.s20),

          // Two column split view: Left table, Right detail panel
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Table of apps
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: "App" and "Time" in sentence case
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OlozSpacing.s20,
                            vertical: OlozSpacing.s12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'App',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textSecondary,
                                ),
                              ),
                              Text(
                                'Time',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: colors.border),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: OlozSpacing.s16,
                              vertical: OlozSpacing.s8,
                            ),
                            itemCount: filteredApps.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final app = filteredApps[index];
                              final pkg = (app as dynamic).package as String;
                              final name = (app as dynamic).label as String;
                              final ms = (app as dynamic).foregroundMs as int;
                              final platform = (app as dynamic).platform as String;
                              final isSelected = pkg == selPkg;

                              return InkWell(
                                onTap: () => onSelectPackage(pkg),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colors.chartSoft
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      AppIconTile(
                                        icon: _getAppIcon(pkg),
                                        size: 32,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: colors.text,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colors.surfaceMuted,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                platform == 'windows' ? 'PC' : 'Phone',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        OlozFormatters.formatDurationMs(ms),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontFeatures: const [
                                            FontFeature.tabularFigures()
                                          ],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: OlozSpacing.s20),

                // Right Panel: App Detail
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(OlozSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                    ),
                    child: ListView(
                      children: [
                        // App icon + Name
                        Row(
                          children: [
                            AppIconTile(
                              icon: _getAppIcon(selPkg),
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selName,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: OlozSpacing.s16),

                        // Time large: 1h 48m
                        Text(
                          OlozFormatters.formatDurationMs(selMs),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: colors.text,
                          ),
                        ),

                        const SizedBox(height: OlozSpacing.s16),

                        // Two mini cards: Reels & Opens
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reels',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$selReels',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ],
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: colors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Opens',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$selOpens',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ],
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: colors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: OlozSpacing.s20),

                        // 7-day chart with visible bars & day letters
                        Text(
                          'This week',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const WeekBars(
                          items: weekBars,
                        ),

                        const SizedBox(height: OlozSpacing.s20),

                        // "Break reminder" row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Break reminder',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors.text,
                                ),
                              ),
                              Text(
                                'Every 15m',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: OlozSpacing.s20),

                        // Button "Set limit" #5870C2
                        SizedBox(
                          height: 44,
                          child: FilledButton(
                            onPressed: () {
                              unawaited(
                                SetLimitSheet.show(
                                  context,
                                  package: selPkg,
                                  appName: selName,
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Set limit',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopFilterPill extends StatelessWidget {
  const _DesktopFilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final OlozColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.chartSoft : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colors.chartSoft : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? colors.primary : colors.text,
          ),
        ),
      ),
    );
  }
}

IconData _getAppIcon(String package) {
  if (package.contains('instagram')) return Icons.camera_alt_outlined;
  if (package.contains('musically') || package.contains('tiktok')) {
    return Icons.music_note_outlined;
  }
  if (package.contains('youtube')) return Icons.play_arrow_outlined;
  if (package.contains('facebook')) return Icons.thumb_up_alt_outlined;
  if (package.contains('twitter')) return Icons.close_outlined;
  if (package.contains('chrome')) return Icons.circle_outlined;
  if (package.contains('whatsapp')) return Icons.chat_bubble_outline;
  if (package.contains('reddit')) return Icons.reddit_outlined;
  return Icons.apps_outlined;
}
