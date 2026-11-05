import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:ffi/ffi.dart';
import 'package:intl/intl.dart';
import 'package:oloz/data/db/app_database.dart';

abstract class WindowsSystemApi {
  /// Returns the current foreground process executable name (e.g. 'chrome.exe')
  /// or null if none/desktop.
  String? getForegroundProcessName();

  /// Returns user idle duration in seconds using GetLastInputInfo.
  int getIdleDurationSeconds();
}

class NativeWin32SystemApi implements WindowsSystemApi {
  NativeWin32SystemApi() {
    if (Platform.isWindows) {
      _user32 = DynamicLibrary.open('user32.dll');
      _kernel32 = DynamicLibrary.open('kernel32.dll');

      _getForegroundWindow = _user32
          .lookupFunction<IntPtr Function(), int Function()>('GetForegroundWindow');

      _getWindowThreadProcessId = _user32.lookupFunction<
          Uint32 Function(IntPtr hWnd, Pointer<Uint32> lpdwProcessId),
          int Function(int hWnd, Pointer<Uint32> lpdwProcessId)>('GetWindowThreadProcessId');

      _getLastInputInfo = _user32.lookupFunction<
          Int32 Function(Pointer<_LASTINPUTINFO> plii),
          int Function(Pointer<_LASTINPUTINFO> plii)>('GetLastInputInfo');

      _openProcess = _kernel32.lookupFunction<
          IntPtr Function(Uint32 dwDesiredAccess, Int32 bInheritHandle, Uint32 dwProcessId),
          int Function(int dwDesiredAccess, int bInheritHandle, int dwProcessId)>('OpenProcess');

      _queryFullProcessImageNameW = _kernel32.lookupFunction<
          Int32 Function(
              IntPtr hProcess, Uint32 dwFlags, Pointer<Utf16> lpExeName, Pointer<Uint32> lpdwSize),
          int Function(int hProcess, int dwFlags, Pointer<Utf16> lpExeName,
              Pointer<Uint32> lpdwSize)>('QueryFullProcessImageNameW');

      _closeHandle = _kernel32.lookupFunction<
          Int32 Function(IntPtr hObject),
          int Function(int hObject)>('CloseHandle');

      _getTickCount64 = _kernel32.lookupFunction<
          Uint64 Function(),
          int Function()>('GetTickCount64');
    }
  }

  late final DynamicLibrary _user32;
  late final DynamicLibrary _kernel32;

  late final int Function() _getForegroundWindow;
  late final int Function(int, Pointer<Uint32>) _getWindowThreadProcessId;
  late final int Function(Pointer<_LASTINPUTINFO>) _getLastInputInfo;
  late final int Function(int, int, int) _openProcess;
  late final int Function(int, int, Pointer<Utf16>, Pointer<Uint32>) _queryFullProcessImageNameW;
  late final int Function(int) _closeHandle;
  late final int Function() _getTickCount64;

  static const int _processQueryLimitedInformation = 0x1000;

  @override
  String? getForegroundProcessName() {
    if (!Platform.isWindows) return null;

    final hwnd = _getForegroundWindow();
    if (hwnd == 0) return null;

    final pidPtr = calloc<Uint32>();
    try {
      _getWindowThreadProcessId(hwnd, pidPtr);
      final pid = pidPtr.value;
      if (pid == 0) return null;

      final hProcess = _openProcess(_processQueryLimitedInformation, 0, pid);
      if (hProcess == 0) return null;

      try {
        final buffer = calloc<Uint16>(1024).cast<Utf16>();
        final sizePtr = calloc<Uint32>()..value = 1024;
        try {
          final success = _queryFullProcessImageNameW(hProcess, 0, buffer, sizePtr);
          if (success != 0) {
            final fullPath = buffer.toDartString();
            return fullPath.split(Platform.pathSeparator).last;
          }
        } finally {
          calloc
            ..free(buffer)
            ..free(sizePtr);
        }
      } finally {
        _closeHandle(hProcess);
      }
    } on Exception catch (_) {
      return null;
    } finally {
      calloc.free(pidPtr);
    }
    return null;
  }

  @override
  int getIdleDurationSeconds() {
    if (!Platform.isWindows) return 0;

    final lii = calloc<_LASTINPUTINFO>();
    try {
      lii.ref.cbSize = sizeOf<_LASTINPUTINFO>();
      if (_getLastInputInfo(lii) != 0) {
        final tickNow = _getTickCount64();
        final lastInput = lii.ref.dwTime;
        final diffMs = (tickNow & 0xFFFFFFFF) - lastInput;
        return (diffMs ~/ 1000).clamp(0, 86400);
      }
    } on Exception catch (_) {
      return 0;
    } finally {
      calloc.free(lii);
    }
    return 0;
  }
}

final class _LASTINPUTINFO extends Struct {
  @Uint32()
  external int cbSize;

  @Uint32()
  external int dwTime;
}

class WindowsActiveAppEvent {
  const WindowsActiveAppEvent({
    required this.exeName,
    required this.label,
    required this.category,
    required this.timestampMs,
    required this.isIdle,
  });

  final String exeName;
  final String label;
  final String category;
  final int timestampMs;
  final bool isIdle;
}

