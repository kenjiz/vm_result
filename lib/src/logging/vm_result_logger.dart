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
abstract class VMResultLogger {
  /// Logs an informational message.
  void info(String message);

  /// Logs a warning message.
  void warning(String message);

  /// Logs an error message with an optional stack trace.
  void error(String message, [StackTrace? stackTrace]);
}

/// A default logger implementation that uses standard [dart:developer] log.
class DefaultVMResultLogger implements VMResultLogger {
  /// Creates a constant [DefaultVMResultLogger].
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

/// Global configuration registry for the vm_result package logging.
class VMResultLogging {
  /// The active [VMResultLogger] instance.
  ///
  /// Defaults to [DefaultVMResultLogger] which prints to standard [dart:developer] logs.
  static VMResultLogger logger = const DefaultVMResultLogger();
}
