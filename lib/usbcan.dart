import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:cobs2/cobs2.dart';

class CANFrame {
  // ignore: non_constant_identifier_names
  late int can_id;
  // ignore: non_constant_identifier_names
  late bool is_rtr;
  // ignore: non_constant_identifier_names
  late bool is_extended;
  // ignore: non_constant_identifier_names
  late bool is_error;
  late Uint8List data;
  /*                                                                     
   uint8_t command : if it is normal can frame, it is 0x00.               
   uint8_t id[4] : can id                                                 
   uint8_t frame_type :  is_rtr << 2 | is_extended << 1 | is_error        
   uint8_t dlc : data length                                              
   uint8_t data[8] : data                                                 
   */
  CANFrame(Uint8List frame) {
    can_id =
        ((frame[1] << 24) + (frame[2] << 16) + (frame[3] << 8) + (frame[4]));
    is_rtr = ((frame[5] << 2) % 2 == 1);
    is_extended = ((frame[5] << 1) % 2 == 1);
    is_error = ((frame[5]) % 2 == 1);
    data = frame.sublist(6);
  }
}

enum Command { normal, establishmentOfCommunication }

class UsbCan {
  UsbDevice? device;
  bool connectionEstablished = false;
  Stream<CANFrame>? _stream;
  Stream<CANFrame>? get stream {
    _stream ??= _usbStream();

    return _stream;
  }

  Future<bool> connectUSB() async {
    if (device == null) {
      //Search a usbcan.
      List<UsbDevice> devices = await UsbSerial.listDevices();
      for (var element in devices) {
        if (element.vid == 0x0483 && element.pid == 0x0409) {
          device = element;
          break;
        }
      }
    }

    if (device == null) {
      return false;
    }
    try {
      await device!.create();
    } catch (e) {
      return false;
    }
    if (device!.port == null) return false;

    //open a port.
    if (!(await device!.port!.open())) return false;

    stream!.listen((event) {});
    return true;
  }

  Future<bool> sendCommand(Command command, Uint8List data) async {
    Uint8List sendData = Uint8List(1 + data.length);
    switch (command) {
      case Command.normal:
        sendData[0] = 0 << 4;
        break;
      case Command.establishmentOfCommunication:
        sendData[0] = 1 << 4;
    }
    sendData.setRange(1, data.length + 1, data);
    return await _sendUint8List(sendData);
  }

  //for test
  Future<bool> sendString(String text) async {
    return await _sendUint8List(ascii.encode(text));
  }

  //Simply send Uin8list data.
  Future<bool> _sendUint8List(Uint8List data) async {
    if (device == null || device!.port == null) return false;
    ByteData encoded = ByteData(64);
    EncodeResult encodeResult = encodeCOBS(encoded, ByteData.sublistView(data));
    if (encodeResult.status != EncodeStatus.OK) return false;
    device!.port!.write(encoded.buffer.asUint8List(0, encodeResult.outLen));
    return true;
  }

  Stream<CANFrame> _usbStream() async* {
    while (device == null || device!.port == null) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    final reader = _usbRawStream();
    await for (Uint8List data in reader) {
      switch (data[0]) {
        case 0: //normalframe
          yield CANFrame(data);
          break;
        case 1: //establishment sucsess
          connectionEstablished = true;
      }
    }
  }

  //this is stream for receive data.
  //it do COBS.
  Stream<Uint8List> _usbRawStream() async* {
    Uint8List buffer = Uint8List(0);
    final stream = device!.port!.inputStream;
    await for (Uint8List data in stream!) {
      for (int i = 0; i < data.length; i++) {
        if (data[i] == 0) {
          ByteData decoded = ByteData(64);
          DecodeResult decodeResult =
              decodeCOBS(decoded, ByteData.sublistView(buffer));
          if (decodeResult.status != DecodeStatus.OK) {
            buffer = Uint8List(0);
            continue;
          }
          yield buffer;
          buffer = Uint8List(0);
        } else {
          buffer = Uint8List.fromList(buffer + [data[i]]);
        }
      }
    }
  }
}
