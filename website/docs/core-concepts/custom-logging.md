---
sidebar_position: 5
---

# Custom Logging

By default, `vm_result` logs state transitions, dropped duplicate execution warnings, and unhandled exceptions to the standard Dart developer log (`dart:developer`) in debug mode (`kDebugMode`).

However, for production applications, you usually want to pipe these logs into your own central logging framework (e.g. Firebase Crashlytics, Talker, or Sentry). `vm_result` provides a simple, decoupled contract to do exactly this.

---

## 1. The `VMResultLogger` Contract

To redirect logs, implement the `VMResultLogger` interface:

```dart
import 'package:vm_result/vm_result.dart';

abstract class VMResultLogger {
  void info(String message);
  void warning(String message);
  void error(String message, [StackTrace? stackTrace]);
}
```

---

## 2. Registering a Custom Logger

Assign your custom logger to `VMResultLogging.logger` during application startup (typically in `main.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:vm_result/vm_result.dart';

class MySimpleConsoleLogger implements VMResultLogger {
  @override
  void info(String message) {
    print('[INFO] $message');
  }

  @override
  void warning(String message) {
    print('[WARNING] ⚠️ $message');
  }

  @override
  void error(String message, [StackTrace? stackTrace]) {
    print('[ERROR] ❌ $message');
    if (stackTrace != null) {
      print(stackTrace);
    }
  }
}

void main() {
  // Register the logger before runApp
  VMResultLogging.logger = MySimpleConsoleLogger();
  
  runApp(const MyApp());
}
```

---

## 3. Integrating with `package:talker`

If your project utilizes the popular [talker](https://pub.dev/packages/talker) library for logs and crash reporting, you can plug it in like this:

```dart
import 'package:talker/talker.dart';
import 'package:vm_result/vm_result.dart';

class VMResultTalkerLogger implements VMResultLogger {
  VMResultTalkerLogger(this.talker);
  
  final Talker talker;

  @override
  void info(String message) {
    talker.info(message);
  }

  @override
  void warning(String message) {
    talker.warning(message);
  }

  @override
  void error(String message, [StackTrace? stackTrace]) {
    talker.handle(message, stackTrace, 'VMResult Error');
  }
}

// In main.dart:
void main() {
  final talker = Talker();
  VMResultLogging.logger = VMResultTalkerLogger(talker);
  
  runApp(const MyApp());
}
```
---

## 4. Default Fallback

If you don't configure a custom logger:
* In **Debug Mode (`kDebugMode`)**: Standard outputs are sent to `dart:developer` logs (visible in DevTools and IDE consoles).
* In **Profile / Release Mode**: Logging functions evaluate to no-ops automatically, ensuring zero runtime overhead or leakage of logs in production builds.
