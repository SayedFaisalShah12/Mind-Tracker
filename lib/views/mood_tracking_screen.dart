import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/mood/mood_bloc.dart';
import '../bloc/mood/mood_event.dart';
import '../bloc/mood/mood_state.dart';
import '../models/mood_entry.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  final TextEditingController _notesController = TextEditingController();
  final List<String> _selectedTags = [];
  
  int _selectedMood = 3; // Default to neutral mood
  final List<String> _moodEmojis = ['😢', '😔', '😐', '😊', '😄'];
  final List<String> _availableTags = [
    'Work', 'Family', 'Friends', 'Health', 'Exercise',
    'Sleep', 'Food', 'Weather', 'Travel', 'Learning'
  ];

  @override
  void initState() {
    super.initState();
    // Load today's mood entry if it exists
    context.read<MoodBloc>().add(GetMoodEntryByDate(DateTime.now()));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocListener<MoodBloc, MoodState>(
        listener: (context, state) {
          if (state is MoodEntryAdded || state is MoodEntryUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mood saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is MoodError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(),
              const SizedBox(height: 24),
              _buildMoodSelector(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              'Today - $dateStr',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final moodValue = index + 1;
            final isSelected = _selectedMood == moodValue;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = moodValue;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _moodEmojis[index],
                    style: TextStyle(
                      fontSize: isSelected ? 32 : 28,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _getMoodDescription(_selectedMood),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'How was your day? What made you feel this way?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (Optional)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
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
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveMood,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Mood',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _saveMood() {
    final now = DateTime.now();
    final moodEntry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: now,
      moodValue: _selectedMood,
      emoji: _moodEmojis[_selectedMood - 1],
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      tags: List.from(_selectedTags),
      createdAt: now,
      updatedAt: now,
    );

    // Check if today's mood already exists
    final state = context.read<MoodBloc>().state;
    if (state is MoodLoaded && state.todayMoodEntry != null) {
      // Update existing entry
      final updatedEntry = moodEntry.copyWith(
        id: state.todayMoodEntry!.id,
        createdAt: state.todayMoodEntry!.createdAt,
      );
      context.read<MoodBloc>().add(UpdateMoodEntry(updatedEntry));
    } else {
      // Add new entry
      context.read<MoodBloc>().add(AddMoodEntry(moodEntry));
    }
  }

  String _getMoodDescription(int moodValue) {
    switch (moodValue) {
      case 1:
        return 'Very Sad';
      case 2:
        return 'Sad';
      case 3:
        return 'Neutral';
      case 4:
        return 'Happy';
      case 5:
        return 'Very Happy';
      default:
        return 'Neutral';
    }
  }
}
