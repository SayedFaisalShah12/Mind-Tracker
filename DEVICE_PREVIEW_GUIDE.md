# Device Preview Guide

## Overview

Device Preview is a powerful development tool that allows you to preview your Flutter app on different device sizes and orientations without needing physical devices or emulators.

## Features

- **Multiple Device Support**: Preview on iPhone, Android, tablets, and desktop
- **Orientation Testing**: Test both portrait and landscape modes
- **Real-time Updates**: See changes instantly across all device previews
- **Debug Mode Only**: Automatically disabled in production builds

## Available Devices

The Mind Tracker app is configured with the following devices:

### iOS Devices
- **iPhone 13** (default)
- **iPhone 13 Pro Max**

### Android Devices
- **Samsung Galaxy Note 20**
- **Samsung Galaxy S20**

## How to Use

### 1. Running with Device Preview

```bash
# Run on web with device preview enabled
flutter run -d chrome --web-port=8080
```

### 2. Using the Preview Panel

When you run the app with device preview:

1. **Device Selector**: Use the dropdown to switch between different devices
2. **Orientation Toggle**: Switch between portrait and landscape modes
3. **Zoom Controls**: Adjust the preview size
4. **Settings**: Access additional preview options

### 3. Development Workflow

1. **Start Development**: Run the app with device preview
2. **Make Changes**: Edit your code and save
3. **Hot Reload**: See changes instantly across all device previews
4. **Test Responsiveness**: Ensure your UI works on all screen sizes

## Configuration

### Enabling/Disabling Device Preview

Device preview is automatically enabled in debug mode and disabled in production. You can control this behavior in `lib/config/device_preview_config.dart`:

```dart
class DevicePreviewConfig {
  // Enable device preview only in debug mode
  static bool get isEnabled => kDebugMode;
  
  // Add or remove devices from the preview list
  static List<DeviceInfo> get defaultDevices => [
    Devices.ios.iPhone13,
    Devices.ios.iPhone13ProMax,
    Devices.android.samsungGalaxyNote20,
    Devices.android.samsungGalaxyS20,
  ];
}
```

### Adding Custom Devices

You can add custom device configurations:

```dart
static List<DeviceInfo> get customDevices => [
  DeviceInfo(
    identifier: 'custom_tablet',
    name: 'Custom Tablet',
    screenSize: Size(1024, 768),
    safeAreas: EdgeInsets.zero,
    type: DeviceType.tablet,
    platform: TargetPlatform.android,
  ),
];
```

## Best Practices

### 1. Test Early and Often
- Use device preview during development, not just at the end
- Test on multiple devices as you build features

### 2. Responsive Design
- Design for the smallest screen first (mobile)
- Use responsive layouts that adapt to different screen sizes
- Test both portrait and landscape orientations

### 3. Performance
- Device preview runs in debug mode, so performance may be slower
- Test on actual devices for final performance validation

### 4. Accessibility
- Test with different screen sizes to ensure accessibility
- Verify touch targets are appropriately sized

## Troubleshooting

### Common Issues

1. **Preview Not Showing**: Ensure you're running in debug mode
2. **Slow Performance**: This is normal in debug mode
3. **Layout Issues**: Check your responsive design implementation

### Getting Help

- Check the [device_preview package documentation](https://pub.dev/packages/device_preview)
- Review Flutter's responsive design guidelines
- Test on actual devices for final validation

## Production Considerations

- Device preview is automatically disabled in production builds
- Always test on real devices before releasing
- Consider using Flutter's responsive design patterns for production apps

---

**Note**: Device Preview is a development tool and should not be used as a substitute for testing on real devices, especially for final validation before release.
