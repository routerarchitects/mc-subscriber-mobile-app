import 'package:family_wifi/core/network/api_constants.dart';
import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/base_bloc.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/core/utils/shared_preferences_helper.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/sign_up_screen/models/sign_up_model.dart';
import 'package:family_wifi/presentation/sign_up_screen/repository/sign_up_repository.dart';
import 'package:family_wifi/routes/app_routes.dart';
import 'package:flutter/material.dart';

class SignUpProvider with BaseBloc {
  SignUpModel signUpModel = SignUpModel();
  TextEditingController emailController = TextEditingController();
  TextEditingController operatorIdController = TextEditingController();
  TextEditingController customServerUrlController = TextEditingController();
  late final SignUpRepository _repository;
  late final SharedPreferencesHelper _sharedPreferencesHelper;
  late final ApiHelper _apiHelper;

  SignUpProvider(
    LoadingStateProvider loadingStateProvider,
    AlertStateProvider alertStateProvider,
    this._repository,
    this._sharedPreferencesHelper,
    this._apiHelper,
  ) {
    initialize(loadingStateProvider, alertStateProvider);
  }

  @override
  void dispose() {
    emailController.dispose();
    operatorIdController.dispose();
    customServerUrlController.dispose();
  }

  Future<void> init() async {
    final storedServerUrl = await _sharedPreferencesHelper.customServerUrl;
    final defaultServerUrl =
        ApiConstants.developmentMode
            ? ApiConstants.baseUrlDev
            : ApiConstants.baseUrl;
    String? serverUrl = storedServerUrl?.trim();

    customServerUrlController.text =
        serverUrl == null || serverUrl.isEmpty ? defaultServerUrl : serverUrl;
    _apiHelper.setCustomHost(customServerUrlController.text.trim());
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? validateOperatorId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Operator ID is required';
    }

    return null;
  }

  String? validateServerUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Server URL is required';
    }

    if (trimmed.contains('://') ||
        trimmed.contains('/') ||
        trimmed.contains('?') ||
        trimmed.contains('#')) {
      return 'Enter hostname or hostname:port only';
    }

    final normalized = _normalizeServerUrl(trimmed);
    if (normalized.isEmpty) {
      return 'Enter a valid hostname';
    }

    final parts = normalized.split(':');
    if (parts.length > 2) {
      return 'Enter hostname or hostname:port only';
    }

    final host = parts[0];
    final port = parts.length == 2 ? parts[1] : null;

    if (host.isEmpty) {
      return 'Enter a valid hostname';
    }

    final hostRegex = RegExp(r'^[A-Za-z0-9.-]+$');
    final fqdnRegex =
        RegExp(r'^(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$');
    final isFqdn = hostRegex.hasMatch(host) && fqdnRegex.hasMatch(host);

    if (!isFqdn) {
      return 'Enter a valid fully qualified domain name';
    }

    if (port != null) {
      final portNumber = int.tryParse(port);
      if (portNumber == null || portNumber < 1 || portNumber > 65535) {
        return 'Enter a valid port (1-65535)';
      }
    }

    return null;
  }

  String _normalizeServerUrl(String value) {
    return value.trim().toLowerCase();
  }

  Future<void> onNextPressed(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    startLoading();

    try {
      signUpModel.email = emailController.text.trim();
      signUpModel.operatorId = operatorIdController.text.trim();

      final normalizedServerUrl = _normalizeServerUrl(
        customServerUrlController.text,
      );
      await _sharedPreferencesHelper.setCustomServerUrl(normalizedServerUrl);
      _apiHelper.setCustomHost(normalizedServerUrl);

      Result result = await _repository.createAccount(signUpModel);

      dismissLoading();
      if (result.isSuccess) {
        NavigatorService.popAndPushNamed(
          AppRoutes.passwordResetConfirmationScreenTwo,
          arguments: {
            'email': signUpModel.email,
            'registrationId': signUpModel.operatorId,
          },
        );
      } else {
        showAlert(result.message, title: await 'signup_failed'.tr());
      }
    } catch (error) {
      dismissLoading();

      // Handle error
      print('Sign up error: $error');
    }
  }
}
