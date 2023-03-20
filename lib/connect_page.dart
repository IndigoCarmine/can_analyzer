import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

import 'stream_list_builder.dart';
import 'usbcan.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key, required this.usbCan});
  final UsbCan usbCan;
  @override
  State<ConnectPage> createState() => _ConnectPageState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "Connect";
  }
}

class _ConnectPageState extends State<ConnectPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Builder(builder: (builder) {
            UsbDevice? port = widget.usbCan.device;
            if (port == null) {
              return const SizedBox(
                  height: 300,
                  child: Center(
                      child: Text("No device Connected",
                          style: TextStyle(fontSize: 30))));
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
          Container(
            padding: const EdgeInsets.all(10),
            child: TextButton(
              child: const Text("Negotiation test"),
              onPressed: () async {
                // widget.usbCan.connectionEstablished = false;
                Uint8List data = const AsciiEncoder().convert("HelloUSBCAN");
                widget.usbCan
                    .sendCommand(Command.establishmentOfCommunication, data);
                int counter = 0;
                while (counter < 4) {
                  if (widget.usbCan.connectionEstablished) {
                    const snackBar = SnackBar(
                        content:
                            Text("Hello! This is newest version of USBCAN!!"));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }
                  await Future.delayed(const Duration(seconds: 1));
                  widget.usbCan
                      .sendCommand(Command.establishmentOfCommunication, data);
                  counter++;
                }
                const snackBar =
                    SnackBar(content: Text("Something went wrong!"));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ),
          StreamListBuilder<CANFrame>(
            stream: widget.usbCan.stream,
            builder: (context, data) {
              return Text(data.toString());
            },
            max: 3,
          ),
        ],
      ),
    );
  }
}
