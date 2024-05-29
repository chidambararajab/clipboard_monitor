import 'package:flutter/services.dart';
import 'dart:async';
import 'package:clipboard_monitor/database/database.dart';
import 'package:clipboard_monitor/models/clipboard_item.dart';

class ClipboardMonitor {
  static final ClipboardMonitor _instance = ClipboardMonitor._internal();
  factory ClipboardMonitor() => _instance;

  ClipboardMonitor._internal();

  Timer? _timer;

  void startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      ClipboardData? clipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        _saveClipboardText(clipboardData.text!);
      }
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  Future<void> _saveClipboardText(String text) async {
    final newItem =
        ClipboardItem(id: DateTime.now().millisecondsSinceEpoch, text: text);
    await DatabaseService().insertClipboardItem(newItem);
  }
}
