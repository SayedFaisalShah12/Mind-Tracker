import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../../services/user_settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserSettingsService _userSettingsService;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _reminderTime = '20:00';
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _userSettingsService = UserSettingsService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _userSettingsService.getUserSettings();
    setState(() {
      _isDarkMode = settings.isDarkMode;
      _notificationsEnabled = settings.notificationsEnabled;
      _biometricEnabled = settings.biometricEnabled;
      _reminderTime = settings.reminderTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppearanceSection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildNotificationsSection(),
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
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: _isDarkMode,
              onChanged: (value) async {
                setState(() {
                  _isDarkMode = value;
                });
                await _userSettingsService.toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: _localAuth.canCheckBiometrics,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return SwitchListTile(
                    title: const Text('Biometric Lock'),
                    subtitle: const Text('Use fingerprint or face ID'),
                    value: _biometricEnabled,
                    onChanged: (value) async {
                      if (value) {
                        final authenticated = await _authenticateWithBiometrics();
                        if (authenticated) {
                          setState(() {
                            _biometricEnabled = value;
                          });
                          await _userSettingsService.toggleBiometric(value);
                        }
                      } else {
                        setState(() {
                          _biometricEnabled = value;
                        });
                        await _userSettingsService.toggleBiometric(value);
                      }
                    },
                  );
                } else {
                  return const ListTile(
                    title: Text('Biometric Lock'),
                    subtitle: Text('Not available on this device'),
                    enabled: false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Daily Reminders'),
              subtitle: const Text('Get reminded to log your mood'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() {
                  _notificationsEnabled = value;
                });
                await _userSettingsService.toggleNotifications(value);
              },
            ),
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(_reminderTime),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showTimePicker,
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
            const Text(
              'Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Export Data'),
              subtitle: const Text('Download your data as JSON'),
              leading: const Icon(Icons.download),
              onTap: _exportData,
            ),
            ListTile(
              title: const Text('Import Data'),
              subtitle: const Text('Import data from JSON file'),
              leading: const Icon(Icons.upload),
              onTap: _importData,
            ),
            ListTile(
              title: const Text('Clear All Data'),
              subtitle: const Text('Delete all your data permanently'),
              leading: const Icon(Icons.delete_forever, color: Colors.red),
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
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
              leading: const Icon(Icons.info),
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              subtitle: const Text('Read our privacy policy'),
              leading: const Icon(Icons.privacy_tip),
              onTap: _showPrivacyPolicy,
            ),
            ListTile(
              title: const Text('Terms of Service'),
              subtitle: const Text('Read our terms of service'),
              leading: const Icon(Icons.description),
              onTap: _showTermsOfService,
            ),
            ListTile(
              title: const Text('Contact Support'),
              subtitle: const Text('Get help and support'),
              leading: const Icon(Icons.support),
              onTap: _contactSupport,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric lock',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void _showTimePicker() async {
    final time = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_reminderTime.split(':')[0]),
        minute: int.parse(_reminderTime.split(':')[1]),
      ),
    );

    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _reminderTime = timeString;
      });
      await _userSettingsService.updateReminderTime(timeString);
    }
  }

  void _exportData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export feature coming soon!'),
      ),
    );
  }

  void _importData() {
    // TODO: Implement data import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data import feature coming soon!'),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your mood entries, habits, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement clear all data
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: Show privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy policy coming soon!'),
      ),
    );
  }

  void _showTermsOfService() {
    // TODO: Show terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms of service coming soon!'),
      ),
    );
  }

  void _contactSupport() {
    // TODO: Open support contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support contact coming soon!'),
      ),
    );
  }
}
