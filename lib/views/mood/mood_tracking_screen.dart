import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/mood/mood_bloc.dart';
import '../../models/mood_entry.dart';
import '../../utils/uuid_generator.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  final TextEditingController _notesController = TextEditingController();
  final List<String> _selectedTags = [];
  int _selectedMood = 3; // Default to neutral
  final List<String> _availableTags = [
    'Work',
    'Family',
    'Friends',
    'Health',
    'Exercise',
    'Sleep',
    'Food',
    'Weather',
    'Travel',
    'Hobby',
  ];

  final List<Map<String, dynamic>> _moodOptions = [
    {'value': 1, 'emoji': '😢', 'label': 'Very Bad', 'color': Colors.red},
    {'value': 2, 'emoji': '😕', 'label': 'Bad', 'color': Colors.orange},
    {'value': 3, 'emoji': '😐', 'label': 'Okay', 'color': Colors.yellow},
    {'value': 4, 'emoji': '😊', 'label': 'Good', 'color': Colors.lightGreen},
    {'value': 5, 'emoji': '😄', 'label': 'Excellent', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    context.read<MoodBloc>().add(const LoadMoodEntries());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveMood() {
    final selectedMoodOption = _moodOptions.firstWhere(
      (option) => option['value'] == _selectedMood,
    );

    final moodEntry = MoodEntry(
      id: UuidGenerator.generate(),
      date: DateTime.now(),
      moodValue: _selectedMood,
      emoji: selectedMoodOption['emoji'],
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      tags: _selectedTags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<MoodBloc>().add(AddMoodEntry(moodEntry));

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mood logged successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Reset form
    _notesController.clear();
    setState(() {
      _selectedTags.clear();
      _selectedMood = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navigate to mood history
            },
          ),
        ],
      ),
      body: BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMoodSelector(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 24),
                _buildTagsSection(),
                const SizedBox(height: 24),
                _buildTodayMoodPreview(state),
                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _moodOptions.map((option) {
                final isSelected = option['value'] == _selectedMood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = option['value'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (option['color'] as Color).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? option['color'] as Color
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          option['emoji'],
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? option['color'] : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tags (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMoodPreview(MoodState state) {
    if (state is MoodLoaded && state.todayMood != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Mood',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    state.todayMood!.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _moodOptions.firstWhere(
                            (option) => option['value'] == state.todayMood!.moodValue,
                          )['label'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (state.todayMood!.notes != null)
                          Text(
                            state.todayMood!.notes!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        if (state.todayMood!.tags.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: state.todayMood!.tags.map((tag) {
                              return Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.blue.withOpacity(0.1),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveMood,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Save Mood',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
