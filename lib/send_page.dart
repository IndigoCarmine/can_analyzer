import 'dart:async';

import 'stream_list_builder.dart';
import 'package:usbcan_plugins/usbcan.dart';
import 'package:flutter/material.dart';

import 'package:usbcan_plugins/widgets.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key, required this.usbCan});
  final UsbCan usbCan;
  @override
  State<SendPage> createState() => _SendPageState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "Send";
  }
}

class _SendPageState extends State<SendPage> {
  UsbCanFormStyle usbcanStyle = UsbCanFormStyle.simple;
  StreamController<CANFrame> streamController = StreamController<CANFrame>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          UsbCanForm(
            onSendButtonPressed: (CANFrame frame) {
              streamController.add(frame);
              widget.usbCan.sendFrame(frame);
            },
            style: usbcanStyle,
            enabledModes: const [
              CanWidgetMode.hexMode,
              CanWidgetMode.floatMode,
              CanWidgetMode.stringMode
            ],
          ),
          SizedBox(
            height: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Use detailed form"),
                const SizedBox(width: 10),
                Checkbox(
                    value: usbcanStyle == UsbCanFormStyle.all,
                    onChanged: (value) {
                      setState(() {
                        usbcanStyle = value ?? false
                            ? UsbCanFormStyle.all
                            : UsbCanFormStyle.simple;
                      });
                    }),
              ],
            ),
          ),
          Container(
              margin: const EdgeInsets.only(top: 20),
              height: 20,
              color: Colors.grey[300],
              child: const Center(
                  child: Text(
                "recent frames",
                style: TextStyle(fontSize: 15),
              ))),
          Expanded(
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey[100]!)),
              alignment: Alignment.topCenter,
              child: StreamListBuilder(
                max: 5,
                builder: (context, data) => SizedBox(
                  height: 60,
                  child: CanFrameTile(
                    frame: data,
                    onFrameTap: (frame) {
                      widget.usbCan.sendFrame(frame);
                    },
                    mode: CanWidgetMode.hexMode,
                  ),
                ),
                stream: streamController.stream,
                isEqual: (previous, next) => previous == next,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
