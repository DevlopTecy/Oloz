import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

enum OlozTab { home, reels, apps, settings }

/// Bottom navigation bar for mobile (<720dp) with 4 tabs:
/// Home, Reels, Apps, Settings.
/// Active tab = soft pill + indigo icon and label.
class OlozNavBar extends StatelessWidget {
  const OlozNavBar({
    required this.currentTab,
    required this.onTabSelected,
    super.key,
  });

  final OlozTab currentTab;
  final ValueChanged<OlozTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentTab == OlozTab.home,
                onTap: () => onTabSelected(OlozTab.home),
              ),
              _NavBarItem(
                icon: Icons.play_circle_outline_rounded,
                selectedIcon: Icons.play_circle_filled_rounded,
                label: 'Reels',
                isSelected: currentTab == OlozTab.reels,
                onTap: () => onTabSelected(OlozTab.reels),
              ),
              _NavBarItem(
                icon: Icons.apps_outlined,
                selectedIcon: Icons.apps_rounded,
                label: 'Apps',
                isSelected: currentTab == OlozTab.apps,
                onTap: () => onTabSelected(OlozTab.apps),
              ),
              _NavBarItem(
                icon: Icons.tune_rounded,
                selectedIcon: Icons.tune_rounded,
                label: 'Settings',
                isSelected: currentTab == OlozTab.settings,
                onTap: () => onTabSelected(OlozTab.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Semantics(
      selected: isSelected,
      button: true,
      label: '$label tab',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: OlozDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? colors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(OlozSpacing.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 20,
                color: isSelected ? colors.primary : colors.textSecondary,
              ),
              if (isSelected) ...[
                const SizedBox(width: OlozSpacing.s8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

