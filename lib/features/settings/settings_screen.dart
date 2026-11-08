import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:oloz/core/platform/tracking_service.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/widgets/oloz_toggle.dart';
import 'package:oloz/core/widgets/segmented_pill.dart';
import 'package:oloz/data/providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _launchWithWindows = true;
  bool _showInTray = true;
  bool _floatingIndicator = false;
  String _reminderText = 'Every 15m';

  TrackingPermissionsStatus? _permissions;
  String _deviceModel = '';
  String _deviceOs = '';

  @override
  void initState() {
    super.initState();
    unawaited(_loadState());
  }

  Future<void> _loadState() async {
    final tracking = ref.read(trackingServiceProvider);
    final perms = await tracking.checkPermissions();
    final overlayShowing = await tracking.isOverlayShowing();
    final devInfo = await tracking.getDeviceInfo();

    if (mounted) {
      setState(() {
        _permissions = perms;
        _floatingIndicator = overlayShowing;
        _deviceModel = devInfo['model'] ?? '';
        _deviceOs = devInfo['androidVersion'] ?? devInfo['os'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;
    final currentThemeMode = ref.watch(themeModeProvider);

    final screenMs =
        ref.watch(screenTimeLimitProvider).value ?? (6 * 60 * 60 * 1000);
    final reelsLimit = ref.watch(reelsLimitProvider).value ?? 350;
    final screenHours = screenMs ~/ (60 * 60 * 1000);
    final goalsLabel = screenMs == (6 * 60 * 60 * 1000) && reelsLimit == 350
        ? '6h · 350 reels'
        : '${screenHours > 0 ? '${screenHours}h' : '${screenMs ~/ (60 * 1000)}m'} · $reelsLimit reels';

    final themeIndex = switch (currentThemeMode) {
      ThemeMode.light => 0,
      ThemeMode.dark => 1,
      ThemeMode.system => 2,
    };

    final allPermsGranted = _permissions == null ||
        (_permissions!.usageStats &&
            _permissions!.accessibility &&
            _permissions!.overlay);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: "Settings"
        Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isDesktop ? 28 : 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: colors.text,
          ),
        ),

        const SizedBox(height: OlozSpacing.s16),

        // Profile row: initials avatar "YA", "Your account", "Synced" chip
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OlozSpacing.s16,
            vertical: OlozSpacing.s12,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.surfaceMuted,
                child: Text(
                  'YA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              ),
              const SizedBox(width: OlozSpacing.s12),
              Expanded(
                child: Text(
                  'Your account',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.chartSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Synced',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s24),

        // Group: "Preferences"
        Text(
          'Preferences',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),

        const SizedBox(height: OlozSpacing.s12),

        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // Goals and limits
              InkWell(
                onTap: () => context.push('/onboarding/goal'),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(OlozSpacing.s16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Goals and limits',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.text,
                          ),
                        ),
                      ),
                      Text(
                        goalsLabel,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: colors.border),

              // Notifications
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OlozSpacing.s16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.text,
                      ),
                    ),
                    OlozToggle(
                      value: _notifications,
                      onChanged: (val) => setState(() => _notifications = val),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),

              // Floating indicator (R: , T:)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OlozSpacing.s16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Floating indicator (R: , T:)',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.text,
                            ),
                          ),
                          Text(
                            'Displays live pill with reels and time on screen',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OlozToggle(
                      value: _floatingIndicator,
                      onChanged: (val) async {
                        final tracking = ref.read(trackingServiceProvider);
                        if (val) {
                          final perms = await tracking.checkPermissions();
                          if (!perms.overlay) {
                            await tracking.requestOverlayPermission();
                            return;
                          }
                          final ms = ref.read(totalTimeProvider).value ?? 0;
                          final reels =
                              ref.read(totalReelsProvider).value ?? 0;
                          await tracking.showOverlayCounter(
                            count: reels,
                            minutes: ms ~/ (60 * 1000),
                          );
                          setState(() => _floatingIndicator = true);
                        } else {
                          await tracking.hideOverlayCounter();
                          setState(() => _floatingIndicator = false);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),

              // Theme (segmented Light / Dark / Auto on the same row)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OlozSpacing.s16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.text,
                      ),
                    ),
                    SegmentedPill(
                      options: const ['Light', 'Dark', 'Auto'],
                      selectedIndex: themeIndex,
                      horizontalPadding: 8,
                      verticalPadding: 4,
                      onChanged: (idx) {
                        final mode = switch (idx) {
                          0 => ThemeMode.light,
                          1 => ThemeMode.dark,
                          _ => ThemeMode.system,
                        };
                        ref.read(themeModeProvider.notifier).setThemeMode(mode);
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),

              // Permissions
              InkWell(
                onTap: _showPermissionsSheet,
                child: Padding(
                  padding: const EdgeInsets.all(OlozSpacing.s16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permissions',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            allPermsGranted
                                ? 'Active & granted'
                                : 'Tap to manage permissions',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: allPermsGranted
                                  ? colors.primary
                                  : colors.error,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        allPermsGranted
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        size: 20,
                        color: allPermsGranted ? colors.primary : colors.error,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: colors.border),

              // Reminders
              InkWell(
                onTap: _showRemindersSheet,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(OlozSpacing.s16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications_none,
                              size: 20, color: colors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Reminders',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.text,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _reminderText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s24),

        // Group: "Devices"
        Text(
          'Devices',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),

        const SizedBox(height: OlozSpacing.s12),

        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // This phone (Live)
              Padding(
                padding: const EdgeInsets.all(OlozSpacing.s16),
                child: Row(
                  children: [
                    Icon(Icons.smartphone,
                        size: 20, color: colors.textSecondary),
                    const SizedBox(width: OlozSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This phone',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.text,
                            ),
                          ),
                          if (_deviceModel.isNotEmpty)
                            Text(
                              '$_deviceModel · $_deviceOs',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.chartSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Live',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),

              // Windows PC (Synced 2m ago)
              Padding(
                padding: const EdgeInsets.all(OlozSpacing.s16),
                child: Row(
                  children: [
                    Icon(Icons.desktop_windows_outlined,
                        size: 20, color: colors.textSecondary),
                    const SizedBox(width: OlozSpacing.s12),
                    Expanded(
                      child: Text(
                        'Windows PC',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.text,
                        ),
                      ),
                    ),
                    Text(
                      'Synced 2m ago',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Desktop Startup group
        if (isDesktop) ...[
          const SizedBox(height: OlozSpacing.s24),
          Text(
            'Startup',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: OlozSpacing.s12),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                // Launch with Windows
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OlozSpacing.s16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Launch with Windows',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.text,
                        ),
                      ),
                      OlozToggle(
                        value: _launchWithWindows,
                        onChanged: (val) =>
                            setState(() => _launchWithWindows = val),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.border),

                // Show in tray
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OlozSpacing.s16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Show in tray',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.text,
                        ),
                      ),
                      OlozToggle(
                        value: _showInTray,
                        onChanged: (val) => setState(() => _showInTray = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: OlozSpacing.s24),

        // Data & Diagnostics group
        Text(
          'Diagnostics & Data',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),

        const SizedBox(height: OlozSpacing.s12),

        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => context.push('/settings/debug'),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(OlozSpacing.s16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bug_report_outlined,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: OlozSpacing.s12),
                      Expanded(
                        child: Text(
                          'Reel event logger',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.text,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: colors.border),
              InkWell(
                onTap: _showResetDataDialog,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(OlozSpacing.s16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: colors.error,
                      ),
                      const SizedBox(width: OlozSpacing.s12),
                      Expanded(
                        child: Text(
                          "Reset today's tracking data",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.error,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s24),

        // Privacy & About group
        Text(
          'Privacy & About',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),

        const SizedBox(height: OlozSpacing.s12),

        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // Privacy policy
              InkWell(
                onTap: () => _showPrivacyPolicy(context),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(OlozSpacing.s16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: OlozSpacing.s12),
                      Expanded(
                        child: Text(
                          'Privacy policy',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.text,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: colors.border),

              // Version & Build info
              Padding(
                padding: const EdgeInsets.all(OlozSpacing.s16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: OlozSpacing.s12),
                    Expanded(
                      child: Text(
                        'Version',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.text,
                        ),
                      ),
                    ),
                    Text(
                      '1.0.0+1',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: OlozSpacing.s32),
      ],
    );

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: isDesktop
            ? SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: OlozSpacing.screenPaddingDesktop,
                  vertical: OlozSpacing.s24,
                ),
                child: Center(
                  child: SizedBox(
                    width: 640,
                    child: content,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: OlozSpacing.screenPaddingMobile,
                  vertical: OlozSpacing.s16,
                ),
                children: [content],
              ),
      ),
    );
  }

  void _showPermissionsSheet() {
    final tracking = ref.read(trackingServiceProvider);
    final colors = context.olozColors;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => StatefulBuilder(
          builder: (context, setSheetState) {
            final perms = _permissions;
            return Padding(
              padding: const EdgeInsets.all(OlozSpacing.s20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permissions & System Access',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'All tracking is performed offline and securely on your device.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: OlozSpacing.s16),
                  _buildPermTile(
                    title: 'Usage Access',
                    subtitle: 'Tracks app screen time and opens',
                    isGranted: perms?.usageStats ?? false,
                    onGrant: () async {
                      await tracking.requestUsageAccess();
                      await _loadState();
                      setSheetState(() {});
                    },
                    colors: colors,
                  ),
                  _buildPermTile(
                    title: 'Accessibility Service',
                    subtitle: 'Detects vertical video swipes (Reels & Shorts)',
                    isGranted: perms?.accessibility ?? false,
                    onGrant: () async {
                      await tracking.requestAccessibility();
                      await _loadState();
                      setSheetState(() {});
                    },
                    colors: colors,
                  ),
                  _buildPermTile(
                    title: 'Display Over Other Apps',
                    subtitle: 'Shows floating pill indicator (R: , T:)',
                    isGranted: perms?.overlay ?? false,
                    onGrant: () async {
                      await tracking.requestOverlayPermission();
                      await _loadState();
                      setSheetState(() {});
                    },
                    colors: colors,
                  ),
                  const SizedBox(height: OlozSpacing.s16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPermTile({
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onGrant,
    required OlozColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isGranted)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.chartSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Granted',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(60, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onGrant,
              child: const Text('Grant'),
            ),
        ],
      ),
    );
  }

  void _showRemindersSheet() {
    final colors = context.olozColors;
    final options = ['Every 15m', 'Every 30m', 'Every 45m', 'Every 1h', 'Off'];

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(OlozSpacing.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Break Reminders',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Receive a subtle reminder when continuing screen sessions.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: OlozSpacing.s16),
              ...options.map(
                (opt) => ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: opt == _reminderText
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: opt == _reminderText ? colors.primary : colors.text,
                    ),
                  ),
                  trailing: opt == _reminderText
                      ? Icon(Icons.check_rounded, color: colors.primary)
                      : null,
                  onTap: () {
                    setState(() => _reminderText = opt);
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDataDialog() {
    final colors = context.olozColors;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colors.border),
          ),
          title: Text(
            "Reset Today's Data?",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          content: Text(
            "This will reset today's tracked foreground time, opens, and reels count back to 0 in your local database.",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: colors.textSecondary,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                final db = ref.read(databaseProvider);
                final refDate = ref.read(referenceDateProvider);
                final todayStr = DateFormat('yyyy-MM-dd').format(refDate);

                await (db.delete(db.dailyTotals)
                      ..where((tbl) => tbl.day.equals(todayStr)))
                    .go();
                await (db.delete(db.sessions)
                      ..where((tbl) => tbl.day.equals(todayStr)))
                    .go();
                await (db.delete(db.reelEvents)
                      ..where((tbl) => tbl.day.equals(todayStr)))
                    .go();

                final tracking = ref.read(trackingServiceProvider);
                await tracking.updateTrackingNotification(
                  reels: 0,
                  minutes: 0,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Today's stats reset to 0."),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    final colors = context.olozColors;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colors.border),
          ),
          title: Text(
            'Privacy Policy',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Oloz is offline-first and calm by design.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• No window titles or URLs are ever recorded.\n'
                    '• No text, keystrokes, messages, or screen content are ever inspected.\n'
                    '• The accessibility service strictly inspects layout IDs to count short-form video scrolls.\n'
                    '• Only daily aggregates sync to cloud when enabled, protected by Row Level Security.\n'
                    '• You can delete your cloud data or keep Oloz 100% offline at any time.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      height: 1.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Understood',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
