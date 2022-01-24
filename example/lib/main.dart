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
