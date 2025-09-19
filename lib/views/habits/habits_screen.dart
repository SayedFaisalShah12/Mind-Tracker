import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/habit/habit_bloc.dart';
import '../../models/habit.dart';
import '../../utils/uuid_generator.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HabitBloc>().add(LoadHabits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddHabitDialog,
          ),
        ],
      ),
      body: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          if (state is HabitLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HabitError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HabitBloc>().add(LoadHabits());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HabitLoaded) {
            if (state.habits.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.habits.length,
              itemBuilder: (context, index) {
                final habit = state.habits[index];
                return _buildHabitCard(habit, state.habitEntries[habit.id] ?? []);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 120,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'No habits yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Start building positive habits by adding your first one!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddHabitDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, List<HabitEntry> entries) {
    final today = DateTime.now();
    final todayEntry = entries.firstWhere(
      (entry) => _isSameDay(entry.date, today),
      orElse: () => HabitEntry(
        id: '',
        habitId: habit.id,
        date: today,
        completed: false,
        createdAt: today,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  habit.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Created ${_formatDate(habit.createdAt)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: habit.isActive,
                  onChanged: (value) {
                    final updatedHabit = habit.copyWith(isActive: value);
                    context.read<HabitBloc>().add(UpdateHabit(updatedHabit));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Today'),
                    value: todayEntry.completed,
                    onChanged: (value) {
                      context.read<HabitBloc>().add(
                        ToggleHabitEntry(
                          habitId: habit.id,
                          date: today,
                          completed: value ?? false,
                        ),
                      );
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditHabitDialog(habit),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteHabitDialog(habit),
                ),
              ],
            ),
            _buildHabitStats(entries),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitStats(List<HabitEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final last7Days = entries.where((entry) {
      final daysDiff = DateTime.now().difference(entry.date).inDays;
      return daysDiff >= 0 && daysDiff < 7;
    }).toList();

    final completedCount = last7Days.where((entry) => entry.completed).length;
    final completionRate = last7Days.isEmpty ? 0.0 : completedCount / last7Days.length;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 7 days: $completedCount/${last7Days.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: completionRate,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completionRate >= 0.7 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(completionRate * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog() {
    final nameController = TextEditingController();
    String selectedEmoji = '✅';
    String selectedColor = 'blue';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Habit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g., Exercise, Read, Meditate',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose an emoji:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['✅', '🏃', '📚', '🧘', '💧', '🌱', '🎯', '💪']
                  .map((emoji) => GestureDetector(
                        onTap: () {
                          selectedEmoji = emoji;
                          Navigator.of(context).pop();
                          _showAddHabitDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final habit = Habit(
                  id: UuidGenerator.generate(),
                  name: nameController.text.trim(),
                  emoji: selectedEmoji,
                  color: selectedColor,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                context.read<HabitBloc>().add(AddHabit(habit));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditHabitDialog(Habit habit) {
    final nameController = TextEditingController(text: habit.name);
    String selectedEmoji = habit.emoji;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Habit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose an emoji:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['✅', '🏃', '📚', '🧘', '💧', '🌱', '🎯', '💪']
                  .map((emoji) => GestureDetector(
                        onTap: () {
                          selectedEmoji = emoji;
                          Navigator.of(context).pop();
                          _showEditHabitDialog(habit);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final updatedHabit = habit.copyWith(
                  name: nameController.text.trim(),
                  emoji: selectedEmoji,
                );
                context.read<HabitBloc>().add(UpdateHabit(updatedHabit));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteHabitDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<HabitBloc>().add(DeleteHabit(habit.id));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
