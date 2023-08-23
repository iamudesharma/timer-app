
import 'dart:async';

import 'package:flutter/foundation.dart';

class CustomTimer {
  final Duration initialDuration;
  late Duration remainingDuration;
  late Timer timer;
  late ValueNotifier<String> displayTime;
  bool isRunning = true;

  CustomTimer(this.initialDuration) {
    remainingDuration = initialDuration;
    displayTime = ValueNotifier<String>(_formatDuration(remainingDuration));
    timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    if (!isRunning) return;

    if (remainingDuration.inSeconds > 0) {
      remainingDuration -= const Duration(seconds: 1);
      displayTime.value = _formatDuration(remainingDuration);
    } else {
      timer.cancel();
      displayTime.value = '00:00';
    }
  }

  void start() {
    isRunning = true;
  }

  void stop() {
    isRunning = false;
  }

  String _formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}