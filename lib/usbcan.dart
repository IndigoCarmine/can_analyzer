import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:libserialport/libserialport.dart';
import 'package:cobs2/cobs2.dart';

class UsbCan {
  SerialPort? port;
  Future<bool> connectUSB() async {
    //Search a usbcan.
    List<String> devices = SerialPort.availablePorts;
    for (var element in devices) {
      SerialPort port_ = SerialPort(element);
      if (port_.manufacturer == "STMicroelectronics") {
        port = port_;
        break;
      }
    }
    if (port == null) return false;

    //open a port.
    if (port!.openReadWrite()) return false;

    return true;
  }

  Future<bool> send(String text) async {
    if (port == null) return false;
    ByteData encoded = ByteData(64);
    EncodeResult encodeResult =
        encodeCOBS(encoded, ByteData.sublistView(ascii.encode(text)));
    if (encodeResult.status != EncodeStatus.OK) return false;
    port!.write(encoded.buffer.asUint8List(0, encodeResult.outLen));
    return true;
  }

  //this is stream for receive data.
  Stream<String> usbStream() async* {
    if (port == null) connectUSB();
    var asciide = const AsciiDecoder();
    Uint8List buffer = Uint8List(0);
    final reader = SerialPortReader(port!);
    await for (Uint8List data in reader.stream) {
      for (int i = 0; i < data.length; i++) {
        if (data[i] == 0) {
          ByteData decoded = ByteData(64);
          DecodeResult decodeResult =
              decodeCOBS(decoded, ByteData.sublistView(buffer));
          if (decodeResult.status != DecodeStatus.OK) {
            buffer = Uint8List(0);
            continue;
          }
          yield asciide
              .convert(decoded.buffer.asUint8List(0, decodeResult.outLen));
          buffer = Uint8List(0);
        } else {
          buffer = Uint8List.fromList(buffer + [data[i]]);
        }
      }
    }
  }
}
