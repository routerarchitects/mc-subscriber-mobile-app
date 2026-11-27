/// This class is used in the [device_management_screen] screen.
class MobileDeviceInfoModel {
  MobileDeviceInfoModel({
    required this.macAddress,
    this.deviceName = 'NA',
    this.uploadSpeed = 'NA',
    this.downloadSpeed = 'NA',
    String? iconPath,
    this.isPaused = false,
    this.pausedUntil,
    this.isPauseResumeInProgress = false,
    this.isHistoricalDevice = false,
  }) : iconPath = iconPath ?? 'assets/images/img_depth_4_frame_0_1.svg';

  final String macAddress;
  final String deviceName;
  final String uploadSpeed;
  final String downloadSpeed;
  final String? iconPath;
  final bool isPaused;
  final String? pausedUntil;
  final bool isPauseResumeInProgress;
  final bool isHistoricalDevice;

  MobileDeviceInfoModel copyWith({
    String? macAddress,
    String? deviceName,
    String? uploadSpeed,
    String? downloadSpeed,
    String? iconPath,
    bool? isPaused,
    String? pausedUntil,
    bool? isPauseResumeInProgress,
    bool? isHistoricalDevice,
  }) {
    return MobileDeviceInfoModel(
      macAddress: macAddress ?? this.macAddress,
      deviceName: deviceName ?? this.deviceName,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      iconPath: iconPath ?? this.iconPath,
      isPaused: isPaused ?? this.isPaused,
      pausedUntil: pausedUntil ?? this.pausedUntil,
      isPauseResumeInProgress:
          isPauseResumeInProgress ?? this.isPauseResumeInProgress,
      isHistoricalDevice: isHistoricalDevice ?? this.isHistoricalDevice,
    );
  }
}
