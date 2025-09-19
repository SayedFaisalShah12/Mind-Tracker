import 'dart:math';

class UuidGenerator {
  static const String _chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  static final Random _random = Random();

  static String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomString = List.generate(
      8,
      (index) => _chars[_random.nextInt(_chars.length)],
    ).join();
    
    return '${timestamp}_$randomString';
  }

  static String generateShort() {
    return List.generate(
      8,
      (index) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }
}
