import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/data/providers/app_providers.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  List<Map<dynamic, dynamic>> _events = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshEvents());
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_refreshEvents());
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshEvents() async {
    final service = ref.read(trackingServiceProvider);
    final events = await service.getDebugEvents();
    if (mounted) {
      setState(() {
        _events = events.reversed.toList();
      });
    }
  }

  Future<void> _clearEvents() async {
    final service = ref.read(trackingServiceProvider);
    await service.clearDebugEvents();
    if (mounted) {
      setState(() {
        _events = [];
      });
    }
  }

  String _formatEventType(int type) {
    return switch (type) {
      4096 => 'TYPE_VIEW_SCROLLED',
      2048 => 'TYPE_WINDOW_CONTENT_CHANGED',
      32 => 'TYPE_WINDOW_STATE_CHANGED',
      _ => 'TYPE_$type',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        title: Text(
          'Reel Event Logger',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            color: colors.primary,
            onPressed: () {
              unawaited(_refreshEvents());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear',
            color: colors.textSecondary,
            onPressed: () {
              unawaited(_clearEvents());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OlozSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(OlozSpacing.s16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Captured Events: ${_events.length}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.chartSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Live Poll (2s)',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Validates view IDs, scroll bounds, and pager class hints without text capture.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OlozSpacing.s16),

              Expanded(
                child: _events.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(OlozSpacing.s24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.developer_mode_outlined,
                                size: 48,
                                color: colors.textSecondary,
                              ),
                              const SizedBox(height: OlozSpacing.s16),
                              Text(
                                'No accessibility events logged',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.text,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Enable Oloz Accessibility Service in Android Settings, then swipe through reels in Instagram, TikTok, YouTube Shorts, or Facebook.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _events.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: OlozSpacing.s8),
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          final pkg = event['packageName'] as String? ?? '';
                          final eventType =
                              event['eventType'] as int? ?? 0;
                          final className =
                              event['className'] as String? ?? 'unknown';
                          final viewId = event['viewId'] as String?;
                          final isFullScreen =
                              event['isFullScreenScroll'] as bool? ?? false;
                          final fromIdx = event['fromIndex'] as int? ?? -1;
                          final toIdx = event['toIndex'] as int? ?? -1;

                          return Container(
                            padding: const EdgeInsets.all(OlozSpacing.s12),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _formatEventType(eventType),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: colors.primary,
                                        ),
                                      ),
                                    ),
                                    if (isFullScreen)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.chartSoft,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Full Screen',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: colors.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pkg,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: colors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Class: ${className.split('.').last} · ViewId: ${viewId ?? "none"}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                if (fromIdx >= 0 || toIdx >= 0)
                                  Text(
                                    'Index: $fromIdx -> $toIdx',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
