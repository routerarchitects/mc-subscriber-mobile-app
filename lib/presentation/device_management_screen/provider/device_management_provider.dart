import 'dart:async';

import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/base_bloc.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/core/utils/streamer.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/device_management_screen/models/mobile_device_info_model.dart';
import 'package:family_wifi/presentation/device_management_screen/models/router_device_info_model.dart';
import 'package:family_wifi/presentation/device_management_screen/repository/device_management_repository.dart';
import 'package:family_wifi/presentation/home_screen/models/topology_info.dart';
import 'package:family_wifi/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeviceManagementProvider with BaseBloc {
  String? selectedNodeSerial;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final Streamer<List<MobileDeviceInfoModel>> _mobileDevices = new Streamer();

  Stream<List<MobileDeviceInfoModel>?> get mobileDevices =>
      _mobileDevices.stream;

  List<MobileDeviceInfoModel>? get mobileDevicesInitialData =>
      _mobileDevices.valueOrNull;

  final Streamer<List<RouterDeviceInfoModel>> _routerDevices = new Streamer();

  Stream<List<RouterDeviceInfoModel>?> get routerDevices =>
      _routerDevices.stream;

  List<RouterDeviceInfoModel>? get routerDevicesInitialData =>
      _routerDevices.valueOrNull;

  late final DeviceManagementRepository _repository;

  DeviceManagementProvider.withNode({this.selectedNodeSerial});

  DeviceManagementProvider(
    LoadingStateProvider loadingStateProvider,
    AlertStateProvider alertStateProvider,
    DeviceManagementRepository repository, {
    this.selectedNodeSerial,
  }) : _repository = repository {
    initialize(loadingStateProvider, alertStateProvider);
  }

  void handleTopologyInfo(TopologyInfo? topologyInfo) {
    if (topologyInfo != null &&
        ((topologyInfo.nodes?.isNotEmpty ?? false) ||
            (topologyInfo.historicalClients?.isNotEmpty ?? false))) {
      List<Node> topologyNodes = topologyInfo.nodes ?? [];
      if (selectedNodeSerial?.isNotEmpty ?? false) {
        topologyNodes = topologyNodes
            .where((tpNode) => tpNode.serial == selectedNodeSerial)
            .toList();
      }
      List<MobileDeviceInfoModel> mobileDevices = topologyNodes
          .where(
            (tpNode) =>
                selectedNodeSerial == null ||
                tpNode.serial == selectedNodeSerial,
          )
          .expand((tpNode) => tpNode.aps ?? <AccessPoint>[])
          .expand((apNode) => apNode.clients ?? <Client>[])
          .map((clientNode) => _mapClientToModel(clientNode))
          .toList();

      if (topologyInfo.historicalClients?.isNotEmpty ?? false) {
        List<MobileDeviceInfoModel> historicalDevices = topologyInfo
            .historicalClients!
            .map(
              (clientNode) =>
                  _mapClientToModel(clientNode, isHistoricalDevice: true),
            )
            .toList();
        mobileDevices.addAll(historicalDevices);
      }

      _mobileDevices.value = mobileDevices;

      _routerDevices.value = topologyNodes.map((tpNode) {
        int noOfClients =
            tpNode.aps?.fold<int>(
              0,
              (previous, aps) => previous + (aps.clients?.length ?? 0),
            ) ??
            0;
        return RouterDeviceInfoModel(
          deviceName: tpNode.serial ?? 'NA',
          deviceUptime: tpNode.uptime.formatSeconds,
          actionButtonText:
              '${noOfClients > 1
                  ? '$noOfClients Devices'
                  : noOfClients == 1
                  ? '1 Device'
                  : 'No Devices'}',
        );
      }).toList();
    } else {
      if (_mobileDevices.hasValue) {
        _mobileDevices.value = null;
      }
      if (_routerDevices.hasValue) {
        _routerDevices.value = null;
      }
    }
  }

  MobileDeviceInfoModel _mapClientToModel(
    Client clientNode, {
    bool isHistoricalDevice = false,
  }) {
    return MobileDeviceInfoModel(
      macAddress: clientNode.station ?? 'NA',
      deviceName: (clientNode.fingerprint?.isNotEmpty ?? false)
          ? clientNode.fingerprint!
          : clientNode.station ?? 'NA',
      uploadSpeed: '${clientNode.txSpeed} Mbps ↑',
      downloadSpeed: '${clientNode.rxSpeed} Mbps ↓',
      isPaused: clientNode.isBlocked,
      pausedUntil: pausedDurationLabel(clientNode.blockedUntil),
      isHistoricalDevice: isHistoricalDevice,
    );
  }

  String? pausedDurationLabel(String? pausedUntil) {
    if (pausedUntil?.isEmpty ?? true) {
      return null;
    }
    if (pausedUntil == 'indefinite') {
      return 'Paused Indefinitely';
    } else {
      String? friendlyDateTime = pausedUntil!.friendlyDateTime;
      if (friendlyDateTime != null) {
        return 'Paused until $friendlyDateTime';
      }
    }
    return null;
  }

  Future<ToggleDevicePauseOutcome> toggleDevicePause(
    MobileDeviceInfoModel device, {
    int? pauseDuration,
  }) async {
    final wasPaused = device.isPaused;
    _updateMobileDevice(
      device.macAddress,
      device.copyWith(isPauseResumeInProgress: true),
    );

    try {
      Result result = await _repository.pauseResumeDevice(
        device.macAddress,
        !wasPaused,
        pauseDuration: pauseDuration != null && pauseDuration > 0
            ? pauseDuration
            : null,
      );

      if (result.isSuccess) {
        _updateMobileDevice(
          device.macAddress,
          device.copyWith(isPauseResumeInProgress: false, isPaused: !wasPaused),
        );
        return ToggleDevicePauseOutcome.success(
          messageKey: wasPaused
              ? 'resume_device_success'
              : 'pause_device_success',
          isPaused: !wasPaused,
        );
      } else if (result.sessionExpired) {
        _updateMobileDevice(
          device.macAddress,
          device.copyWith(isPauseResumeInProgress: false),
        );
        return const ToggleDevicePauseOutcome.sessionExpired();
      } else {
        _updateMobileDevice(
          device.macAddress,
          device.copyWith(isPauseResumeInProgress: false),
        );
        return ToggleDevicePauseOutcome.error(
          message: result.message?.toString(),
          messageKey: wasPaused ? 'resume_device_error' : 'pause_device_error',
        );
      }
    } catch (error) {
      _updateMobileDevice(
        device.macAddress,
        device.copyWith(isPauseResumeInProgress: false),
      );

      // Handle error
      print('Toggle Device Pause error: $error');
      return const ToggleDevicePauseOutcome.error(
        messageKey: 'failed',
        titleKey: 'something_went_wrong',
      );
    }
  }

  void _updateMobileDevice(String macAddress, MobileDeviceInfoModel updated) {
    if (!_mobileDevices.hasValue || _mobileDevices.value == null) {
      return;
    }
    final current = _mobileDevices.value;
    final index = current.indexWhere((item) => item.macAddress == macAddress);
    if (index == -1) {
      return;
    }
    final next = List<MobileDeviceInfoModel>.of(current);
    next[index] = updated;
    _mobileDevices.value = next;
  }

  Future<bool> handleRouterMeshDelete(int indexToDelete) async {
    Completer<bool> deleteCompleter = Completer<bool>();
    showAlert(
      await 'remove_device_confirm_message'.tr(),
      title: await 'remove_device_confirm_title'.tr(),
      yesAction: await 'remove_device_confirm_action'.tr(),
      noAction: 'Cancel',
      yesHandler: () async {
        RouterDeviceInfoModel deviceInfo = _routerDevices.value.elementAt(
          indexToDelete,
        );
        bool deleted = await deleteRouterMeshDevice(deviceInfo.deviceName);
        if (deleted) {
          _routerDevices.value.remove(deviceInfo);
          _routerDevices.value = List.of(_routerDevices.value);
        }
        deleteCompleter.complete(deleted);
      },
      noHandler: () => deleteCompleter.complete(false),
    );
    return deleteCompleter.future;
  }

  Future<bool> deleteRouterMeshDevice(String macAddress) async {
    try {
      startLoading();

      RegExp specialChars = RegExp(r'[^\w]+');
      String macAddressFormatted = macAddress
          .trim()
          .replaceAll(specialChars, '')
          .toLowerCase();

      Result result = await _repository.deleteDevice(macAddressFormatted);
      dismissLoading();

      if (result.isSuccess) {
        return true;
      } else if (result.sessionExpired) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
      } else {
        showAlert(result.message, title: await 'remove_device_failed'.tr());
      }
    } catch (error) {
      dismissLoading();

      // Handle error
      print('Remove device error: $error');
    }
    return false;
  }

  void dispose() {
    _mobileDevices.close();
    _routerDevices.close();
  }
}

