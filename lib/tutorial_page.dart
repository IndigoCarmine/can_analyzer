import 'package:flutter/material.dart';
// import 'package:flutter_sliding_tutorial/flutter_sliding_tutorial.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});
  static const TextStyle _textStyle =
      TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis);
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
      Spacer(),
      Text("Hello!!", style: TextStyle(fontSize: 30)),
      Spacer(),
      Text("This is a application  for usb can.", style: _textStyle),
      Text(
        "First, check to see that the device has the latest firmware installed.",
        style: _textStyle,
      ),
      Text(
        "The newest one is the one where the LED goes off quickly after it turns on.",
        style: _textStyle,
      ),
      Text("Last, tap a right buttom to connect to the device.",
          style: _textStyle),
      Spacer(),
      Text(
        "I hope no one suffers from a CAN (and also the app)",
        style: _textStyle,
      ),
      Spacer(),
    ]);
  }
}
