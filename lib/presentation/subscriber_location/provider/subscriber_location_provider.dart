import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/action_result.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/subscriber_location/repository/subscriber_location_repository.dart';
import 'package:family_wifi/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class SubscriberLocationProvider {
  late final SubscriberLocationRepository _repository;
  final List<String> _ianaTimezones =
      tz.timeZoneDatabase.locations.keys.toList()..sort();
  final TextEditingController locationNameController = TextEditingController();
  String? selectedTimezone;

  ValueNotifier<ConfigurationState> configurationState = new ValueNotifier(
    ConfigurationState.PENDING,
  );

  final ValueNotifier<String?> locationError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> timezoneError = ValueNotifier<String?>(null);

  SubscriberLocationProvider(this._repository);

  List<String> timezones() {
    return _ianaTimezones;
  }

  void dispose() {
    locationNameController.dispose();
    configurationState.dispose();
    locationError.dispose();
    timezoneError.dispose();
  }

  void onLocationNameChanged(String value) {
    this.locationError.value = null;
  }

  void onTimezoneSelected(String? value) {
    this.selectedTimezone = value;
    this.timezoneError.value = null;
  }

  Future<String?> validateLocationName() async {
    if (locationNameController.text.isEmpty) {
      return await 'empty_location_name'.tr();
    }
    return null;
  }

  Future<String?> validateTimezone() async {
    if ((selectedTimezone?.trim().isEmpty ?? true) ||
        !timezones().contains(selectedTimezone!.trim())) {
      return await 'invalid_location_timezone'.tr();
    }
    return null;
  }

  Future<ActionResult?> addLocation() async {
    this.locationError.value = await validateLocationName();
    this.timezoneError.value = await validateTimezone();

    if (locationError.value != null || this.timezoneError.value != null) {
      return null;
    }

    configurationState.value = ConfigurationState.CONFIGURING;

    ActionResult actionResult = new ActionResult(isSuccess: false);

    try {
      Result result = await _repository.addSubscriberLocation(
        locationNameController.text.trim(),
        selectedTimezone!,
      );

      if (result.isSuccess) {
        configurationState.value = ConfigurationState.CONFIGURED;
        actionResult.isSuccess = true;
      } else if (result.sessionExpired) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
      } else {
        configurationState.value = ConfigurationState.PENDING;
        actionResult.errorMessage = result.message;
      }
    } catch (error) {
      configurationState.value = ConfigurationState.PENDING;

      // Handle error
      print('Configuration error: $error');
    }
    return actionResult;
  }
}

enum ConfigurationState { PENDING, CONFIGURING, CONFIGURED }
