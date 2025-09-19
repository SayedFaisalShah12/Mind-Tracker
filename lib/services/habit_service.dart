import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../utils/uuid_generator.dart';

class HabitService {
  static const String _habitsBoxName = 'habits';
  static const String _habitEntriesBoxName = 'habit_entries';
  
  late Box<Habit> _habitsBox;
  late Box<HabitEntry> _habitEntriesBox;

  Future<void> init() async {
    _habitsBox = await Hive.openBox<Habit>(_habitsBoxName);
    _habitEntriesBox = await Hive.openBox<HabitEntry>(_habitEntriesBoxName);
  }

  // Habit CRUD operations
  Future<List<Habit>> getHabits() async {
    return _habitsBox.values.toList();
  }

  Future<Habit?> getHabitById(String id) async {
    return _habitsBox.get(id);
  }

  Future<void> addHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    final updatedHabit = habit.copyWith(
      updatedAt: DateTime.now(),
    );
    await _habitsBox.put(habit.id, updatedHabit);
  }

  Future<void> deleteHabit(String id) async {
    // Delete all related habit entries
    final entries = _habitEntriesBox.values
        .where((entry) => entry.habitId == id)
        .toList();
    
    for (final entry in entries) {
      await _habitEntriesBox.delete(entry.id);
    }
    
    // Delete the habit
    await _habitsBox.delete(id);
  }

  // Habit Entry operations
  Future<Map<String, List<HabitEntry>>> getHabitEntries() async {
    final entries = _habitEntriesBox.values.toList();
    final groupedEntries = <String, List<HabitEntry>>{};

    for (final entry in entries) {
      if (!groupedEntries.containsKey(entry.habitId)) {
        groupedEntries[entry.habitId] = [];
      }
      groupedEntries[entry.habitId]!.add(entry);
    }

    return groupedEntries;
  }

  Future<List<HabitEntry>> getHabitEntriesByHabitId(String habitId) async {
    return _habitEntriesBox.values
        .where((entry) => entry.habitId == habitId)
        .toList();
  }

  Future<List<HabitEntry>> getHabitEntriesByDate(DateTime date) async {
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    return _habitEntriesBox.values
        .where((entry) => 
            entry.date.isAfter(dateStart) && 
            entry.date.isBefore(dateEnd))
        .toList();
  }

  Future<void> toggleHabitEntry(
    String habitId,
    DateTime date,
    bool completed,
  ) async {
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    // Check if entry already exists for this date
    final existingEntry = _habitEntriesBox.values
        .where((entry) => 
            entry.habitId == habitId &&
            entry.date.isAfter(dateStart) &&
            entry.date.isBefore(dateEnd))
        .firstOrNull;

    if (existingEntry != null) {
      // Update existing entry
      final updatedEntry = existingEntry.copyWith(
        completed: completed,
      );
      await _habitEntriesBox.put(existingEntry.id, updatedEntry);
    } else {
      // Create new entry
      final newEntry = HabitEntry(
        id: UuidGenerator.generate(),
        habitId: habitId,
        date: date,
        completed: completed,
        createdAt: DateTime.now(),
      );
      await _habitEntriesBox.put(newEntry.id, newEntry);
    }
  }

  Future<double> getHabitCompletionRate(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entries = await getHabitEntriesByHabitId(habitId);
    
    final relevantEntries = entries.where((entry) =>
        entry.date.isAfter(startDate) &&
        entry.date.isBefore(endDate)).toList();

    if (relevantEntries.isEmpty) return 0.0;

    final completedCount = relevantEntries
        .where((entry) => entry.completed)
        .length;

    return completedCount / relevantEntries.length;
  }

  Future<Map<String, double>> getAllHabitsCompletionRate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final habits = await getHabits();
    final completionRates = <String, double>{};

    for (final habit in habits) {
      final rate = await getHabitCompletionRate(
        habit.id,
        startDate,
        endDate,
      );
      completionRates[habit.id] = rate;
    }

    return completionRates;
  }

  Future<void> close() async {
    await _habitsBox.close();
    await _habitEntriesBox.close();
  }
}
