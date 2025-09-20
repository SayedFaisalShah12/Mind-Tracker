import 'package:hive/hive.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import '../utils/hive_helper.dart';

class HabitService {
  static const String _habitsBoxName = 'habits';
  static const String _habitEntriesBoxName = 'habit_entries';

  Future<Box<Habit>> get _habitsBox async {
    return await HiveHelper.openBox<Habit>(_habitsBoxName);
  }

  Future<Box<HabitEntry>> get _habitEntriesBox async {
    return await HiveHelper.openBox<HabitEntry>(_habitEntriesBoxName);
  }

  Future<List<Habit>> getHabits() async {
    final box = await _habitsBox;
    return box.values.where((habit) => habit.isActive).toList();
  }

  Future<List<HabitEntry>> getHabitEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final box = await _habitEntriesBox;
    final entries = box.values.toList();

    if (startDate != null && endDate != null) {
      return entries.where((entry) {
        return entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               entry.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    return entries;
  }

  Future<Map<String, HabitEntry>> getHabitEntriesByDate(DateTime date) async {
    final box = await _habitEntriesBox;
    final entries = box.values.where((entry) {
      return entry.date.year == date.year &&
             entry.date.month == date.month &&
             entry.date.day == date.day;
    }).toList();

    final Map<String, HabitEntry> result = {};
    for (final entry in entries) {
      result[entry.habitId] = entry;
    }
    return result;
  }

  Future<void> addHabit(Habit habit) async {
    final box = await _habitsBox;
    await box.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    final box = await _habitsBox;
    await box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String habitId) async {
    final box = await _habitsBox;
    await box.delete(habitId);
    
    // Also delete all related habit entries
    final entriesBox = await _habitEntriesBox;
    final entriesToDelete = entriesBox.values
        .where((entry) => entry.habitId == habitId)
        .map((entry) => entry.id)
        .toList();
    
    for (final entryId in entriesToDelete) {
      await entriesBox.delete(entryId);
    }
  }

  Future<void> toggleHabitActive(String habitId, bool isActive) async {
    final box = await _habitsBox;
    final habit = box.get(habitId);
    if (habit != null) {
      final updatedHabit = habit.copyWith(isActive: isActive);
      await box.put(habitId, updatedHabit);
    }
  }

  Future<HabitEntry> toggleHabitEntry(
    String habitId,
    DateTime date,
    bool completed,
    String? notes,
  ) async {
    final box = await _habitEntriesBox;
    
    // Check if entry already exists for this date and habit
    final existingEntry = box.values.firstWhere(
      (entry) => entry.habitId == habitId &&
                 entry.date.year == date.year &&
                 entry.date.month == date.month &&
                 entry.date.day == date.day,
      orElse: () => HabitEntry(
        id: '',
        habitId: '',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (existingEntry.id.isEmpty) {
      // Create new entry
      final newEntry = HabitEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: habitId,
        date: date,
        completed: completed,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await box.put(newEntry.id, newEntry);
      return newEntry;
    } else {
      // Update existing entry
      final updatedEntry = existingEntry.copyWith(
        completed: completed,
        notes: notes,
        updatedAt: DateTime.now(),
      );
      await box.put(existingEntry.id, updatedEntry);
      return updatedEntry;
    }
  }

  Future<List<HabitEntry>> getHabitEntriesByMonth(DateTime month) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    return getHabitEntries(startDate: startDate, endDate: endDate);
  }

  Future<List<HabitEntry>> getHabitEntriesByWeek(DateTime weekStart) async {
    final endDate = weekStart.add(const Duration(days: 6));
    return getHabitEntries(startDate: weekStart, endDate: endDate);
  }

  Future<double> getHabitCompletionRate(String habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final entries = await getHabitEntries(startDate: startDate, endDate: endDate);
    final habitEntries = entries.where((entry) => entry.habitId == habitId).toList();
    
    if (habitEntries.isEmpty) return 0.0;
    
    final completedCount = habitEntries.where((entry) => entry.completed).length;
    return completedCount / habitEntries.length;
  }
}
