import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';
import 'package:oloz/core/widgets/bottom_sheet_scaffold.dart';
import 'package:oloz/core/widgets/duration_stepper.dart';
import 'package:oloz/core/widgets/oloz_toggle.dart';
import 'package:oloz/core/widgets/preset_pills.dart';
import 'package:oloz/data/providers/app_providers.dart';

class SetLimitSheet extends ConsumerStatefulWidget {
  const SetLimitSheet({
    required this.package,
    this.appName = 'Instagram',
    this.initialLimitMs = 90 * 60 * 1000, // 1h 30m
    super.key,
  });

  final String package;
  final String appName;
  final int initialLimitMs;

  static Future<void> show(
    BuildContext context, {
    required String package,
    String appName = 'Instagram',
    int initialLimitMs = 90 * 60 * 1000,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.40),
      builder: (context) => SetLimitSheet(
        package: package,
        appName: appName,
        initialLimitMs: initialLimitMs,
      ),
    );
  }

  @override
  ConsumerState<SetLimitSheet> createState() => _SetLimitSheetState();
}

class _SetLimitSheetState extends ConsumerState<SetLimitSheet> {
  late int _limitMs;
  bool _remind = true;
  int _selectedPreset = 2; // Default to 1h 30m

  final _presets = const [
    DurationPreset(label: '45m', durationMs: 45 * 60 * 1000),
    DurationPreset(label: '1h', durationMs: 60 * 60 * 1000),
    DurationPreset(label: '1h 30m', durationMs: 90 * 60 * 1000),
    DurationPreset(label: '2h', durationMs: 120 * 60 * 1000),
  ];

  @override
  void initState() {
    super.initState();
    _limitMs = widget.initialLimitMs;
  }

  void _onStep(int deltaMs) {
    setState(() {
      _limitMs = (_limitMs + deltaMs).clamp(15 * 60 * 1000, 12 * 60 * 60 * 1000);
      _syncPreset();
    });
  }

  void _onPresetSelected(int index) {
    setState(() {
      _selectedPreset = index;
      _limitMs = _presets[index].durationMs;
    });
  }

  void _syncPreset() {
    _selectedPreset = _presets.indexWhere((p) => p.durationMs == _limitMs);
  }

  Future<void> _save() async {
    final limitRepo = ref.read(limitRepositoryProvider);
    await limitRepo.setLimit(
      scope: 'app',
      package: widget.package,
      dailyLimitMs: _limitMs,
      remind: _remind,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olozColors;

    return BottomSheetScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: "Daily limit" with app chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily limit',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.chartSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.appName,
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

          const SizedBox(height: OlozSpacing.s24),

          // Big Stepper: minus, "1h 30m", plus
          Center(
            child: DurationStepper(
              durationMs: _limitMs,
              onDecrement: () => _onStep(-15 * 60 * 1000),
              onIncrement: () => _onStep(15 * 60 * 1000),
            ),
          ),

          const SizedBox(height: OlozSpacing.s20),

          // Presets: 45m, 1h, 1h 30m, 2h
          PresetPills(
            presets: _presets,
            selectedIndex: _selectedPreset,
            onSelected: _onPresetSelected,
          ),

          const SizedBox(height: OlozSpacing.s24),

          // Toggle row: "Remind me"
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: OlozSpacing.s16,
              vertical: OlozSpacing.s12,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remind me',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
                OlozToggle(
                  value: _remind,
                  onChanged: (val) => setState(() => _remind = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: OlozSpacing.s24),

          // Primary button "Save" full width
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: OlozSpacing.s8),
        ],
      ),
    );
  }
}
