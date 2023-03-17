import 'dart:io';

Future<bool> retry({
  required int maxAttempts,
  required Duration delay,
  required Future<bool> Function() function,
}) async {
  int attempts = 0;
  while (attempts < maxAttempts) {
    if (await function()) {
      return true;
    }
    attempts++;
    sleep(delay);
  }
  return false;
}
