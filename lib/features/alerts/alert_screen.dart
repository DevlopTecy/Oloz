import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/data/providers/app_providers.dart';

class OverLimitAlertScreen extends ConsumerWidget {
  const OverLimitAlertScreen({
    this.appName = 'Instagram',
    this.limitFormatted = '1h 30m',
    this.package,
    super.key,
  });

  final String appName;
  final String limitFormatted;
  final String? package;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olozColors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OlozSpacing.screenPaddingMobile,
            vertical: OlozSpacing.s16,
          ),
          child: Column(
            children: [
              // Close (X) icon at top right
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: colors.textSecondary,
                  onPressed: () => context.pop(),
                ),
              ),

              const Spacer(),

              // Soft danger-tinted ring with hourglass icon
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.error.withValues(alpha: 0.35),
                    width: 7,
                  ),
                  color: colors.error.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: 42,
                    color: colors.error,
                  ),
                ),
              ),

              const SizedBox(height: OlozSpacing.s28),

              // Title "Limit reached"
              Text(
                'Limit reached',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colors.text,
                ),
              ),

              const SizedBox(height: OlozSpacing.s8),

              // Subline: "Instagram · 1h 30m" in sentence case
              Text(
                '$appName · $limitFormatted',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),

              const Spacer(),

              // Buttons at bottom with 12px gap
              // 1. Primary "Take a break" with moon icon
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    unawaited(ref.read(trackingServiceProvider).sendToDeviceHome());
                    context.go('/home');
                  },
                  icon: const Icon(Icons.nightlight_round, size: 18),
                  label: const Text(
                    'Take a break',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: OlozSpacing.s12),

              // 2. Secondary muted "5 more min"
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    if (package != null) {
                      final limit = await ref
                          .read(limitRepositoryProvider)
                          .watchLimit(scope: 'app', package: package)
                          .first;
                      if (limit != null) {
                        final until = DateTime.now().millisecondsSinceEpoch +
                            5 * 60 * 1000;
                        await ref
                            .read(limitRepositoryProvider)
                            .snoozeLimit(limit.id, until);
                      }
                    }
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.text,
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '5 more min',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: OlozSpacing.s8),
            ],
          ),
        ),
      ),
    );
  }
}

