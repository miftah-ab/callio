import 'package:hive_flutter/hive_flutter.dart';

class SettingsStorage {
  static const _boxName = 'settingsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> setAppEnabled(bool isEnabled) async {
    await _box.put('isAppEnabled', isEnabled);
  }

  static bool isAppEnabled() {
    return _box.get('isAppEnabled', defaultValue: true);
  }

  static Future<void> setGlobalDelay(int seconds) async {
    await _box.put('globalDelay', seconds);
  }

  static int getGlobalDelay() {
    return _box.get('globalDelay', defaultValue: 0); // 0 = instantly
  }
}
