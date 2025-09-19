import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_settings.dart';
import '../services/user_settings_service.dart';
import 'onboarding/onboarding_screen.dart';
import 'home/home_screen.dart';
import 'theme/app_theme.dart';

class MindTrackerApp extends StatefulWidget {
  const MindTrackerApp({super.key});

  @override
  State<MindTrackerApp> createState() => _MindTrackerAppState();
}

class _MindTrackerAppState extends State<MindTrackerApp> {
  late UserSettingsService _userSettingsService;
  UserSettings? _userSettings;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _userSettingsService = UserSettingsService();
    await _userSettingsService.init();
    
    final settings = await _userSettingsService.getUserSettings();
    if (mounted) {
      setState(() {
        _userSettings = settings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userSettings == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Mind Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _userSettings!.isDarkMode 
          ? ThemeMode.dark 
          : ThemeMode.light,
      home: _userSettings!.hasCompletedOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
