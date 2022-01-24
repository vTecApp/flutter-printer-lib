import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:printer/printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  _testPrinter() async {
    String size = "100%";
    String content =
        '<html><header><META HTTP-EQUIV="Pragma" CONTENT="no-cache"><META HTTP-EQUIV="Expires" CONTENT="-1"><style type="text/css"> body, td, th { font-family: Tahoma, Verdana, Arial; font-weight: normal; font-size: 12px;} .htext { font-family: Tahoma, Verdana, Arial; font-weight: bold; font-size: 20px; } .h1text { font-family: Tahoma, Verdana, Arial; font-weight: bold; font-size: 16px; } .h0text { font-family: Tahoma, Verdana, Arial; font-weight: bold; font-size: 12px; } </style></header><body><table border="0" cellpadding="2" cellspacing="0" style="border-collapse:collapse; width:$size;"><tr><td align="center" colspan="3" class="htext">008</td></tr><tr><td align="center" colspan="3" style="height:2mm;"></td></tr><tr><td align="center" colspan="3">Vertical Tec Cloud POS<br>388/68 บิซแกลเลอเรีย นวลจันทร์<br>เขตบึงกุ่ม กรุงเทพฯ 10230<br>TaxID : 0105557771999<br>ใบเสร็จรับเงิน/ใบกำกับภาษีอย่างย่อ<br>POS ID : E00000000000000</td></tr><tr><td align="center" colspan="3" style="height:2mm;"></td></tr><tr><td align="left" colspan="3">Date: 20/01/2022 13:42:02</td></tr><tr><td align="left" colspan="3">Order No.:008</td></tr><tr><td align="left">No Customer:1</td><td align="right" colspan="2">Eat In</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ไก่แช่เหล้ายำแมงกะพรุน 375</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">375.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หอยจ้อ S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">3</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">555.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ไก่แช่เหล้า S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">245.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ทอดมันกุ้ง S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">185.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) สลัดกุ้งกรอบผลไม้รวม M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">350.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หมูซีอิ๊วฮ่องกง S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">2</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">370.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หมูกรอบ M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">3</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">840.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) กุ้งแชบ๊วยชุบแป้งทอด S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">225.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ไก่แช่เหล้า M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">490.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หอยจ้อ M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">3</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">1,050.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ออร์เดิร์ฟเย็น 480</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">480.00</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="left">Total Baht 18</td><td align="right" colspan="2">5,165.00</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="left" colspan="2">Service Charge 10.00%</td><td align="right">516.50</td></tr><tr><td class="h0text" align="left" colspan="2">NET BAHT</td><td class="h0text" align="right">5,681.50</td></tr><tr><td class="h0text" align="left">Due Payment</td><td class="h0text" valign="top" align="right" colspan="2">5,681.50</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="center" colspan="3">VAT Included<br>Thank You. Please come again.</td></tr><tr><td align="center" colspan="3" style="height:6mm;"></td></tr><tr><td align="center" class="h1text" colspan="3"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJsAAAAeCAYAAAA7HGznAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAXWSURBVHhejYwBiu1IEMPe/S89ixYE/sZdRBDalov8/ga/3+//zyz65TrD6knu5u7SOffMsHZJD3332mBtuleGq18b9F3uX7qkh9UbXd+CLm98zc206yegX64zrJ7kbu4unXPPDGuX9NB3rw3WpntluPq1Qd/l/qVLeli90fUt6PLG19xMu34C+uU6w+pJ7ubu0jn3zLB2SQ9999pgbbpXhqtfG/Rd7l+6pIfVG13fgi5vfM3NtOsnoF+uM6ye5G7uLp1zzwxrl/TQd68N1qZ7Zbj6tUHf5f6lS3pYvdH1LejyxtfcTLt+AvrlOsPqSe7m7tI598ywdkkPfffaYG26V4arXxv0Xe5fuqSH1Rtd34Iub3zNzbTrJ6BfrjOsnuRu7i6dc88Ma5f00HevDdame2W4+rVB3+X+pUt6WL3R9S3o8sbX3Ey7fgL65TrD6knu5u7SOffMsHZJD3332mBtuleGq18b9F3uX7qkh9UbXd+CLm98zc206yegX64zrJ7kbu4unXPPDGuX9NB3rw3WpntluPq1Qd/l/qVLeli90fUt6PLG19xMu34C+uU6w+pJ7ubu0jn3zLB2SQ9999pgbbpXhqtfG/Rd7l+6pIfVG13fgi5vfM3NtOsnoF+uM6ye5G7uLp1zzwxrl/TQd68N1qZ7Zbj6tUHf5f6lS3pYvdH1LejyxtfcTLt+AvrlOsPqSe7m7tI598ywdkkPfffaYG26V4arXxv0Xe5fuqSH1Rtd34Iub3zNzbTrJ6BfrjOsnuRu7i6dc88Ma5f00HevDdame2W4+rVB3+X+pUt6WL3R9S3o8sbX3Ey7fgL65TrD6knu5u7SOffMsHZJD3332mBtuleGq18b9F3uX7qkh9UbXd+CLm98zc206yegX64zrJ7kbu4unXPPDGuX9NB3rw3WpntluPq1Qd/l/qVLeli90fUt6PLG19xMu34C+uU6w+pJ7ubu0jn3zLB2SQ9999pgbbpXhqtfG/Rd7l+6pIfVG13fgi5vfM3NtOsnoF+uM6ye5G7uLp1zzwxrl/TQd68N1qZ7Zbj6tUHf5f6lS3pYvdH1LejyxtfcTLt+AvrlOsPqSe7m7tI598ywdkkPfffaYG26V4arXxv0Xe5fuqSH1Rtd34Iub3zNzbTrJ6BfrjOsnuRu7i6dc88Ma5f00HevDdame2W4+rVB3+X+pUt6WL3R9S3o8sbX3Ey7fgL65TrD6knu5u7SOffMsHZJD3332mBtuleGq18b9F3uX7qkh9UbXd+CLm98zc206yegX64zrJ7kbu4unXPPDGuX9NB3rw3WpntluPq1Qd/l/qVLeli90fUt6PLG19xMu34C+uU6w+pJ7ubu0jn3zLB2SQ9999pgbbpXhqtfG/Rd7l+6pIfVG13fgi5vfM3NtOsnoF+uM6ye5G7uLp1zzwxrl/TQd68N1qZ7Zbj6tUHf5f6lS3pYvdH1LejyxtfcTLt+AvrlOsPqSe7m7tI598ywdkkPfffaYG26V4arXxv0Xe5fuqSH1Rtd34Iub3zNzbTrJ6BfrjOsnuRu7i6dc88Ma5f00HevDdame2W4+rVB3+X+pUt6WL3R9S3o8sbX3Ey7fgL65TrD6knu5u7SOffMsHZJD3332mBtuleGq18b9F3uX7qkh9UbXd+CLm98zc206yegX64zrJ7kbu4unXPPDGuX9NB3rw3WpntluPq1Qd/l/qVLeli90fUt6PLG19xMu34C+uU6w+pJ7ubu0jn3zLB2SQ9999pgbbpXhqtfG/Rd7l+6pIfVG13fgi5vfM3NtOsnoF+uM6ye5G7uLp1zzwxrl/TQd68N1qZ7Zbj6tUHf5f6lS3pYvdH1LejyxtfcTLt+AvrlOsPqSe7m7tI598ywdkkPfffaYG26V4arXxv0Xe5fuqSH1Rtd34Iub3zNzbTrJ6BfrjOsnuRu7i6dc88Ma5f00HevDdame2W4+rVB3+X+pUt6WL3R9S3o8sbX/C9/f/8B4OBeDZyGgvYAAAAASUVORK5CYII="></td></tr><tr><td align="center" colspan="3" style="height:6mm;"></td></tr></table></body></html>';
    await Printer.printBill("192.168.1.87", 9100, content);
  }

  _discoverPrinter() async {
    await Printer.discoverPrinter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _discoverPrinter,
                    child: Text('Discover Printer')),
                ElevatedButton(
                    onPressed: _testPrinter, child: Text("Test Printer"))
              ],
            ),
          )),
    );
  }
}
