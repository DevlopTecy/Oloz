import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/widgets/oloz_nav_bar.dart';
import 'package:oloz/core/widgets/oloz_sidebar.dart';

/// Responsive application shell wrapping the primary navigation and pages.
/// - `< 720 dp`: Mobile layout with persistent bottom navigation bar.
/// - `≥ 720 dp`: Desktop layout with fixed left sidebar and centered content (max 1200dp).
class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({
    required this.currentTab,
    required this.onTabSelected,
    required this.child,
    super.key,
  });

  final OlozTab currentTab;
  final ValueChanged<OlozTab> onTabSelected;
  final Widget child;

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 720;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: colors.bg,
            body: Row(
              children: [
                OlozSidebar(
                  currentTab: widget.currentTab,
                  onTabSelected: widget.onTabSelected,
                  isCollapsed: _sidebarCollapsed,
                  onToggleCollapse: () {
                    setState(() {
                      _sidebarCollapsed = !_sidebarCollapsed;
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: OlozSpacing.maxContentWidthDesktop,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile layout
        return Scaffold(
          backgroundColor: colors.bg,
          body: SafeArea(
            bottom: false,
            child: widget.child,
          ),
          bottomNavigationBar: OlozNavBar(
            currentTab: widget.currentTab,
            onTabSelected: widget.onTabSelected,
          ),
        );
      },
    );
  }
}

