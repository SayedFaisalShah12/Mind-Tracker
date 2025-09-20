import 'package:hive/hive.dart';
import '../models/mood_entry.dart';
import '../utils/hive_helper.dart';

class MoodService {
  static const String _boxName = 'mood_entries';

  Future<Box<MoodEntry>> get _box async {
    return await HiveHelper.openBox<MoodEntry>(_boxName);
  }

  Future<List<MoodEntry>> getMoodEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final box = await _box;
    final entries = box.values.toList();

    if (startDate != null && endDate != null) {
      return entries.where((entry) {
        return entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               entry.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    return entries;
  }

  Future<MoodEntry?> getMoodEntryByDate(DateTime date) async {
    final box = await _box;
    final entries = box.values.where((entry) {
      return entry.date.year == date.year &&
             entry.date.month == date.month &&
             entry.date.day == date.day;
    }).toList();

    return entries.isNotEmpty ? entries.first : null;
  }

  Future<void> addMoodEntry(MoodEntry moodEntry) async {
    final box = await _box;
    await box.put(moodEntry.id, moodEntry);
  }

  Future<void> updateMoodEntry(MoodEntry moodEntry) async {
    final box = await _box;
    await box.put(moodEntry.id, moodEntry);
  }

  Future<void> deleteMoodEntry(String moodEntryId) async {
    final box = await _box;
    await box.delete(moodEntryId);
  }

  Future<List<MoodEntry>> getMoodEntriesByMonth(DateTime month) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    return getMoodEntries(startDate: startDate, endDate: endDate);
  }

  Future<List<MoodEntry>> getMoodEntriesByWeek(DateTime weekStart) async {
    final endDate = weekStart.add(const Duration(days: 6));
    return getMoodEntries(startDate: weekStart, endDate: endDate);
  }

  Future<double> getAverageMoodForPeriod({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final entries = await getMoodEntries(startDate: startDate, endDate: endDate);
    if (entries.isEmpty) return 0.0;
    
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.moodValue);
    return total / entries.length;
  }
}
