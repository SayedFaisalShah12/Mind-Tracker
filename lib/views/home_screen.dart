import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/mood/mood_bloc.dart';
import '../bloc/mood/mood_event.dart';
import '../bloc/mood/mood_state.dart';
import '../bloc/habit/habit_bloc.dart';
import '../bloc/habit/habit_event.dart';
import '../bloc/habit/habit_state.dart';
import '../services/notification_service.dart';
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await NotificationService.showInstantMoodReminder();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Mood reminder sent!'),
              backgroundColor: scheme.inverseSurface,
            ),
          );
        },
        label: const Text('Remind Me'),
        icon: const Icon(Icons.notifications_active),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood),
            label: 'Mood',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outlined),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mind Tracker')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [scheme.primaryContainer, scheme.secondaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _buildWelcomeCardContent(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: 8),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildTodayOverview(context),
                const SizedBox(height: 24),
                _buildRecentMoods(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCardContent(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final textTheme = Theme.of(context).textTheme;
    final onContainer = Theme.of(context).colorScheme.onPrimaryContainer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: onContainer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How are you feeling today?',
          style: textTheme.bodyLarge?.copyWith(
            color: onContainer.withOpacity(0.9),
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
                    style: textTheme.bodyLarge?.copyWith(color: onContainer),
                  ),
                ],
              );
            } else {
              return FilledButton.icon(
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
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Log Mood',
                Icons.mood,
                Theme.of(context).colorScheme.primary,
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
                Theme.of(context).colorScheme.secondary,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HabitsScreen()),
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
                Theme.of(context).colorScheme.tertiary,
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
                Theme.of(context).colorScheme.primary,
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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.12), scheme.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            if (state is HabitLoaded) {
              final completedHabits =
                  state.todayHabitEntries.values
                      .where((entry) => entry.completed == true)
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
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
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
                              value:
                                  totalHabits > 0
                                      ? completedHabits / totalHabits
                                      : 0,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
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
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading habits...'),
                  ],
                ),
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                    child: Text(
                      'No mood entries yet. Start tracking your mood!',
                    ),
                  ),
                );
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children:
                        recentMoods.map<Widget>((mood) {
                          return ListTile(
                            leading: Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text('${mood.moodValue}/5'),
                            subtitle: Text(
                              '${mood.date.day}/${mood.date.month}/${mood.date.year}',
                            ),
                            trailing:
                                mood.notes != null
                                    ? const Icon(Icons.note, size: 16)
                                    : null,
                          );
                        }).toList(),
                  ),
                ),
              );
            }
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading recent moods...'),
                  ],
                ),
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
