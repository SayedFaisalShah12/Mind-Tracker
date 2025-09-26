import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static bool _isSupportedPlatform() {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isAvailable() async {
    if (!_isSupportedPlatform()) return false;
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    if (!_isSupportedPlatform()) return <BiometricType>[];
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return <BiometricType>[];
    }
  }

  static Future<bool> authenticate({
    required String reason,
    String? cancelButton,
  }) async {
    if (!_isSupportedPlatform()) return false;
    try {
      final bool isAvailable = await BiometricService.isAvailable();
      if (!isAvailable) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics({
    required String reason,
  }) async {
    if (!_isSupportedPlatform()) return false;
    try {
      final bool isAvailable = await BiometricService.isAvailable();
      if (!isAvailable) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
  }

  static Future<bool> shouldShowBiometricPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPromptTime = prefs.getInt('last_biometric_prompt') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const promptInterval = 5 * 60 * 1000; // 5 minutes

    return (now - lastPromptTime) > promptInterval;
  }

  static Future<void> updateLastPromptTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'last_biometric_prompt',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<String> getBiometricTypeString() async {
    if (!_isSupportedPlatform()) return 'Biometric';
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }
}
