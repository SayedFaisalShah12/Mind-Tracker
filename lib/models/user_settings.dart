import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 3)
class UserSettings extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isDarkMode;

  @HiveField(3)
  String primaryColor;

  @HiveField(4)
  bool biometricEnabled;

  @HiveField(5)
  bool notificationsEnabled;

  @HiveField(6)
  String reminderTime; // HH:mm format

  @HiveField(7)
  List<String> customMoodEmojis;

  @HiveField(8)
  bool hasCompletedOnboarding;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.name,
    this.isDarkMode = false,
    this.primaryColor = 'blue',
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.reminderTime = '20:00',
    this.customMoodEmojis = const ['😢', '😕', '😐', '😊', '😄'],
    this.hasCompletedOnboarding = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserSettings copyWith({
    String? id,
    String? name,
    bool? isDarkMode,
    String? primaryColor,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    String? reminderTime,
    List<String>? customMoodEmojis,
    bool? hasCompletedOnboarding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      name: name ?? this.name,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      primaryColor: primaryColor ?? this.primaryColor,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      customMoodEmojis: customMoodEmojis ?? this.customMoodEmojis,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDarkMode': isDarkMode,
      'primaryColor': primaryColor,
      'biometricEnabled': biometricEnabled,
      'notificationsEnabled': notificationsEnabled,
      'reminderTime': reminderTime,
      'customMoodEmojis': customMoodEmojis,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'],
      name: json['name'],
      isDarkMode: json['isDarkMode'],
      primaryColor: json['primaryColor'],
      biometricEnabled: json['biometricEnabled'],
      notificationsEnabled: json['notificationsEnabled'],
      reminderTime: json['reminderTime'],
      customMoodEmojis: List<String>.from(json['customMoodEmojis'] ?? []),
      hasCompletedOnboarding: json['hasCompletedOnboarding'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
