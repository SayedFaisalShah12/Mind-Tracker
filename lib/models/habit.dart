import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String emoji;

  @HiveField(3)
  String color;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isCustom; // true if user created, false if default

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.isCustom = false,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCustom,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCustom': isCustom,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      color: json['color'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isCustom: json['isCustom'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, emoji: $emoji, color: $color, isActive: $isActive)';
  }
}
