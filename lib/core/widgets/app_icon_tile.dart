import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

/// Standard 36px rounded square app icon tile with 12px corner radius.
class AppIconTile extends StatelessWidget {
  const AppIconTile({
    this.packageNameOrName = '',
    this.icon,
    this.size = 36,
    super.key,
  });

  final String packageNameOrName;
  final IconData? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final normalized = packageNameOrName.toLowerCase();

    var bgColor = colors.surfaceMuted;
    var iconColor = colors.text;
    var iconData = icon ?? Icons.apps_rounded;

    if (normalized.contains('instagram')) {
      bgColor = OlozBrandColors.instagramBg;
      iconColor = OlozBrandColors.instagramFg;
      iconData = Icons.camera_alt_outlined;
    } else if (normalized.contains('tiktok') ||
        normalized.contains('musically') ||
        normalized.contains('trill')) {
      bgColor = OlozBrandColors.tiktokBg;
      iconColor = OlozBrandColors.tiktokFg;
      iconData = Icons.music_note_outlined;
    } else if (normalized.contains('youtube')) {
      bgColor = OlozBrandColors.youtubeBg;
      iconColor = OlozBrandColors.youtubeFg;
      iconData = Icons.play_arrow_rounded;
    } else if (normalized.contains('facebook') ||
        normalized.contains('katana')) {
      bgColor = OlozBrandColors.facebookBg;
      iconColor = OlozBrandColors.facebookFg;
      iconData = Icons.public_rounded;
    } else if (normalized == 'x' || normalized.contains('twitter')) {
      bgColor = colors.text.withValues(alpha: 0.08);
      iconColor = colors.text;
      iconData = Icons.close_rounded;
    } else if (normalized.contains('chrome')) {
      bgColor = OlozBrandColors.chromeBg;
      iconColor = OlozBrandColors.chromeFg;
      iconData = Icons.language_rounded;
    } else if (normalized.contains('whatsapp')) {
      bgColor = OlozBrandColors.whatsappBg;
      iconColor = OlozBrandColors.whatsappFg;
      iconData = Icons.chat_bubble_outline_rounded;
    } else if (normalized.contains('reddit')) {
      bgColor = OlozBrandColors.redditBg;
      iconColor = OlozBrandColors.redditFg;
      iconData = Icons.forum_outlined;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(OlozSpacing.radiusAppIcon),
      ),
      child: Center(
        child: Icon(
          iconData,
          size: size * 0.55,
          color: iconColor,
        ),
      ),
    );
  }
}
