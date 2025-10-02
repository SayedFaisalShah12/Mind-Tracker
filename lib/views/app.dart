import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'biometric_lock_screen.dart';
import '../services/biometric_service.dart';

class App extends StatefulWidget {
  final bool isFirstLaunch;

  const App({super.key, required this.isFirstLaunch});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  bool _isLockScreenActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isFirstLaunch) {
      _markFirstLaunchComplete();
    }
  }

  Future<void> _markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
  }

  Future<bool> _shouldUseBiometricLock() async {
    final enabled = await BiometricService.isEnabled();
    if (!enabled) return false;
    final available = await BiometricService.isAvailable();
    if (!available) return false;
    // Optionally throttle prompts
    final shouldPrompt = await BiometricService.shouldShowBiometricPrompt();
    if (shouldPrompt) {
      return true;
    }
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _maybePromptBiometricOnResume();
      print('resumed');
      print('resumed');
      print('resumed');
      print('resumed');
      print('resumed');
      print('resumed');
    }
  }

  Future<void> _maybePromptBiometricOnResume() async {
    if (_isLockScreenActive) return;
    final shouldLock = await _shouldUseBiometricLock();
    if (!mounted || !shouldLock) return;
    _isLockScreenActive = true;
    // Push lock screen; on unlock, pop back to current screen
    // If the app was on Home, this ensures re-auth without rebuilding the tree
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (_) => BiometricLockScreen(
              child: const SizedBox.shrink(),
              onUnlock: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
      ),
    );
    _isLockScreenActive = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFirstLaunch) {
      return const OnboardingScreen();
    } else {
      return FutureBuilder<bool>(
        future: _shouldUseBiometricLock(),
        builder: (context, snapshot) {
          final useLock = snapshot.data == true;
          if (useLock) {
            return BiometricLockScreen(
              child: const HomeScreen(),
              onUnlock: () {
                // Once unlocked, replace with HomeScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            );
          }
          return const HomeScreen();
        },
      );
    }
  }
}
