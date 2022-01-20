import 'dart:async';

import 'package:flutter/services.dart';

class Printer {
  static const MethodChannel _channel = MethodChannel('printer');

  static Future<String> printBill(
      String printerName, int tcpPort, String content) async {
    return await _channel.invokeMethod("printBill",
        {'printerName': printerName, 'tcpPort': tcpPort, 'content': content});
  }

  static Future<void> discoverPrinter() async {
    await _channel.invokeMethod("discoverPrinter");
  }
}
