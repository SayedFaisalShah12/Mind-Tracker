import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/mood/mood_bloc.dart';
import '../bloc/mood/mood_event.dart';
import '../bloc/mood/mood_state.dart';
import '../bloc/habit/habit_bloc.dart';
import '../bloc/habit/habit_event.dart';
import '../bloc/habit/habit_state.dart';
import 'mood_tracking_screen.dart';
import 'habits_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const MoodTrackingScreen(),
    const HabitsScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<MoodBloc>().add(LoadMoodEntries());
    context.read<HabitBloc>().add(LoadHabits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildTodayOverview(context),
            const SizedBox(height: 24),
            _buildRecentMoods(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<MoodBloc, MoodState>(
              builder: (context, state) {
                if (state is MoodLoaded && state.todayMoodEntry != null) {
                  return Row(
                    children: [
                      Text(
                        state.todayMoodEntry!.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mood: ${state.todayMoodEntry!.moodValue}/5',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  );
                } else {
                  return ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MoodTrackingScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Log Today\'s Mood'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Log Mood',
                Icons.mood,
                Colors.blue,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MoodTrackingScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Check Habits',
                Icons.check_circle,
                Colors.green,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HabitsScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'View Stats',
                Icons.analytics,
                Colors.purple,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Settings',
                Icons.settings,
                Colors.orange,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            if (state is HabitLoaded) {
              final completedHabits = state.todayHabitEntries.values
                  .where((entry) => entry.completed)
                  .length;
              final totalHabits = state.habits.length;
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$completedHabits/$totalHabits',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Habits Completed',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              value: totalHabits > 0 ? completedHabits / totalHabits : 0,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${totalHabits > 0 ? ((completedHabits / totalHabits) * 100).round() : 0}%',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Loading habits...'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentMoods(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Moods',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<MoodBloc, MoodState>(
          builder: (context, state) {
            if (state is MoodLoaded) {
              final recentMoods = state.moodEntries.take(5).toList();
              
              if (recentMoods.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No mood entries yet. Start tracking your mood!'),
                  ),
                );
              }
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: recentMoods.map((mood) {
                      return ListTile(
                        leading: Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text('${mood.moodValue}/5'),
                        subtitle: Text(
                          '${mood.date.day}/${mood.date.month}/${mood.date.year}',
                        ),
                        trailing: mood.notes != null
                            ? const Icon(Icons.note, size: 16)
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              );
            }
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Loading recent moods...'),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }
}
