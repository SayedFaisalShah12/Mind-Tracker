import 'package:hive/hive.dart';

part 'habit_entry.g.dart';

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

  @HiveField(6)
  DateTime updatedAt;

  HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  HabitEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? completed,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    return HabitEntry(
      id: json['id'],
      habitId: json['habitId'],
      date: DateTime.parse(json['date']),
      completed: json['completed'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'HabitEntry(id: $id, habitId: $habitId, date: $date, completed: $completed, notes: $notes)';
  }
}
