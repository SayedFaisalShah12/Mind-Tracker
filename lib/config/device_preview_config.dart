import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

class DevicePreviewConfig {
  // Enable device preview only in debug mode
  static bool get isEnabled => kDebugMode;

  // Default devices to show in preview
  static List<DeviceInfo> get defaultDevices => [
    Devices.ios.iPhone13,
    Devices.ios.iPhone13ProMax,
    Devices.android.samsungGalaxyNote20,
    Devices.android.samsungGalaxyS20,
  ];

  // Custom device configurations
  static List<DeviceInfo> get customDevices => [
    // Add custom device configurations here if needed
  ];

  // Get all available devices
  static List<DeviceInfo> get allDevices => [
    ...defaultDevices,
    ...customDevices,
  ];
}
