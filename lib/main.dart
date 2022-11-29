
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
      home: MyHomePage(title: 'Flutter Demo Home Page', usbCan: UsbCan()),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key, required this.title,required this.usbCan});

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
              UsbDevice? deviceNow = widget.usbCan.device;
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
            StreamBuilder(stream: widget.usbCan.usbStream(),  builder: (context, snapshot){return Text(snapshot.hasData ? snapshot.data??"":"");},
            )
            ,
            TextButton(
              child: const Text("Send"),
              onPressed: () async {
                widget.usbCan.send("AAA\r");
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
