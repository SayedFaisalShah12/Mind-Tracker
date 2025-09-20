import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:mind_tracker/main.dart';
import 'package:mind_tracker/services/mood_service.dart';
import 'package:mind_tracker/services/habit_service.dart';
import 'package:mind_tracker/bloc/mood/mood_bloc.dart';
import 'package:mind_tracker/bloc/habit/habit_bloc.dart';
import 'package:mind_tracker/views/app.dart';

void main() {
  group('Mind Tracker App Tests', () {
    testWidgets('App loads without crashing', (WidgetTester tester) async {
      // Initialize Hive for testing
      await Hive.initFlutter();

      // Create services
      final moodService = MoodService();
      final habitService = HabitService();

      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<MoodBloc>(
              create: (context) => MoodBloc(moodService: moodService),
            ),
            BlocProvider<HabitBloc>(
              create: (context) => HabitBloc(habitService: habitService),
            ),
          ],
          child: MaterialApp(home: const App(isFirstLaunch: false)),
        ),
      );

      // Verify that the app loads
      expect(find.text('Mind Tracker'), findsOneWidget);
    });
  });
}
