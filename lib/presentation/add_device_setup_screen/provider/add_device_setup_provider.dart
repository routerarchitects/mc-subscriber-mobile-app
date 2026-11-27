import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/base_bloc.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/add_device_setup_screen/repository/add_device_setup_repository.dart';
import 'package:family_wifi/routes/app_routes.dart';
import 'package:family_wifi/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class AddDeviceSetupProvider with BaseBloc {
  TextEditingController macAddressController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ValueNotifier<ConfigurationState> configurationState = new ValueNotifier(
    ConfigurationState.PENDING,
  );

  late final AddDeviceSetupRepository _repository;

  AddDeviceSetupProvider(
    LoadingStateProvider loadingStateProvider,
    AlertStateProvider alertStateProvider,
    this._repository,
  ) {
    initialize(loadingStateProvider, alertStateProvider);
  }

  @override
  void dispose() {
    macAddressController.dispose();
    configurationState.dispose();
  }

  void init() {
    // Initialize any required data
  }

  String? validateMacAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'MAC address is required';
    }

    final macRegex = RegExp(r'^([0-9a-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    if (!macRegex.hasMatch(value.trim())) {
      return 'Please enter a valid MAC address';
    }

    return null;
  }

  Future<void> onNextPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid MAC address'),
          backgroundColor: appTheme.redCustom,
        ),
      );
      return;
    }

    configurationState.value = ConfigurationState.CONFIGURING;

    try {
      RegExp specialChars = RegExp(r'[^\w]+');
      String macAddress = macAddressController.text
          .trim()
          .replaceAll(specialChars, '')
          .toLowerCase();
      Result result = await _repository.addDevice(macAddress);

      if (result.isSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(await 'add_device_success'.tr()),
            backgroundColor: appTheme.colorFF4CAF,
          ),
        );
        configurationState.value = ConfigurationState.CONFIGURED;
      } else if (result.sessionExpired) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
      } else {
        showAlert(result.message, title: await 'add_device_failed'.tr());
        configurationState.value = ConfigurationState.PENDING;
      }
    } catch (error) {
      configurationState.value = ConfigurationState.PENDING;

      // Handle error
      print('Edit Network error: $error');
    }
  }
}

enum ConfigurationState { PENDING, CONFIGURING, CONFIGURED }
