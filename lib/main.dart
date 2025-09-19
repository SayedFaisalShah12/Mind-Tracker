import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/mood_entry.dart';
import 'models/habit.dart';
import 'models/user_settings.dart';
import 'services/mood_service.dart';
import 'services/habit_service.dart';
import 'controllers/mood/mood_bloc.dart';
import 'controllers/habit/habit_bloc.dart';
import 'views/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitEntryAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  
  // Initialize Firebase (optional)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase not configured, continue without it
    debugPrint('Firebase not initialized: $e');
  }
  
  // Initialize services
  final moodService = MoodService();
  final habitService = HabitService();
  
  await moodService.init();
  await habitService.init();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<MoodBloc>(
          create: (context) => MoodBloc(moodService: moodService),
        ),
        BlocProvider<HabitBloc>(
          create: (context) => HabitBloc(habitService: habitService),
        ),
      ],
      child: const MindTrackerApp(),
    ),
  );
}