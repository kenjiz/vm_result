import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

final logger = TalkerFlutter.init(
  settings: TalkerSettings(
    enabled: kDebugMode,
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
