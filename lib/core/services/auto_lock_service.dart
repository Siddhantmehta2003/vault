import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final autoLockProvider = StateNotifierProvider<AutoLockNotifier, int>((ref) {
  return AutoLockNotifier();
});

class AutoLockNotifier extends StateNotifier<int> {
  Timer? _inactivityTimer;
  static const String _settingsKey = 'auto_lock_minutes';

  AutoLockNotifier() : super(5) {
    _loadSettings();
  }

  void _loadSettings() {
    final box = Hive.box('settings');
    state = box.get(_settingsKey, defaultValue: 5);
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    final box = Hive.box('settings');
    await box.put(_settingsKey, minutes);
    state = minutes;
  }

  void startInactivityTimer(VoidCallback onTimeout) {
    _inactivityTimer?.cancel();
    if (state == 0) return; // 0 means disabled

    _inactivityTimer = Timer(Duration(minutes: state), onTimeout);
  }

  void resetTimer(VoidCallback onTimeout) {
    startInactivityTimer(onTimeout);
  }

  void stopTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}

class AutoLockWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback onTimeout;

  const AutoLockWrapper({
    super.key,
    required this.child,
    required this.onTimeout,
  });

  @override
  ConsumerState<AutoLockWrapper> createState() => _AutoLockWrapperState();
}

class _AutoLockWrapperState extends ConsumerState<AutoLockWrapper> {
  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    ref.read(autoLockProvider.notifier).resetTimer(widget.onTimeout);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      onPanUpdate: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
