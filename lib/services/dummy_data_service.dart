import '../models/mood_entry.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import 'mood_service.dart';
import 'habit_service.dart';

class DummyDataService {
  static Future<void> addDummyData() async {
    final moodService = MoodService();
    final habitService = HabitService();
    
    // Add default habits
    final now = DateTime.now();
    final habits = [
      Habit(
        id: '1',
        name: 'Exercise',
        emoji: '🏃‍♂️',
        color: 'green',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        isCustom: false,
      ),
      Habit(
        id: '2',
        name: 'Meditation',
        emoji: '🧘‍♀️',
        color: 'purple',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        isCustom: false,
      ),
      Habit(
        id: '3',
        name: 'Read',
        emoji: '📚',
        color: 'blue',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        isCustom: false,
      ),
      Habit(
        id: '4',
        name: 'Drink Water',
        emoji: '💧',
        color: 'teal',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        isCustom: false,
      ),
      Habit(
        id: '5',
        name: 'Sleep Early',
        emoji: '😴',
        color: 'indigo',
        isActive: true,
        createdAt: now,
        updatedAt: now,
        isCustom: false,
      ),
    ];

    // Add habits
    for (final habit in habits) {
      await habitService.addHabit(habit);
    }

    // Add some mood entries for the past week
    final moodEntries = <MoodEntry>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final moodValue = _getRandomMoodValue();
      final emoji = _getMoodEmoji(moodValue);
      
      final moodEntry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        date: date,
        moodValue: moodValue,
        emoji: emoji,
        notes: _getRandomNote(),
        tags: _getRandomTags(),
        createdAt: date,
        updatedAt: date,
      );
      
      moodEntries.add(moodEntry);
    }

    // Add mood entries
    for (final moodEntry in moodEntries) {
      await moodService.addMoodEntry(moodEntry);
    }

    // Add some habit entries for the past week
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      
      for (final habit in habits) {
        final completed = _getRandomBool();
        final habitEntry = HabitEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString() + habit.id + i.toString(),
          habitId: habit.id,
          date: date,
          completed: completed,
          notes: completed ? _getRandomHabitNote() : null,
          createdAt: date,
          updatedAt: date,
        );
        
        await habitService.toggleHabitEntry(
          habit.id,
          date,
          completed,
          habitEntry.notes,
        );
      }
    }
  }

  static int _getRandomMoodValue() {
    // Weighted random: more likely to be 3-4
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 10) return 1; // 10% chance
    if (random < 20) return 2; // 10% chance
    if (random < 50) return 3; // 30% chance
    if (random < 80) return 4; // 30% chance
    return 5; // 20% chance
  }

  static String _getMoodEmoji(int moodValue) {
    switch (moodValue) {
      case 1: return '😢';
      case 2: return '😔';
      case 3: return '😐';
      case 4: return '😊';
      case 5: return '😄';
      default: return '😐';
    }
  }

  static String? _getRandomNote() {
    final notes = [
      'Had a great day at work!',
      'Feeling stressed about upcoming exams.',
      'Went for a nice walk in the park.',
      'Had dinner with friends.',
      'Slept well last night.',
      'Weather was beautiful today.',
      'Completed all my tasks.',
      'Feeling grateful for everything.',
      'Had some challenges but overcame them.',
      'Spent quality time with family.',
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    return random < 60 ? notes[random % notes.length] : null; // 60% chance of having a note
  }

  static List<String> _getRandomTags() {
    final allTags = ['Work', 'Family', 'Friends', 'Health', 'Exercise', 'Sleep', 'Food', 'Weather'];
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    if (random < 40) return []; // 40% chance of no tags
    
    final numTags = (random % 3) + 1; // 1-3 tags
    final shuffledTags = List.from(allTags)..shuffle();
    return shuffledTags.take(numTags).toList().cast<String>();
  }

  static bool _getRandomBool() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    return random < 70; // 70% chance of completion
  }

  static String? _getRandomHabitNote() {
    final notes = [
      'Felt great after this!',
      'Easy to do today.',
      'Helped me relax.',
      'Made me feel productive.',
      'Enjoyed this activity.',
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    return random < 30 ? notes[random % notes.length] : null; // 30% chance of having a note
  }
}
