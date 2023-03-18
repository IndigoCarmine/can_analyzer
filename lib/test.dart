import 'package:flutter/material.dart';
import 'usbcan.dart';
import 'usbcan_widgets.dart';
import 'stream_list_builder.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key, required this.title});
  final String title;
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Stream<int> testStream() async* {
    int counter = 0;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield counter++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: UsbCanForm(
          onSendButtonPressed: (CANFrame frame) {
            print(frame);
          },
          style: UsbCanFormStyle.simple,
        ));
  }
}
