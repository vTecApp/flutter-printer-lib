import 'package:flutter/foundation.dart';
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
  String _errMsg = "";

  _testPrinter() async {
    setState(() {
      _errMsg = "Printing...";
    });
    String content =
        '<html><header><META HTTP-EQUIV="Pragma" CONTENT="no-cache"><META HTTP-EQUIV="Expires" CONTENT="-1"><style type="text/css"> body, td, th { font-family: Tahoma, Verdana, Arial; font-weight: normal; font-size: 12px;} .htext { font-family: Tahoma, Verdana, Arial; font-weight: bold; font-size: 20px; } .h1text { font-family: Tahoma, Verdana, Arial; font-weight: bold; font-size: 16px; } .h0text { font-family: Tahoma, Verdana, Arial; font-weight: bold; font-size: 12px; } </style></header><body><table border="0" cellpadding="2" cellspacing="0" style="border-collapse:collapse; width:70mm;"><tr><td align="center" colspan="3" class="htext">008</td></tr><tr><td align="center" colspan="3" style="height:2mm;"></td></tr><tr><td align="center" colspan="3">Vertical Tec Cloud POS<br>388/68 บิซแกลเลอเรีย นวลจันทร์<br>เขตบึงกุ่ม กรุงเทพฯ 10230<br>TaxID : 0105557771999<br>ใบเสร็จรับเงิน/ใบกำกับภาษีอย่างย่อ<br>POS ID : E00000000000000</td></tr><tr><td align="center" colspan="3" style="height:2mm;"></td></tr><tr><td align="left" colspan="3">Date: 20/01/2022 13:42:02</td></tr><tr><td align="left" colspan="3">Order No.:008</td></tr><tr><td align="left">No Customer:1</td><td align="right" colspan="2">Eat In</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ไก่แช่เหล้ายำแมงกะพรุน 375</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">375.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หอยจ้อ S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">3</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">555.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ไก่แช่เหล้า S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">245.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ทอดมันกุ้ง S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">185.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) สลัดกุ้งกรอบผลไม้รวม M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">350.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หมูซีอิ๊วฮ่องกง S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">2</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">370.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หมูกรอบ M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">3</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">840.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) กุ้งแชบ๊วยชุบแป้งทอด S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">225.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ไก่แช่เหล้า M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">490.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หอยจ้อ M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">3</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">1,050.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ออร์เดิร์ฟเย็น 480</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">480.00</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="left">Total Baht 18</td><td align="right" colspan="2">5,165.00</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="left" colspan="2">Service Charge 10.00%</td><td align="right">516.50</td></tr><tr><td class="h0text" align="left" colspan="2">NET BAHT</td><td class="h0text" align="right">5,681.50</td></tr><tr><td class="h0text" align="left">Due Payment</td><td class="h0text" valign="top" align="right" colspan="2">5,681.50</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="center" colspan="3">VAT Included<br>Thank You. Please come again.</td></tr><tr><td align="center" colspan="3" style="height:6mm;"></td></tr><tr><td align="center" class="h1text" colspan="3"><img src="data:image/png;base64,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"></td></tr><tr><td align="center" colspan="3" style="height:6mm;"></td></tr></table></body></html>';
    try {
      await Printer.printBill("192.168.1.87", 9100, content);
      setState(() {
        _errMsg = "Printed";
      });
    } on PlatformException catch (e) {
      setState(() {
        _errMsg = e.message ?? "";
      });
    }
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
                    onPressed: _testPrinter, child: Text("Test Printer")),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errMsg,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          )),
    );
  }
}
