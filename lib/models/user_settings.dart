import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 3)
class UserSettings extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String themeMode; // 'light', 'dark', 'system'

  @HiveField(2)
  bool biometricEnabled;

  @HiveField(3)
  bool notificationsEnabled;

  @HiveField(4)
  String reminderTime; // HH:mm format

  @HiveField(5)
  List<String> customMoodEmojis;

  @HiveField(6)
  String primaryColor;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  UserSettings({
    required this.id,
    this.themeMode = 'system',
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.reminderTime = '20:00',
    this.customMoodEmojis = const ['😢', '😔', '😐', '😊', '😄'],
    this.primaryColor = 'blue',
    required this.createdAt,
    required this.updatedAt,
  });

  UserSettings copyWith({
    String? id,
    String? themeMode,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    String? reminderTime,
    List<String>? customMoodEmojis,
    String? primaryColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      customMoodEmojis: customMoodEmojis ?? this.customMoodEmojis,
      primaryColor: primaryColor ?? this.primaryColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'themeMode': themeMode,
      'biometricEnabled': biometricEnabled,
      'notificationsEnabled': notificationsEnabled,
      'reminderTime': reminderTime,
      'customMoodEmojis': customMoodEmojis,
      'primaryColor': primaryColor,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'],
      themeMode: json['themeMode'] ?? 'system',
      biometricEnabled: json['biometricEnabled'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      reminderTime: json['reminderTime'] ?? '20:00',
      customMoodEmojis: List<String>.from(json['customMoodEmojis'] ?? ['😢', '😔', '😐', '😊', '😄']),
      primaryColor: json['primaryColor'] ?? 'blue',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'UserSettings(id: $id, themeMode: $themeMode, biometricEnabled: $biometricEnabled, notificationsEnabled: $notificationsEnabled)';
  }
}
