import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';
import '../utils/uuid_generator.dart';

class MoodService {
  static const String _boxName = 'mood_entries';
  late Box<MoodEntry> _box;

  Future<void> init() async {
    _box = await Hive.openBox<MoodEntry>(_boxName);
  }

  Future<List<MoodEntry>> getMoodEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final entries = _box.values.toList();
    
    if (startDate != null || endDate != null) {
      return entries.where((entry) {
        if (startDate != null && entry.date.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && entry.date.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    }
    
    return entries;
  }

  Future<MoodEntry?> getTodayMood() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final entries = await getMoodEntries(
      startDate: todayStart,
      endDate: todayEnd,
    );

    return entries.isNotEmpty ? entries.first : null;
  }

  Future<MoodEntry?> getMoodEntryById(String id) async {
    return _box.get(id);
  }

  Future<void> addMoodEntry(MoodEntry moodEntry) async {
    await _box.put(moodEntry.id, moodEntry);
  }

  Future<void> updateMoodEntry(MoodEntry moodEntry) async {
    final updatedEntry = moodEntry.copyWith(
      updatedAt: DateTime.now(),
    );
    await _box.put(moodEntry.id, updatedEntry);
  }

  Future<void> deleteMoodEntry(String id) async {
    await _box.delete(id);
  }

  Future<List<MoodEntry>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await getMoodEntries(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<double> getAverageMood({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final entries = await getMoodEntries(
      startDate: startDate,
      endDate: endDate,
    );

    if (entries.isEmpty) return 0.0;

    final totalMood = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.moodValue,
    );

    return totalMood / entries.length;
  }

  Future<Map<int, int>> getMoodDistribution({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final entries = await getMoodEntries(
      startDate: startDate,
      endDate: endDate,
    );

    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = 0;
    }

    for (final entry in entries) {
      distribution[entry.moodValue] = 
          (distribution[entry.moodValue] ?? 0) + 1;
    }

    return distribution;
  }

  Future<void> close() async {
    await _box.close();
  }
}