enum ToggleDevicePauseStatus { success, error, sessionExpired }

class ToggleDevicePauseOutcome {
  final ToggleDevicePauseStatus status;
  final String? messageKey;
  final String? titleKey;
  final String? message;
  final bool? isPaused;

  const ToggleDevicePauseOutcome._({
    required this.status,
    this.messageKey,
    this.titleKey,
    this.message,
    this.isPaused,
  });

  const ToggleDevicePauseOutcome.sessionExpired()
    : this._(status: ToggleDevicePauseStatus.sessionExpired);

  const ToggleDevicePauseOutcome.success({
    required String messageKey,
    bool? isPaused,
  }) : this._(
         status: ToggleDevicePauseStatus.success,
         messageKey: messageKey,
         isPaused: isPaused,
       );

  const ToggleDevicePauseOutcome.error({
    String? message,
    String? messageKey,
    String? titleKey,
  }) : this._(
         status: ToggleDevicePauseStatus.error,
         message: message,
         messageKey: messageKey,
         titleKey: titleKey,
       );

  bool get isSuccess => status == ToggleDevicePauseStatus.success;

  bool get isError => status == ToggleDevicePauseStatus.error;

  bool get isSessionExpired => status == ToggleDevicePauseStatus.sessionExpired;
}

extension IterableExtension on Iterable {
  // A generic function to deeply flatten any nested, nullable iterable structure
  Iterable<T> deepFlatten<T>() sync* {
    for (final element in this) {
      if (element == null) {
        continue; // Skip if an inner iterable or element is null
      }

      // Check if the element is itself an Iterable (but not a String)
      // String is a special case of Iterable<int> but should be treated as a single element
      if (element is Iterable && element is! String) {
        // Recursively flatten the nested iterable
        yield* element.deepFlatten<T>();
      } else {
        // If it's a CustomModel or other non-iterable, yield it
        // We cast it to T, assuming the input structure eventually resolves to T
        yield element as T;
      }
    }
  }
}

