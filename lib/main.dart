import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
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
      home: MyHomePage(title: 'Flutter Demo Home Page', usbCan: UsbCan()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.usbCan});

  final String title;
  final UsbCan usbCan;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
              SerialPort? port = widget.usbCan.port;
              if (port == null) {
                return const Text("NOT");
              } else {
                return Column(
                  children: [
                    Text(port.deviceNumber.toString()),
                    Text(port.manufacturer ?? ""),
                    Text(port.productName ?? ""),
                    Text(port.vendorId.toString())
                  ],
                );
              }
            }),
            StreamBuilder(
              stream: widget.usbCan.usbStream(),
              builder: (context, snapshot) {
                return Text(
                    snapshot.hasData ? snapshot.data!.data.toString() : "");
              },
            ),
            TextButton(
              child: const Text("Send"),
              onPressed: () async {
                widget.usbCan.sendCommand(
                    Command.establishmentOfCommunication, Uint8List(0));
                while (!widget.usbCan.connectionEstablished) {
                  const snackBar = SnackBar(content: Text("Hello!"));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            )
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: widget.usbCan.connectUSB,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
