import 'dart:async';

import 'package:flutter/services.dart';

class Printer {
  static const MethodChannel _channel = MethodChannel('printer');

  static Future<String> printBill(
      String printerName, int tcpPort, String content) async {
    content = content.replaceAll('70mm', '144mm');
    content = content.replaceAll(
        '<hr/>', '<hr style="border-top:2px solid black;"/>');
    return await _channel.invokeMethod("printBill",
        {'printerName': printerName, 'tcpPort': tcpPort, 'content': content});
  }
}
