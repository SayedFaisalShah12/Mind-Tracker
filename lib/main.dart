import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/mood_entry.dart';
import 'models/habit.dart';
import 'models/habit_entry.dart';
import 'models/user_settings.dart';
import 'services/mood_service.dart';
import 'services/habit_service.dart';
import 'services/dummy_data_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'bloc/mood/mood_bloc.dart';
import 'bloc/habit/habit_bloc.dart';
import 'views/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitEntryAdapter());
  Hive.registerAdapter(UserSettingsAdapter());

  // Initialize services
  final moodService = MoodService();
  final habitService = HabitService();
  
  // Initialize services
  await NotificationService.initialize();
  await ThemeService.initialize();

  // Check if this is first launch
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

  // Add dummy data if first launch
  if (isFirstLaunch) {
    await DummyDataService.addDummyData();
  }

  runApp(
    MindTrackerApp(
      moodService: moodService,
      habitService: habitService,
      isFirstLaunch: isFirstLaunch,
    ),
  );
}

class MindTrackerApp extends StatelessWidget {
  final MoodService moodService;
  final HabitService habitService;
  final bool isFirstLaunch;

  const MindTrackerApp({
    super.key,
    required this.moodService,
    required this.habitService,
    required this.isFirstLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MoodBloc>(
          create: (context) => MoodBloc(moodService: moodService),
        ),
        BlocProvider<HabitBloc>(
          create: (context) => HabitBloc(habitService: habitService),
        ),
      ],
      child: MaterialApp(
        title: 'Mind Tracker',
        theme: ThemeService.getLightTheme(),
        darkTheme: ThemeService.getDarkTheme(),
        themeMode: ThemeService.themeMode,
        home: App(isFirstLaunch: isFirstLaunch),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
