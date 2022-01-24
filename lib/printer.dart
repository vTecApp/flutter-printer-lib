import 'dart:async';

import 'package:flutter/services.dart';

enum PaperSize { size58, size80 }

class Printer {
  static const MethodChannel _channel = MethodChannel('printer');

  static Future<String> printBill(
      String printerName, int tcpPort, String content,
      {paperSize = PaperSize.size80}) async {
    int bitmapWidth = 72 * 4;
    if (paperSize == PaperSize.size80) {
      bitmapWidth = 72 * 8;
    }
    content = _customizeContent(content, paperSize);
    return await _channel.invokeMethod("printBill", {
      'printerName': printerName,
      'tcpPort': tcpPort,
      'content': content,
      'scale': 150,
      'bitmapWidth': bitmapWidth
    });
  }

  static _customizeContent(String content, PaperSize paperSize) {
    String size = '70mm';
    if (paperSize == PaperSize.size80) size = '144mm';

    content = content.replaceAll('70mm', size);
    content = content.replaceAll(
        '<hr/>', '<hr style="border-top:2px solid black;"/>');
    return content;
  }
}
