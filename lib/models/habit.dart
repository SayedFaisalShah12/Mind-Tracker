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
  List<HabitEntry> entries;

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.entries = const [],
  });

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<HabitEntry>? entries,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      entries: entries ?? this.entries,
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
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      color: json['color'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      entries: (json['entries'] as List?)
          ?.map((e) => HabitEntry.fromJson(e))
          .toList() ?? [],
    );
  }
}

@HiveType(typeId: 2)
class HabitEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String habitId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool completed;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  DateTime createdAt;

  HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.notes,
    required this.createdAt,
  });

  HabitEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? completed,
    String? notes,
    DateTime? createdAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'completed': completed,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    return HabitEntry(
      id: json['id'],
      habitId: json['habitId'],
      date: DateTime.parse(json['date']),
      completed: json['completed'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
