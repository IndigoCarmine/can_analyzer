import 'package:can_analyzer/connect_page.dart';
import 'package:can_analyzer/recieve_page.dart';
import 'package:can_analyzer/send_page.dart';
import 'package:flutter/material.dart';
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
      title: 'Can Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: "Can Analyzer"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UsbCan usbCan = UsbCan();
  List<Widget> pages = [
    ConnectPage(usbCan: UsbCan()),
    SendPage(usbCan: UsbCan()),
    RecievePage(usbCan: UsbCan()),
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: pages.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontSize: 20)),
          bottom: TabBar(tabs: getTabs()),
        ),
        body: TabBarView(
          children: pages,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!(await usbCan.connectUSB())) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("USBCAN IS NOT CONNECTED"),
                ));
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("USBCAN CONNECTED"),
                ));
              }
            }
            setState(() {});
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<Widget> getTabs() {
    return pages.map((e) => Tab(text: e.toString())).toList();
  }
}