extension RateExtension on num? {
  double get bpsToMbps => (this ?? 0) > 0 ? this! / 1000000 : 0;

  double get bpsToKbps => (this ?? 0) > 0 ? this! / 1000 : 0;

  String get formatSeconds {
    if (this != null) {
      // Define constants for time units
      const int secondsPerMinute = 60;
      const int secondsPerHour = 3600; // 60 * 60
      const int secondsPerDay = 86400; // 24 * 3600
      const int secondsPerWeek = 604800; // 7 * 86400
      const int secondsPerMonth = 2592000; // 30 * 86400
      const int secondsPerYear = 31536000; // ~365 * 86400 (approximate)

      int years = this! ~/ secondsPerYear;
      int remainingSeconds = (this! % secondsPerYear).toInt();

      int months = remainingSeconds ~/ secondsPerMonth;
      remainingSeconds %= secondsPerMonth;

      int weeks = remainingSeconds ~/ secondsPerWeek;
      remainingSeconds %= secondsPerWeek;

      int days = remainingSeconds ~/ secondsPerDay;
      remainingSeconds %= secondsPerDay;

      int hours = remainingSeconds ~/ secondsPerHour;
      remainingSeconds %= secondsPerHour;

      int minutes = remainingSeconds ~/ secondsPerMinute;
      remainingSeconds %= secondsPerMinute;

      int seconds = remainingSeconds;

      List<String> parts = [];
      if (years > 0) parts.add('$years years');
      if (months > 0) parts.add('$years months');
      if (weeks > 0) parts.add('$weeks weeks');
      if (days > 0) parts.add('$days days');
      if (hours > 0) parts.add('$hours hours');
      if (minutes > 0) parts.add('$minutes minutes');
      if (seconds > 0 || parts.isEmpty) parts.add('$seconds seconds');

      return parts.join(', ');
    }
    return 'NA';
  }
}

extension FriendlyDateTimeExtension on String {
  String? get friendlyDateTime {
    // Parse the JSON datetime string into a DateTime object
    DateTime? blockedUntil = DateTime.tryParse(this);
    if (blockedUntil == null) {
      return null;
    }
    DateTime now = DateTime.now();

    // Create date-only objects to ignore time during day comparisons
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));
    DateTime targetDay = DateTime(
      blockedUntil.year,
      blockedUntil.month,
      blockedUntil.day,
    );

    // Format the time portion (e.g., 4PM, 12PM, 8:30AM)
    // 'ja' formats it to '12 PM'. Removing the space gives '12PM'.
    String formattedTime = DateFormat(
      'jm',
    ).format(blockedUntil);

    if (targetDay == today) {
      return "Today $formattedTime";
    } else if (targetDay == tomorrow) {
      return "Tomorrow $formattedTime";
    } else {
      // Formats to "18th Sep" style.
      // Note: 'd' gives day number. For custom suffixes like 'st', 'nd', 'rd', 'th',
      // a small helper can be used, or standard 'd MMM' (e.g., 18 Sep) works great.
      String dayWithSuffix = _getDayWithSuffix(blockedUntil.day);
      String month = DateFormat('MMM').format(blockedUntil);
      return "$dayWithSuffix $month, $formattedTime";
    }
  }

  // Optional helper to add 'st', 'nd', 'rd', 'th' suffix to the day
  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }
}
