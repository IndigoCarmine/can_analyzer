import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'usbcan.dart';

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
  UsbCan usbCan = UsbCan();
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
              UsbDevice? port = usbCan.device;
              if (port == null) {
                return const Text("NOT");
              } else {
                return Column(
                  children: [
                    Text(port.deviceId.toString()),
                    Text(port.manufacturerName ?? ""),
                    Text(port.productName ?? ""),
                    Text(port.vid.toString())
                  ],
                );
              }
            }),
            StreamBuilder(
              stream: usbCan.stream,
              builder: (context, snapshot) {
                return Text(
                    snapshot.hasData ? snapshot.data!.data.toString() : "");
              },
            ),
            TextButton(
              child: const Text("Send"),
              onPressed: () async {
                usbCan.sendCommand(
                    Command.establishmentOfCommunication, Uint8List(0));
                int counter = 0;
                while (counter < 4) {
                  if (usbCan.connectionEstablished) {
                    const snackBar = SnackBar(content: Text("Hello!"));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }
                  sleep(const Duration(seconds: 1));
                  await usbCan.sendCommand(
                      Command.establishmentOfCommunication, Uint8List(0));
                  counter++;
                }
                const snackBar = SnackBar(content: Text("Can not call back!"));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            )
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!(await usbCan.connectUSB())) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("USB CAN NOT CONNECTED"),
              ));
            }
          }
          setState(() {});
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
