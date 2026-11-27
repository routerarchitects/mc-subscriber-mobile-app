import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/base_bloc.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/login_screen/models/login_model.dart';
import 'package:family_wifi/presentation/login_screen/repository/login_repository.dart';
import 'package:family_wifi/routes/app_routes.dart';
import 'package:flutter/material.dart';

class LoginProvider with BaseBloc {
  LoginModel loginModel = LoginModel();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late final LoginRepository _repository;

  LoginProvider(
    LoadingStateProvider loadingStateProvider,
    AlertStateProvider alertStateProvider,
    this._repository,
  ) {
    initialize(loadingStateProvider, alertStateProvider);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  void init() {
    _repository.removeAccessToken();
    emailController.clear();
    passwordController.clear();
  }

  String? validateEmail(String? value) {
    if (value?.isEmpty == true) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value ?? '')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value?.isEmpty == true) {
      return 'Password is required';
    }
    if ((value?.length ?? 0) < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  Future<void> onLoginPressed(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    startLoading();

    try {
      loginModel.userId = emailController.text.trim();
      loginModel.password = passwordController.text.trim();

      Result result = await _repository.login(loginModel);

      dismissLoading();
      if (result.isSuccess) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.homeScreen);
      } else {
        showAlert(result.message, title: await 'login_failed'.tr());
      }
    } catch (error) {
      dismissLoading();

      // Handle error
      print('Login error: $error');
    }
  }
}
