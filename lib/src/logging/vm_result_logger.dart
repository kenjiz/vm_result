import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Contract for the logger used by the vm_result package.
///
/// Example on implementing custom logger using talker package
/// ```dart
/// class MyTalkerLogger implements VMResultLogger {
///
///   MyTalkerLogger(this.talker);
///
///   final Talker talker;
///
///   @override
///   void info(String message) => talker.info(message);
///
///   @override
///   void warning(String message) => talker.warning(message);
///
///   @override
///   void error(String message, [StackTrace? stackTrace]) =>
///       talker.handle(message, stackTrace);
/// }
///
/// // In main.dart:
/// VMResultLogging.logger = MyTalkerLogger(Talker());
///
///
/// ```
///
abstract class VmResultLogger {
  void info(String message);

  void warning(String message);

  void error(String message, [StackTrace? stackTrace]);
}

/// A default logger implementation that uses standard [dart:developer] log.
class DefaultVMResultLogger implements VmResultLogger {
  const DefaultVMResultLogger();

  @override
  void error(String message, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      dev.log(
        message,
        name: 'VMResult',
        level: 1000, // 1000 = Severe
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void info(String message) {
    if (kDebugMode) {
      dev.log(message, name: 'VMResult', level: 800); // 800 = Info
    }
  }

  @override
  void warning(String message) {
    if (kDebugMode) {
      dev.log(message, name: 'VMResult', level: 900); // 900 = Warning
    }
  }
}

/// Global configuration for the vm_result package logging.
class VMResultLogging {
  static VmResultLogger logger = const DefaultVMResultLogger();
}
