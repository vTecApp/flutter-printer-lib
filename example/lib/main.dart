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
    String logo =
        '<tr><td align="center" colspan="3" class="htext"><img width="200px" src="data:image/jpeg;base64,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4/aA+039Lr06iIvGdPidVTHhDnst9FwP5FTFPt1MPbY0+IyXp7GNnKSqBE8Ecl+ZaL+h1CoWL7j8PkzhfJB4A8Q/qUbomO1IUT4WP3Cy/D9sYyXGQBvMZa9fVfVcYZfnIqkOOvC85+isOIbhqkH5mpjcOjwQf0UHU7l8Wb7Mcb/KRo/MqP4doN26KA0bOBspGjxOGeItkc0HRwJGvULq4BUxxPkidI2wzab6qM/2QYz/AMKP/uh/7i+2bn8ZOtM0ec0XwetfhRYgHQrX4IfyUhFjdNHPKXStzta34qBx3aON0vFEXZC19FYKTchiTvbMUfm4H/8AN1YsM3B/8RV+kTf+pbtp2g3W7aNg3uVmE211QQA08Nha+pPiuChwqurn2jjlmcedjb3nJeisE3S4XT2JhMrhzlJI/l0V1pKWOJvDGxrGjRrAAPcFK1jW7CysMjYz6RZYfsnuNe6z66ThGvZR6nwLuXotkwLAqakjEdPE2NvgMz4k8ypRFst0RERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERERF/9k="/></td></tr>';
    String content =
        '<html><header><META HTTP-EQUIV="Pragma" CONTENT="no-cache"><META HTTP-EQUIV="Expires" CONTENT="-1"><style type="text/css"> body, td, th { font-family: Tahoma, Verdana, Arial; font-weight: normal; font-size: 12px;} .htext { font-family: Tahoma, Verdana, Arial; font-weight: bold; font-size: 20px; } .h1text { font-family: Tahoma, Verdana, Arial; font-weight: bold; font-size: 16px; } .h0text { font-family: Tahoma, Verdana, Arial; font-weight: bold; font-size: 12px; } </style></header><body><table border="0" cellpadding="2" cellspacing="0" style="border-collapse:collapse; width:70mm;">$logo<tr><td align="center" colspan="3" class="htext">008</td></tr><tr><td align="center" colspan="3" style="height:2mm;"></td></tr><tr><td align="center" colspan="3">Vertical Tec Cloud POS<br>388/68 บิซแกลเลอเรีย นวลจันทร์<br>เขตบึงกุ่ม กรุงเทพฯ 10230<br>TaxID : 0105557771999<br>ใบเสร็จรับเงิน/ใบกำกับภาษีอย่างย่อ<br>POS ID : E00000000000000</td></tr><tr><td align="center" colspan="3" style="height:2mm;"></td></tr><tr><td align="left" colspan="3">Date: 20/01/2022 13:42:02</td></tr><tr><td align="left" colspan="3">Order No.:008</td></tr><tr><td align="left">No Customer:1</td><td align="right" colspan="2">Eat In</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ไก่แช่เหล้ายำแมงกะพรุน 375</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">375.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หอยจ้อ S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">3</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">555.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ไก่แช่เหล้า S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">245.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ทอดมันกุ้ง S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">185.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) สลัดกุ้งกรอบผลไม้รวม M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">350.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หมูซีอิ๊วฮ่องกง S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">2</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">370.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หมูกรอบ M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">3</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">840.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) กุ้งแชบ๊วยชุบแป้งทอด S</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">225.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ไก่แช่เหล้า M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">490.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) หอยจ้อ M</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">3</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">1,050.00</td></tr><tr><td align="left" style="width:200px;overflow:hidden;">(DI) ออร์เดิร์ฟเย็น 480</td><td valign="top" align="center" style="width:5mm;overflow:hidden;">1</td><td valign="top" align="right" style="width:20mm;overflow:hidden;">480.00</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="left">Total Baht 18</td><td align="right" colspan="2">5,165.00</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="left" colspan="2">Service Charge 10.00%</td><td align="right">516.50</td></tr><tr><td class="h0text" align="left" colspan="2">NET BAHT</td><td class="h0text" align="right">5,681.50</td></tr><tr><td class="h0text" align="left">Due Payment</td><td class="h0text" valign="top" align="right" colspan="2">5,681.50</td></tr><tr><td align="left" colspan="3"><hr/></td></tr><tr><td align="center" colspan="3">VAT Included<br>Thank You. Please come again.</td></tr><tr><td align="center" colspan="3" style="height:6mm;"></td></tr><tr><td align="center" class="h1text" colspan="3"><img src="data:image/png;base64,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"></td></tr><tr><td align="center" colspan="3" style="height:6mm;"></td></tr></table></body></html>';
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
