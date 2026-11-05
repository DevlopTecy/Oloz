import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/widgets/app_icon_tile.dart';

class PlatformReelsItem {
  const PlatformReelsItem({
    required this.name,
    required this.count,
    required this.fraction,
    required this.barColor,
  });

  final String name;
  final int count;
  final double fraction;
  final Color barColor;
}

/// Platform breakdown row displaying app icon, platform name, count right,
/// and a horizontal bar with decreasing peach tints.
class PlatformBar extends StatelessWidget {
  const PlatformBar({
    required this.items,
    super.key,
  });

  final List<PlatformReelsItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: OlozSpacing.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AppIconTile(packageNameOrName: item.name, size: 28),
                  const SizedBox(width: OlozSpacing.s12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.text,
                      ),
                    ),
                  ),
                  Text(
                    item.count.toString(),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: item.fraction.clamp(0.0, 1.0),
                    backgroundColor: colors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(item.barColor),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

