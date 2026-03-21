import 'dart:io';

import 'package:talker_flutter/talker_flutter.dart';

final logger = TalkerFlutter.init(
  settings: TalkerSettings(
    enabled: !Platform.environment.containsKey('FLUTTER_TEST'), // Disable logger in tests
    titles: {
      TalkerKey.error: 'ERROR',
      TalkerKey.warning: 'WARNING',
      TalkerKey.info: 'INFO',
      TalkerKey.debug: 'DEBUG',
      TalkerKey.critical: 'CRITICAL',
      TalkerKey.exception: 'EXCEPTION',
    },
  ),
);
