import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbCan{
  UsbPort? port;
  UsbDevice? device;
  Future<bool> connectUSB() async{
    //Search a usbcan.
    List<UsbDevice> devices = await UsbSerial.listDevices();
    UsbDevice? device;
    for (var element in devices) {
      if (element.manufacturerName == "STMicroelectronics") device = element;
    }
    if(device==null)return false;

    //set a port.
    if (device.port != null) {
      port = await device.create();
    } else {
      return false;
    }
    if(port == null)return false; 
    //open a port.
    if (!(await port!.open())) return false;
    await port!.setDTR(true);
    await port!.setRTS(true);

    port!.setPortParameters(115200, UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    return true;

  }

  Future<bool> send(String text) async{
    var asciien = const AsciiEncoder();
    if(port ==null)return false;
    await port!.write(asciien.convert(text));
      return true;
  }
  
  //this is stream for receive data.
  Stream<String> usbStream() async*{
    if(port==null)connectUSB();
    var asciide = const AsciiDecoder();
    Uint8List buffer = Uint8List(0);
    await for(Uint8List data in port!.inputStream!){
      for(int i = 0; i < data.length; i++){
        if(data[i] == '\r'.codeUnitAt(0)){
          yield asciide.convert(buffer);
          buffer = Uint8List(0);
        }
      }

    }
  }
}