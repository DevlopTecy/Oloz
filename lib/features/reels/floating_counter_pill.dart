import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

/// Floating live reel counter pill component.
/// Displays a minimal 44px-tall glassmorphism pill with peach indicator dot,
/// tabular bold count, and expanding dwell info.
class FloatingCounterPill extends StatefulWidget {
  const FloatingCounterPill({
    this.reelsCount = 37,
    this.dwellFormatted = '12m',
    this.initialExpanded = false,
    this.onTap,
    super.key,
  });

  final int reelsCount;
  final String dwellFormatted;
  final bool initialExpanded;
  final VoidCallback? onTap;

  @override
  State<FloatingCounterPill> createState() => _FloatingCounterPillState();
}

class _FloatingCounterPillState extends State<FloatingCounterPill> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: colors.surface.withValues(alpha: 0.90),
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Peach dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.reel,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tabular bold count
                  Text(
                    '${widget.reelsCount}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(width: 4),

                  Text(
                    'reels',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),

                  // Expanded state: dwell time and pause icon
                  if (_isExpanded) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: colors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.dwellFormatted,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.pause_circle_outline,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Preview showcase screen demonstrating floating live counter pill in context.
class FloatingCounterPreviewScreen extends StatelessWidget {
  const FloatingCounterPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated vertical video gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    OlozBrandColors.mockVideoGradientStart,
                    OlozBrandColors.mockVideoGradientMid,
                    OlozBrandColors.mockVideoGradientEnd,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(OlozSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Live Counter Pill',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: OlozSpacing.s32),

                  Text(
                    'Collapsed & Expanded States',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: OlozSpacing.s20),

                  // Collapsed pill
                  const FloatingCounterPill(
                    
                  ),

                  const SizedBox(height: OlozSpacing.s20),

                  // Expanded pill
                  const FloatingCounterPill(
                    initialExpanded: true,
                  ),

                  const Spacer(),

                  Center(
                    child: Text(
                      'Floating overlay over short-video apps.\nCalm, minimal, no logos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: OlozSpacing.s20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