class WindowsForegroundTracker {
  WindowsForegroundTracker({
    required this.database,
    WindowsSystemApi? systemApi,
    this.deviceId = 'pc',
    this.idleThresholdSeconds = 120,
  }) : _systemApi = systemApi ?? NativeWin32SystemApi();

  final AppDatabase database;
  final WindowsSystemApi _systemApi;
  final String deviceId;
  final int idleThresholdSeconds;

  Timer? _timer;
  String? _activeExe;
  int _activeStartMs = 0;
  final _dayFormat = DateFormat('yyyy-MM-dd');

  final _eventController = StreamController<WindowsActiveAppEvent>.broadcast();
  Stream<WindowsActiveAppEvent> get eventStream => _eventController.stream;

  bool get isRunning => _timer != null && _timer!.isActive;

  void start() {
    if (isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => pollOnce());
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await _flushCurrentSession(DateTime.now().millisecondsSinceEpoch);
  }

  /// Evaluates current foreground app and user idle state.
  Future<void> pollOnce({int? nowMs}) async {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final idleSeconds = _systemApi.getIdleDurationSeconds();
    final isIdle = idleSeconds >= idleThresholdSeconds;

    final currentExe = _systemApi.getForegroundProcessName()?.toLowerCase();

    // Ignore Oloz itself and taskbar/system desktop if desired
    final ignored = currentExe == null ||
        currentExe == 'oloz.exe' ||
        currentExe == 'applicationframehost.exe' ||
        currentExe == 'shellexperiencehost.exe' ||
        isIdle;

    if (ignored) {
      if (_activeExe != null) {
        await _flushCurrentSession(now);
      }
      return;
    }

    if (_activeExe != currentExe) {
      // Switched to a new app: flush previous
      if (_activeExe != null) {
        await _flushCurrentSession(now);
      }

      _activeExe = currentExe;
      _activeStartMs = now;

      final label = resolveFriendlyLabel(currentExe);
      final category = resolveCategory(currentExe);

      // Ensure app exists in database
      await database.usageDao.upsertApp(
        AppsCompanion.insert(
          package: currentExe,
          label: label,
          platform: 'windows',
          category: category,
          isShortVideo: const Value(false),
        ),
      );

      _eventController.add(
        WindowsActiveAppEvent(
          exeName: currentExe,
          label: label,
          category: category,
          timestampMs: now,
          isIdle: false,
        ),
      );
    }
  }

  Future<void> _flushCurrentSession(int finishTimeMs) async {
    final exe = _activeExe;
    final start = _activeStartMs;

    _activeExe = null;
    _activeStartMs = 0;

    if (exe == null || finishTimeMs <= start) return;

    // Handle session potentially crossing local midnight
    var currentStart = start;
    while (currentStart < finishTimeMs) {
      final date = DateTime.fromMillisecondsSinceEpoch(currentStart);
      final nextMidnight = DateTime(date.year, date.month, date.day + 1);
      final segmentEnd =
          finishTimeMs < nextMidnight.millisecondsSinceEpoch ? finishTimeMs : nextMidnight.millisecondsSinceEpoch;

      if (segmentEnd > currentStart) {
        final dayStr = _dayFormat.format(date);
        await database.usageDao.recordSession(
          package: exe,
          deviceId: deviceId,
          startMs: currentStart,
          endMs: segmentEnd,
          day: dayStr,
        );
      }
      currentStart = segmentEnd;
    }
  }

  static String resolveFriendlyLabel(String exe) {
    final lower = exe.toLowerCase();
    if (lower.contains('chrome')) return 'Google Chrome';
    if (lower.contains('msedge') || lower.contains('edge')) return 'Microsoft Edge';
    if (lower.contains('firefox')) return 'Firefox';
    if (lower.contains('code')) return 'Visual Studio Code';
    if (lower.contains('discord')) return 'Discord';
    if (lower.contains('slack')) return 'Slack';
    if (lower.contains('spotify')) return 'Spotify';
    if (lower.contains('telegram')) return 'Telegram';
    if (lower.contains('whatsapp')) return 'WhatsApp';
    if (lower.contains('notion')) return 'Notion';
    if (lower.contains('explorer')) return 'File Explorer';

    // Fallback: capitalize exe name without extension
    final name = exe.replaceAll('.exe', '');
    return name.isEmpty ? exe : name[0].toUpperCase() + name.substring(1);
  }

  static String resolveCategory(String exe) {
    final lower = exe.toLowerCase();
    if (lower.contains('chrome') || lower.contains('edge') || lower.contains('firefox') || lower.contains('brave')) {
      return 'browsing';
    }
    if (lower.contains('discord') || lower.contains('slack') || lower.contains('telegram') || lower.contains('whatsapp')) {
      return 'messaging';
    }
    if (lower.contains('spotify') || lower.contains('vlc') || lower.contains('netflix')) {
      return 'video';
    }
    if (lower.contains('code') || lower.contains('studio') || lower.contains('terminal') || lower.contains('powershell')) {
      return 'utility';
    }
    return 'other';
  }

  Future<void> dispose() async {
    await stop();
    await _eventController.close();
  }
}
