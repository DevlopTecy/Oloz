import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/widgets/app_icon_tile.dart';

/// Single app item row for Home, Apps list, and Desktop right panel.
class AppRow extends StatelessWidget {
  const AppRow({
    required this.name,
    required this.progress,
    this.package,
    String? timeFormatted,
    String? formattedTime,
    this.reelsCount,
    this.deviceTag,
    this.appIcon,
    this.onTap,
    super.key,
  }) : timeFormatted = timeFormatted ?? formattedTime ?? '';

  final String name;
  final String? package;
  final String timeFormatted;

  /// Progress fraction (0.0 to 1.0)
  final double progress;

  /// Optional reels count for social apps (rendered in peach color).
  final int? reelsCount;

  /// Optional device tag (e.g. 'Phone' or 'PC')
  final String? deviceTag;

  final IconData? appIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Semantics(
      container: true,
      button: onTap != null,
      label: '$name, $timeFormatted${reelsCount != null && reelsCount! > 0 ? ', $reelsCount reels' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OlozSpacing.radiusButton),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: OlozSpacing.s8, horizontal: OlozSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AppIconTile(packageNameOrName: package ?? name, icon: appIcon),
                  const SizedBox(width: OlozSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors.text,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (deviceTag != null) ...[
                              const SizedBox(width: OlozSpacing.s8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(OlozSpacing.radiusPill),
                                ),
                                child: Text(
                                  deviceTag!,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (reelsCount != null && reelsCount! > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '$reelsCount reels',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colors.reel,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    timeFormatted,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OlozSpacing.s8),
              // Thin 4px progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: colors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.chart),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

