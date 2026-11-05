import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;
    final currentThemeMode = ref.watch(themeModeProvider);

    final themeIndex = switch (currentThemeMode) {
      ThemeMode.light => 0,
      ThemeMode.dark => 1,
      ThemeMode.system => 2,
    };

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                        '6h · 350 reels',
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
              Padding(
                padding: const EdgeInsets.all(OlozSpacing.s16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Icon(Icons.check_circle, size: 20, color: colors.primary),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),

              // Reminders
              Padding(
                padding: const EdgeInsets.all(OlozSpacing.s16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_none, size: 20, color: colors.textSecondary),
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
                      'Every 15m',
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
                    Icon(Icons.smartphone, size: 20, color: colors.textSecondary),
                    const SizedBox(width: OlozSpacing.s12),
                    Expanded(
                      child: Text(
                        'This phone',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.text,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    Icon(Icons.desktop_windows_outlined, size: 20, color: colors.textSecondary),
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

        // Debug & Diagnostics group
        Text(
          'Diagnostics',
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
          child: InkWell(
            onTap: () => context.push('/settings/debug'),
            borderRadius: BorderRadius.circular(20),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
