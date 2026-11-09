import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/base_bloc.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/edit_network_screen/repository/edit_network_repository.dart';
import 'package:flutter/material.dart';

import '../models/edit_network_model.dart';

import '../../../core/app_export.dart';

class EditNetworkProvider with BaseBloc {
  final EditNetworkModel editNetworkModel = EditNetworkModel();

  TextEditingController networkNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final EditNetworkRepository _repository;
  late final String? _macAddress;
  late final String? _networkName;

  EditNetworkProvider(
    LoadingStateProvider loadingStateProvider,
    AlertStateProvider alertStateProvider,
    this._repository,
    this._macAddress,
    this._networkName,
  ) {
    initialize(loadingStateProvider, alertStateProvider);
    editNetworkModel.mac = _macAddress;
    editNetworkModel.ssid = _networkName;
  }

  @override
  void dispose() {
    networkNameController.dispose();
    passwordController.dispose();
  }

  void init() {
    // Initialize with existing network data if available
    networkNameController.text = editNetworkModel.ssid ?? '';
    passwordController.text = editNetworkModel.password ?? '';
  }

  String? validateNetworkName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Network name is required';
    }
    if (value.length < 2) {
      return 'Network name must be at least 2 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<void> saveChanges(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    startLoading();

    try {
      editNetworkModel.ssid = networkNameController.text.trim();
      editNetworkModel.password = passwordController.text.trim();

      Result result = await _repository.editNetwork(editNetworkModel);

      dismissLoading();
      if (result.isSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(await 'edit_network_success'.tr()),
            backgroundColor: appTheme.colorFF4CAF,
          ),
        );
        NavigatorService.goBack();
      } else if (result.sessionExpired) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
      } else {
        showAlert(result.message, title: await 'edit_network_failed'.tr());
      }
    } catch (error) {
      dismissLoading();

      // Handle error
      print('Edit Network error: $error');
    }
  }
}
