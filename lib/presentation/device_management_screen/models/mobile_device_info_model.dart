/// This class is used in the [device_management_screen] screen.

// ignore_for_file: must_be_immutable
class MobileDeviceInfoModel {
  MobileDeviceInfoModel({
    required this.macAddress,
    this.deviceName = 'NA',
    this.uploadSpeed = 'NA',
    this.downloadSpeed = 'NA',
    this.iconPath,
    this.isPaused = false,
    this.isPauseResumeInProgress = false,
    this.isHistoricalDevice = false,
  }) {
    macAddress = macAddress;
    deviceName = deviceName;
    uploadSpeed = uploadSpeed;
    downloadSpeed = downloadSpeed;
    iconPath = iconPath ?? 'assets/images/img_depth_4_frame_0_1.svg';
    isPaused = isPaused;
  }

  String macAddress;
  String deviceName;
  String uploadSpeed;
  String downloadSpeed;
  String? iconPath;
  bool isPaused;
  bool isPauseResumeInProgress;
  bool isHistoricalDevice;
}
