import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HiveHelper {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    
    _initialized = true;
  }

  static Future<Box<T>> openBox<T>(String boxName) async {
    await init();
    return await Hive.openBox<T>(boxName);
  }

  static Future<void> closeBox(String boxName) async {
    await Hive.box(boxName).close();
  }

  static Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }

  static Future<void> clearBox(String boxName) async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}
