import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../utils/uuid_generator.dart';

class UserSettingsService {
  static const String _boxName = 'user_settings';
  late Box<UserSettings> _box;

  Future<void> init() async {
    _box = await Hive.openBox<UserSettings>(_boxName);
  }

  Future<UserSettings> getUserSettings() async {
    final settings = _box.get('user_settings');
    
    if (settings == null) {
      // Create default settings
      final defaultSettings = UserSettings(
        id: UuidGenerator.generate(),
        name: 'User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _box.put('user_settings', defaultSettings);
      return defaultSettings;
    }
    
    return settings;
  }

  Future<void> updateUserSettings(UserSettings settings) async {
    final updatedSettings = settings.copyWith(
      updatedAt: DateTime.now(),
    );
    await _box.put('user_settings', updatedSettings);
  }

  Future<void> completeOnboarding() async {
    final settings = await getUserSettings();
    final updatedSettings = settings.copyWith(
      hasCompletedOnboarding: true,
    );
    await updateUserSettings(updatedSettings);
  }

  Future<void> toggleTheme() async {
    final settings = await getUserSettings();
    final updatedSettings = settings.copyWith(
      isDarkMode: !settings.isDarkMode,
    );
    await updateUserSettings(updatedSettings);
  }

  Future<void> updateReminderTime(String time) async {
    final settings = await getUserSettings();
    final updatedSettings = settings.copyWith(
      reminderTime: time,
    );
    await updateUserSettings(updatedSettings);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final settings = await getUserSettings();
    final updatedSettings = settings.copyWith(
      notificationsEnabled: enabled,
    );
    await updateUserSettings(updatedSettings);
  }

  Future<void> toggleBiometric(bool enabled) async {
    final settings = await getUserSettings();
    final updatedSettings = settings.copyWith(
      biometricEnabled: enabled,
    );
    await updateUserSettings(updatedSettings);
  }

  Future<void> close() async {
    await _box.close();
  }
}
