import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/mood/mood_bloc.dart';
import '../bloc/mood/mood_event.dart';
import '../bloc/habit/habit_bloc.dart';
import '../bloc/habit/habit_event.dart';
import '../services/notification_service.dart';
import '../services/biometric_service.dart';
import '../services/theme_service.dart';
import '../services/firebase_service.dart';
import '../services/mood_service.dart';
import '../services/habit_service.dart';
import 'firebase_auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _themeMode = 'system';
  String _reminderTime = '20:00';
  String _primaryColor = 'blue';
  bool _isLoading = false;
  bool _isSignedIn = false;

  final List<String> _themeModes = ['light', 'dark', 'system'];
  final List<String> _reminderTimes = [
    '08:00',
    '12:00',
    '18:00',
    '20:00',
    '22:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reminderSettings = await NotificationService.getReminderSettings();
      final biometricEnabled = await BiometricService.isEnabled();
      final isSignedIn = FirebaseService.isSignedIn;

      setState(() {
        _notificationsEnabled = reminderSettings['enabled'];
        _reminderTime = reminderSettings['time'];
        _biometricEnabled = biometricEnabled;
        _themeMode = ThemeService.getCurrentThemeModeName();
        _primaryColor = ThemeService.getCurrentColorName();
        _isSignedIn = isSignedIn;
      });
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppearanceSection(),
          const SizedBox(height: 24),
          _buildNotificationsSection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildThemeModeSelector(),
            const SizedBox(height: 16),
            _buildColorSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _themeMode,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items:
              _themeModes.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.capitalize()),
                );
              }).toList(),
          onChanged:
              _isLoading
                  ? null
                  : (value) async {
                    setState(() {
                      _themeMode = value!;
                    });

                    // Update theme mode
                    final themeMode =
                        value == 'light'
                            ? ThemeMode.light
                            : value == 'dark'
                            ? ThemeMode.dark
                            : ThemeMode.system;
                    await ThemeService.setThemeMode(themeMode);

                    // Restart app to apply theme changes
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Theme updated! Restart the app to see changes.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Color',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              ThemeService.availableColors.entries.map((entry) {
                final colorName = entry.key;
                final color = entry.value;
                final isSelected = _primaryColor == colorName;

                return GestureDetector(
                  onTap:
                      _isLoading
                          ? null
                          : () async {
                            setState(() {
                              _primaryColor = colorName;
                            });

                            // Update primary color
                            await ThemeService.setPrimaryColor(colorName);

                            // Restart app to apply color changes
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Color updated! Restart the app to see changes.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                              : null,
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Get reminders to log your mood'),
              value: _notificationsEnabled,
              onChanged:
                  _isLoading
                      ? null
                      : (value) async {
                        setState(() {
                          _notificationsEnabled = value;
                        });

                        // Request permissions if enabling
                        if (value) {
                          final hasPermission =
                              await NotificationService.requestPermissions();
                          if (!hasPermission) {
                            setState(() {
                              _notificationsEnabled = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification permission denied'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }

                        // Update notification settings
                        await NotificationService.updateReminderSettings(
                          enabled: _notificationsEnabled,
                          time: _reminderTime,
                        );
                      },
            ),
            if (_notificationsEnabled) ...[
              const SizedBox(height: 8),
              _buildReminderTimeSelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Time',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _reminderTime,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items:
              _reminderTimes.map((time) {
                return DropdownMenuItem(value: time, child: Text(time));
              }).toList(),
          onChanged:
              _isLoading
                  ? null
                  : (value) async {
                    setState(() {
                      _reminderTime = value!;
                    });

                    // Update notification settings
                    await NotificationService.updateReminderSettings(
                      enabled: _notificationsEnabled,
                      time: _reminderTime,
                    );
                  },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Biometric Lock'),
              subtitle: const Text(
                'Use fingerprint or face ID to secure the app',
              ),
              value: _biometricEnabled,
              onChanged:
                  _isLoading
                      ? null
                      : (value) async {
                        if (value) {
                          // Check if biometric is available
                          final isAvailable =
                              await BiometricService.isAvailable();
                          if (!isAvailable) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Biometric authentication is not available on this device',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Test authentication
                          final biometricType =
                              await BiometricService.getBiometricTypeString();
                          final success = await BiometricService.authenticate(
                            reason: 'Enable biometric lock for Mind Tracker',
                          );

                          if (success) {
                            setState(() {
                              _biometricEnabled = true;
                            });
                            await BiometricService.setEnabled(true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Biometric lock enabled with $biometricType',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Authentication failed. Biometric lock not enabled.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          setState(() {
                            _biometricEnabled = false;
                          });
                          await BiometricService.setEnabled(false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Biometric lock disabled'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Data'),
              subtitle: const Text('Export your mood and habit data'),
              onTap: _exportData,
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Import Data'),
              subtitle: const Text('Import data from another device'),
              onTap: _importData,
            ),
            ListTile(
              leading: Icon(
                _isSignedIn ? Icons.cloud_done : Icons.cloud_sync,
                color: _isSignedIn ? Colors.green : Colors.blue,
              ),
              title: Text(_isSignedIn ? 'Cloud Sync (Enabled)' : 'Cloud Sync'),
              subtitle: Text(
                _isSignedIn
                    ? 'Signed in as ${FirebaseService.currentUser?.email}'
                    : 'Sync data across devices with Firebase',
              ),
              onTap:
                  _isLoading
                      ? null
                      : () async {
                        if (_isSignedIn) {
                          // Show sync options
                          _showSyncOptions();
                        } else {
                          // Navigate to auth screen
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const FirebaseAuthScreen(),
                            ),
                          );

                          // Reload settings after returning from auth screen
                          _loadSettings();
                        }
                      },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data'),
              subtitle: const Text('Permanently delete all your data'),
              onTap: _showClearDataDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: _showPrivacyPolicy,
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              onTap: _showTermsOfService,
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              onTap: _sendFeedback,
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import feature coming soon!')),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'This will permanently delete all your mood entries, habits, and settings. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearAllData();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete All Data'),
              ),
            ],
          ),
    );
  }

  void _clearAllData() {
    // Clear mood data
    context.read<MoodBloc>().add(LoadMoodEntries());
    // Clear habit data
    context.read<HabitBloc>().add(LoadHabits());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All data has been cleared'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const SingleChildScrollView(
              child: Text(
                'Mind Tracker respects your privacy. All data is stored locally on your device and is not shared with third parties. You have full control over your data and can export or delete it at any time.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terms of Service'),
            content: const SingleChildScrollView(
              child: Text(
                'By using Mind Tracker, you agree to use the app responsibly and not for any illegal purposes. The app is provided "as is" without warranties.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback feature coming soon!')),
    );
  }

  void _showSyncOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cloud Sync Options',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Upload to Cloud'),
                  subtitle: const Text('Sync local data to Firebase'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _uploadToCloud();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Download from Cloud'),
                  subtitle: const Text('Sync cloud data to local storage'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _downloadFromCloud();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sign Out'),
                  subtitle: const Text('Disconnect from Firebase'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _signOut();
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _uploadToCloud() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get local data
      final moodService = MoodService();
      final habitService = HabitService();

      final moodEntries = await moodService.getMoodEntries();
      final habits = await habitService.getHabits();
      final habitEntries = await habitService.getHabitEntries();

      // Upload to Firebase
      final moodResult = await FirebaseService.syncMoodEntries(moodEntries);
      final habitResult = await FirebaseService.syncHabits(habits);
      final habitEntryResult = await FirebaseService.syncHabitEntries(
        habitEntries,
      );

      if (moodResult == SyncResult.success &&
          habitResult == SyncResult.success &&
          habitEntryResult == SyncResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data uploaded to cloud successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Some data failed to upload. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFromCloud() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Download from Firebase
      final moodEntries = await FirebaseService.downloadMoodEntries();
      final habits = await FirebaseService.downloadHabits();
      final habitEntries = await FirebaseService.downloadHabitEntries();

      // Save to local storage
      final moodService = MoodService();
      final habitService = HabitService();

      for (final entry in moodEntries) {
        await moodService.addMoodEntry(entry);
      }

      for (final habit in habits) {
        await habitService.addHabit(habit);
      }

      for (final entry in habitEntries) {
        await habitService.toggleHabitEntry(
          entry.habitId,
          entry.date,
          entry.completed,
          entry.notes,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data downloaded from cloud successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload data in the app
      context.read<MoodBloc>().add(LoadMoodEntries());
      context.read<HabitBloc>().add(LoadHabits());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseService.signOut();
      await FirebaseService.setCloudSyncEnabled(false);

      setState(() {
        _isSignedIn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign out failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
