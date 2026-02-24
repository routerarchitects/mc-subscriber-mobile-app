import 'dart:async';

import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/base_bloc.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/core/utils/streamer.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/device_management_screen/models/router_device_info_model.dart';
import 'package:family_wifi/presentation/device_management_screen/repository/device_management_repository.dart';
import 'package:family_wifi/presentation/home_screen/models/topology_info.dart';
import 'package:family_wifi/routes/app_routes.dart';
import 'package:family_wifi/theme/theme_helper.dart';
import 'package:flutter/material.dart';

import '../models/mobile_device_info_model.dart';

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
          .map((tpNode) {
            if (selectedNodeSerial == null ||
                selectedNodeSerial == tpNode.serial) {
              return tpNode.aps?.map((apNode) {
                return apNode.clients?.map((clientNode) {
                  return MobileDeviceInfoModel(
                    macAddress: clientNode.station ?? 'NA',
                    deviceName: (clientNode.fingerprint?.isNotEmpty ?? false)
                        ? clientNode.fingerprint!
                        : clientNode.station ?? 'NA',
                    uploadSpeed: '${clientNode.txSpeed} Mbps ↑',
                    downloadSpeed: '${clientNode.rxSpeed} Mbps ↓',
                    isPaused: clientNode.isBlocked,
                  );
                });
              });
            }
          })
          .deepFlatten<MobileDeviceInfoModel>()
          .toList();

      if (topologyInfo.historicalClients?.isNotEmpty ?? false) {
        List<MobileDeviceInfoModel> historicalDevices = topologyInfo
            .historicalClients!
            .map(
              (clientNode) => MobileDeviceInfoModel(
                macAddress: clientNode.station ?? 'NA',
                deviceName: (clientNode.fingerprint?.isNotEmpty ?? false)
                    ? clientNode.fingerprint!
                    : clientNode.station ?? 'NA',
                uploadSpeed: '${clientNode.txSpeed} Mbps ↑',
                downloadSpeed: '${clientNode.rxSpeed} Mbps ↓',
                isPaused: clientNode.isBlocked,
                isHistoricalDevice: true,
              ),
            )
            .toList();
        mobileDevices.addAll(historicalDevices);
      }

      _mobileDevices.value = mobileDevices;

      // _mobileDevices.value = List.from(
      //   _mobileDevices.value..addAll(List.from(_mobileDevices.value)),
      // );
      // _mobileDevices.value = List.from(
      //   _mobileDevices.value..addAll(List.from(_mobileDevices.value)),
      // );

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

  Future<void> toggleDevicePause(
    MobileDeviceInfoModel device,
    BuildContext context,
  ) async {
    device.isPauseResumeInProgress = true;
    _mobileDevices.value = List.of(_mobileDevices.value);

    try {
      Result result = await _repository.pauseResumeDevice(
        device.macAddress,
        !device.isPaused,
      );

      if (result.isSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              await (device.isPaused
                      ? 'resume_device_success'
                      : 'pause_device_success')
                  .tr(),
            ),
            backgroundColor: appTheme.colorFF4CAF,
          ),
        );
        device.isPauseResumeInProgress = false;
        device.isPaused = !device.isPaused;
        _mobileDevices.value = List.of(_mobileDevices.value);
      } else if (result.sessionExpired) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
      } else {
        showAlert(
          result.message,
          title:
              await (device.isPaused
                      ? 'resume_device_error'
                      : 'pause_device_error')
                  .tr(),
        );
        device.isPauseResumeInProgress = false;
        _mobileDevices.value = List.of(_mobileDevices.value);
      }
    } catch (error) {
      showAlert(await 'failed'.tr(), title: await 'something_went_wrong'.tr());

      device.isPauseResumeInProgress = false;
      _mobileDevices.value = List.of(_mobileDevices.value);

      // Handle error
      print('Toggle Device Pause error: $error');
    }
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

      Result result = await _repository!.deleteDevice(macAddressFormatted);
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
