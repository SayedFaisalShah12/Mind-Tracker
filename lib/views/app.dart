import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class App extends StatefulWidget {
  final bool isFirstLaunch;

  const App({super.key, required this.isFirstLaunch});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    if (widget.isFirstLaunch) {
      _markFirstLaunchComplete();
    }
  }

  Future<void> _markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
    print("This is Working");
    print("This is Working");
    print("This is Working");
    print("This is Working");
    print("This is Working");
    print("This is Working");
    print("This is Working");
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFirstLaunch) {
      return const OnboardingScreen();
    } else {
      return const HomeScreen();
    }
  }
}
