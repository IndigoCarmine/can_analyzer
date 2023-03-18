import 'dart:convert';

import 'package:can_analyzer/usbcan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum UsbCanFormStyle {
  all,
  simple,
}

class UsbCanForm extends StatefulWidget {
  const UsbCanForm(
      {super.key, required this.onSendButtonPressed, required this.style});

  final void Function(CANFrame) onSendButtonPressed;
  final UsbCanFormStyle style;

  @override
  State<UsbCanForm> createState() => _UsbCanFormState();
}

class _UsbCanFormState extends State<UsbCanForm> {
  int _canId = 0;
  Uint8List _data = Uint8List(0);

  HexSwitchFieldMode mode = HexSwitchFieldMode.hexMode;
  @override
  Widget build(BuildContext context) {
    if (widget.style == UsbCanFormStyle.simple) {
      return Container(
          child: Column(children: [
        HexSwitchField(
          mode: HexSwitchFieldMode.hexMode,
          onChanged: (value) {
            _canId = value.fold(0, (value, element) => value << 4 + element);
          },
        ),
        HexSwitchField(
          mode: mode,
          onChanged: (value) {
            _data = value;
          },
        ),
        DropdownMenu(
          dropdownMenuEntries: HexSwitchFieldMode.values
              .map((mode) =>
                  DropdownMenuEntry(value: mode, label: mode.toString()))
              .toList(),
          onSelected: (value) {
            setState(() {
              mode = value ?? HexSwitchFieldMode.hexMode;
            });
          },
        ),
        ElevatedButton(
            onPressed: () {
              widget.onSendButtonPressed(CANFrame.fromIdAndData(_canId, _data));
            },
            child: const Text("Send"))
      ]));
    } else {
      return Container(
        child: TextField(),
      );
    }
  }
}

enum HexSwitchFieldMode {
  hexMode,
  stringMode,
  floatMode,
  doubleMode,
  int16Mode,
  int32Mode,
}

class HexSwitchField extends StatefulWidget {
  const HexSwitchField(
      {super.key, required this.onChanged, required this.mode});

  final void Function(Uint8List) onChanged;
  final HexSwitchFieldMode mode;

  @override
  State<HexSwitchField> createState() => _HexSwitchFieldState();
}

class _HexSwitchFieldState extends State<HexSwitchField> {
  Uint8List _data = Uint8List(0);

  @override
  Widget build(BuildContext context) {
    switch (widget.mode) {
      case HexSwitchFieldMode.hexMode:
        return TextField(
          onChanged: (value) {
            _data = Uint8List.fromList(value
                .split("")
                .map((e) {
                  if (e == " ") {
                    return null;
                  } else {
                    return int.parse(e, radix: 16);
                  }
                })
                .where((element) => element != null)
                .toList()
                .cast());
            widget.onChanged(_data);
          },
          controller: TextEditingController(
              text: _data
                  .map((e) => e.toRadixString(16).padLeft(2, "0"))
                  .join(" ")
                  .toUpperCase()),
          keyboardType: TextInputType.visiblePassword,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.length > oldValue.text.length) {
                var sharpedData = newValue.text
                    .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
                    .toUpperCase()
                    .split("")
                    .asMap()
                    .map((key, value) {
                  if (key % 2 == 1) {
                    return MapEntry(key, "$value ");
                  } else {
                    return MapEntry(key, value);
                  }
                });
                return TextEditingValue(
                    text: sharpedData.values.join(),
                    selection: TextSelection.collapsed(
                        offset: sharpedData.values.join().length));
              } else {
                return newValue;
              }
            })
          ],
        );
      case HexSwitchFieldMode.stringMode:
        return TextField(
            keyboardType: TextInputType.visiblePassword,
            onChanged: (value) {
              _data = const AsciiEncoder().convert(value);
              widget.onChanged(_data);
            },
            controller: TextEditingController(
                text: const AsciiDecoder().convert(_data)));
      default:
        return Text("Not implemented: ${widget.mode}");
    }
  }
}
