import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import '../models/user_settings.dart';

class FirebaseService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static bool _initialized = false;
  static User? _currentUser;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _initialized = true;

      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) {
        _currentUser = user;
      });
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }

  static bool get isInitialized => _initialized;
  static bool get isSignedIn => _currentUser != null;
  static User? get currentUser => _currentUser;

  // Authentication methods
  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _saveUserPreference('email', email);
        return AuthResult.success;
      } else {
        return AuthResult.failure;
      }
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      return AuthResult.failure;
    }
  }

  static Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _saveUserPreference('email', email);
        return AuthResult.success;
      } else {
        return AuthResult.failure;
      }
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.message}');
      return AuthResult.failure;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearUserPreferences();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
    }
  }

  // Data sync methods
  static Future<SyncResult> syncMoodEntries(
    List<MoodEntry> localEntries,
  ) async {
    if (!isSignedIn) return SyncResult.notSignedIn;

    try {
      final userId = _currentUser!.uid;
      final batch = _firestore.batch();

      for (final entry in localEntries) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('mood_entries')
            .doc(entry.id);

        batch.set(docRef, entry.toJson());
      }

      await batch.commit();
      return SyncResult.success;
    } catch (e) {
      print('Mood entries sync error: $e');
      return SyncResult.failure;
    }
  }

  static Future<SyncResult> syncHabits(List<Habit> localHabits) async {
    if (!isSignedIn) return SyncResult.notSignedIn;

    try {
      final userId = _currentUser!.uid;
      final batch = _firestore.batch();

      for (final habit in localHabits) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habit.id);

        batch.set(docRef, habit.toJson());
      }

      await batch.commit();
      return SyncResult.success;
    } catch (e) {
      print('Habits sync error: $e');
      return SyncResult.failure;
    }
  }

  static Future<SyncResult> syncHabitEntries(
    List<HabitEntry> localEntries,
  ) async {
    if (!isSignedIn) return SyncResult.notSignedIn;

    try {
      final userId = _currentUser!.uid;
      final batch = _firestore.batch();

      for (final entry in localEntries) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('habit_entries')
            .doc(entry.id);

        batch.set(docRef, entry.toJson());
      }

      await batch.commit();
      return SyncResult.success;
    } catch (e) {
      print('Habit entries sync error: $e');
      return SyncResult.failure;
    }
  }

  static Future<SyncResult> syncUserSettings(UserSettings settings) async {
    if (!isSignedIn) return SyncResult.notSignedIn;

    try {
      final userId = _currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('user_settings')
          .set(settings.toJson());

      return SyncResult.success;
    } catch (e) {
      print('User settings sync error: $e');
      return SyncResult.failure;
    }
  }

  // Download methods
  static Future<List<MoodEntry>> downloadMoodEntries() async {
    if (!isSignedIn) return [];

    try {
      final userId = _currentUser!.uid;
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('mood_entries')
              .get();

      return snapshot.docs
          .map((doc) => MoodEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Download mood entries error: $e');
      return [];
    }
  }

  static Future<List<Habit>> downloadHabits() async {
    if (!isSignedIn) return [];

    try {
      final userId = _currentUser!.uid;
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('habits')
              .get();

      return snapshot.docs.map((doc) => Habit.fromJson(doc.data())).toList();
    } catch (e) {
      print('Download habits error: $e');
      return [];
    }
  }

  static Future<List<HabitEntry>> downloadHabitEntries() async {
    if (!isSignedIn) return [];

    try {
      final userId = _currentUser!.uid;
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('habit_entries')
              .get();

      return snapshot.docs
          .map((doc) => HabitEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Download habit entries error: $e');
      return [];
    }
  }

  static Future<UserSettings?> downloadUserSettings() async {
    if (!isSignedIn) return null;

    try {
      final userId = _currentUser!.uid;
      final doc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('settings')
              .doc('user_settings')
              .get();

      if (doc.exists) {
        return UserSettings.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Download user settings error: $e');
      return null;
    }
  }

  // Helper methods
  static Future<void> _saveUserPreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase_$key', value);
  }

  static Future<void> _clearUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('firebase_email');
  }

  static Future<bool> getCloudSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('cloud_sync_enabled') ?? false;
  }

  static Future<void> setCloudSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cloud_sync_enabled', enabled);
  }

  static Future<void> deleteAllUserData() async {
    if (!isSignedIn) return;

    try {
      final userId = _currentUser!.uid;
      final batch = _firestore.batch();

      // Delete all user collections
      final collections = [
        'mood_entries',
        'habits',
        'habit_entries',
        'settings',
      ];

      for (final collection in collections) {
        final snapshot =
            await _firestore
                .collection('users')
                .doc(userId)
                .collection(collection)
                .get();

        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
    } catch (e) {
      print('Delete user data error: $e');
    }
  }
}

enum AuthResult { success, failure }

enum SyncResult { success, failure, notSignedIn }
