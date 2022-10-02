import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UsbDevice? device;
  void checkPort() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    for (var element in devices) {
      if (element.manufacturerName == "STMicroelectronics") device = element;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Builder(builder: (builder) {
              UsbDevice? deviceNow = device;
              if (deviceNow == null) {
                return const Text("NOT");
              } else {
                return Column(
                  children: [
                    Text(deviceNow.deviceId.toString()),
                    Text(deviceNow.manufacturerName ?? ""),
                    Text(deviceNow.productName ?? ""),
                    Text(deviceNow.serial ?? "")
                  ],
                );
              }
            }),
            TextField(),
            TextButton(
              child: const Text("Send"),
              onPressed: () async {
                UsbPort? port;
                if (device != null && device!.port != null) {
                  port = await device!.create();
                } else {
                  return;
                }
                if (!(await port!.open())) return;
                await port.setDTR(true);
                await port.setRTS(true);

                port.setPortParameters(38400, UsbPort.DATABITS_8,
                    UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

                var asciien = const AsciiEncoder();
                // print first result and close port.
                port.inputStream!.listen(
                  (Uint8List data) {
                    var asciide = const AsciiDecoder();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(asciide.convert(data)),
                    ));
                  },
                );
                await port.write(asciien.convert("TEST"));
              },
            )
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: checkPort,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
