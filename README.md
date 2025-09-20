# Mind Tracker

A cross-platform Flutter app for tracking mood and habits, similar to Daylio Journal. Built with Flutter 3.x and designed to work on Android, iOS, and Web.

## Features

### 🧠 Mood Tracking
- Daily mood check-in with emojis and 1-5 scale
- Add notes and tags to mood entries
- View mood trends over time
- Track mood patterns and correlations

### ✅ Habit Tracking
- Create and manage custom habits
- Track daily habit completion
- Pre-defined habits: Exercise, Meditation, Reading, Water, Sleep
- Visual progress indicators

### 📊 Statistics & Insights
- Weekly/monthly mood charts using fl_chart
- Habit completion rates and trends
- Mood and habit correlation analysis
- Visual progress tracking

### 🔔 Reminders
- Daily mood logging notifications
- Customizable reminder times
- Local notification support

### 🔒 Privacy & Security
- All data stored locally using Hive
- Optional biometric authentication
- No data sent to external servers
- Full control over your data

### 🎨 Customization
- Light/Dark theme support
- Customizable primary colors
- Custom mood emojis
- Material Design 3

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: BLoC (flutter_bloc)
- **Local Storage**: Hive
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications
- **Authentication**: local_auth (biometric)
- **Cloud Sync**: Firebase (optional)
- **Device Preview**: device_preview (development)

## Project Structure

```
lib/
├── models/           # Data models with Hive adapters
├── views/            # UI screens and pages
├── bloc/             # BLoC state management
│   ├── mood/         # Mood tracking logic
│   └── habit/        # Habit tracking logic
├── services/         # Business logic and data services
├── utils/            # Helper utilities
└── widgets/          # Reusable UI components
```

## Getting Started

### Prerequisites
- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code
- Chrome (for web development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd mind_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
dart run build_runner build
```

4. Run the app:
```bash
# For web (with device preview)
flutter run -d chrome --web-port=8080

# For Android
flutter run

# For iOS
flutter run
```

## 📱 Device Preview

The app includes **Device Preview** for easy testing across different devices:

- **iPhone 13** (default)
- **iPhone 13 Pro Max**
- **Samsung Galaxy S21**
- **Samsung Galaxy Note 20**
- **iPad Pro**
- **iPad Air**
- **macOS Desktop**
- **Windows Desktop**

### Using Device Preview

1. **Run with device preview enabled** (debug mode only):
   ```bash
   flutter run -d chrome --web-port=8080
   ```

2. **Switch between devices** using the device selector in the preview panel

3. **Test different orientations** and screen sizes

4. **Disable for production** by setting `DevicePreviewConfig.isEnabled = false`

## Usage

### First Launch
- Complete the onboarding flow
- Dummy data is automatically added for demonstration
- Start tracking your mood and habits

### Mood Tracking
1. Navigate to the Mood tab
2. Select your mood (1-5 scale with emojis)
3. Add optional notes and tags
4. Save your mood entry

### Habit Management
1. Go to the Habits tab
2. Add new habits or use pre-defined ones
3. Check off completed habits daily
4. View your progress and statistics

### Statistics
- View mood trends over different time periods
- Analyze habit completion rates
- Identify patterns and correlations

## Data Storage

- **Local**: All data is stored locally using Hive
- **Export**: Data can be exported (feature coming soon)
- **Privacy**: No data is sent to external servers
- **Backup**: Manual backup through export functionality

## Future Features

- [ ] Cloud sync with Firebase
- [ ] Data export/import
- [ ] Advanced analytics and insights
- [ ] Habit streaks and achievements
- [ ] Mood journal with rich text
- [ ] Custom themes and colors
- [ ] Widget support for quick mood logging
- [ ] Apple Watch / Wear OS support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by Daylio Journal
- Built with Flutter and the amazing Flutter community
- Uses various open-source packages (see pubspec.yaml)

## Support

If you encounter any issues or have feature requests, please open an issue on GitHub.

---

**Note**: This is a demonstration project showcasing Flutter development with modern architecture patterns, state management, and cross-platform capabilities.