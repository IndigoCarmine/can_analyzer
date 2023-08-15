import 'package:can_analyzer/stream_list_builder.dart';
import 'package:usbcan_plugins/widgets.dart';
import 'package:flutter/material.dart';

import 'package:usbcan_plugins/usbcan.dart';

class RecievePage extends StatefulWidget {
  const RecievePage({super.key, required this.usbCan});
  final UsbCan usbCan;

  @override
  State<RecievePage> createState() => _RecievePageState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "Recieve";
  }
}

class _RecievePageState extends State<RecievePage> {
  bool deleteSameIdFrames = false;
  bool Function(CANFrame, CANFrame)? isSameId;
  List enabledModes = [
    CanWidgetMode.hexMode,
    CanWidgetMode.floatMode,
    CanWidgetMode.stringMode,
    CanWidgetMode.uint16Mode,
  ];
  CanWidgetMode mode = CanWidgetMode.hexMode;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              DropdownMenu(
                dropdownMenuEntries: enabledModes
                    .map((e) => DropdownMenuEntry(
                          label: e.toString(),
                          value: e,
                        ))
                    .toList(),
                onSelected: (value) {
                  mode = value as CanWidgetMode;
                  setState(() {});
                },
              ),
              const Text("delete same id frames"),
              const SizedBox(width: 20),
              Checkbox(
                  value: deleteSameIdFrames,
                  onChanged: (value) {
                    setState(() {
                      deleteSameIdFrames = value ?? false;
                      if (deleteSameIdFrames) {
                        isSameId = _isSameId;
                      } else {
                        isSameId = null;
                      }
                    });
                  }),
            ],
          ),
          StreamListBuilder(
            stream: widget.usbCan.stream,
            builder: (context, frame) => SizedBox(
                height: 60, child: CanFrameTile(frame: frame, mode: mode)),
            isEqual: isSameId,
          ),
        ],
      ),
    );
  }

  bool _isSameId(CANFrame frame1, CANFrame frame2) {
    return frame1.canId == frame2.canId;
  }
}
