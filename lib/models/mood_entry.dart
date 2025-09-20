import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int moodValue; // 1-5 scale (1=very sad, 5=very happy)

  @HiveField(3)
  String emoji;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  MoodEntry({
    required this.id,
    required this.date,
    required this.moodValue,
    required this.emoji,
    this.notes,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    int? moodValue,
    String? emoji,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodValue: moodValue ?? this.moodValue,
      emoji: emoji ?? this.emoji,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodValue': moodValue,
      'emoji': emoji,
      'notes': notes,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      moodValue: json['moodValue'],
      emoji: json['emoji'],
      notes: json['notes'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'MoodEntry(id: $id, date: $date, moodValue: $moodValue, emoji: $emoji, notes: $notes, tags: $tags)';
  }
}
