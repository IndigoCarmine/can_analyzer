import 'dart:async';
import 'dart:typed_data';

import 'package:can_analyzer/stream_list_builder.dart';
import 'package:flutter/material.dart';
import 'usbcan.dart';
import 'widgets.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key, required this.title});
  final String title;
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Stream<CANFrame> testStream() async* {
    int counter = 0;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 1000));
      yield CANFrame.fromIdAndData(counter, Uint8List(0));
      counter++;
    }
  }

  UsbCanFormStyle usbcanStyle = UsbCanFormStyle.simple;
  StreamController<CANFrame> streamController = StreamController<CANFrame>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              UsbCanForm(
                onSendButtonPressed: (CANFrame frame) {
                  streamController.add(frame);
                },
                style: usbcanStyle,
              ),
              Row(
                children: [
                  const Text("Use detailed form"),
                  const SizedBox(width: 20),
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
              Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  child: StreamListBuilder(
                      max: 5,
                      builder: (context, data) => CanFrameTile(
                          frame: data, mode: CanWidgetMode.hexMode),
                      stream: testStream()),
                ),
              ),
            ],
          ),
        ));
  }
}
