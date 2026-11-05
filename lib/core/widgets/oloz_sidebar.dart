import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/widgets/oloz_nav_bar.dart';

/// Desktop left sidebar (240px wide or 72px collapsed).
class OlozSidebar extends StatelessWidget {
  const OlozSidebar({
    required this.currentTab,
    required this.onTabSelected,
    this.isCollapsed = false,
    this.onToggleCollapse,
    super.key,
  });

  final OlozTab currentTab;
  final ValueChanged<OlozTab> onTabSelected;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;
    final width = isCollapsed ? 72.0 : 240.0;

    return AnimatedContainer(
      duration: OlozDurations.fast,
      width: width,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Logo
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 16 : 24,
              vertical: 24,
            ),
            child: Row(
              children: [
                // Oloz Logo mark (indigo ring with peach dot)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.chart, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.reel,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: OlozSpacing.s12),
                  Text(
                    'Oloz',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: OlozSpacing.s8),

          // Nav links
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _SidebarItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentTab == OlozTab.home,
                  isCollapsed: isCollapsed,
                  onTap: () => onTabSelected(OlozTab.home),
                ),
                const SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.play_circle_outline_rounded,
                  selectedIcon: Icons.play_circle_filled_rounded,
                  label: 'Reels',
                  isSelected: currentTab == OlozTab.reels,
                  isCollapsed: isCollapsed,
                  onTap: () => onTabSelected(OlozTab.reels),
                ),
                const SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.apps_outlined,
                  selectedIcon: Icons.apps_rounded,
                  label: 'Apps',
                  isSelected: currentTab == OlozTab.apps,
                  isCollapsed: isCollapsed,
                  onTap: () => onTabSelected(OlozTab.apps),
                ),
                const SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.tune_rounded,
                  selectedIcon: Icons.tune_rounded,
                  label: 'Settings',
                  isSelected: currentTab == OlozTab.settings,
                  isCollapsed: isCollapsed,
                  onTap: () => onTabSelected(OlozTab.settings),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Account & Sync indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Initials avatar
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.surfaceMuted,
                  child: Text(
                    'YA',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: OlozSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your account',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.text,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Live syncing',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Semantics(
      selected: isSelected,
      button: true,
      label: '$label navigation',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: OlozDurations.fast,
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 12 : 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? colors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 20,
                  color: isSelected ? colors.primary : colors.textSecondary,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: OlozSpacing.s12),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? colors.primary : colors.text,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

