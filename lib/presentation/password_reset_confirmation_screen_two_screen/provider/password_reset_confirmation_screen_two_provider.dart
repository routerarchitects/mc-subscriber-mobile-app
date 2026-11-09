import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/base_bloc.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/presentation/sign_up_screen/models/sign_up_model.dart';
import 'package:family_wifi/presentation/sign_up_screen/repository/sign_up_repository.dart';
import 'package:family_wifi/routes/app_routes.dart';
import 'package:open_mail_app_plus/open_mail_app_plus.dart';

class PasswordResetConfirmationScreenTwoProvider with BaseBloc {
  SignUpProvider(
    LoadingStateProvider loadingStateProvider,
    AlertStateProvider alertStateProvider,
  ) {
    initialize(loadingStateProvider, alertStateProvider);
  }
  late final SignUpRepository _signUpRepository;
  final SignUpModel _signUpModel = SignUpModel();

  PasswordResetConfirmationScreenTwoProvider(
    LoadingStateProvider loadingStateProvider,
    AlertStateProvider alertStateProvider,
    this._signUpRepository,
    String? email,
    String? registrationId,
  ) {
    initialize(loadingStateProvider, alertStateProvider);
    _signUpModel.email = email ?? '';
    _signUpModel.operatorId = registrationId ?? '';
  }

  Future<List<MailApp>?> onOpenEmailApp() async {
    startLoading();

    // Android: Will open mail app or show native picker.
    // iOS: Will open mail app if single mail app found.
    var result = await OpenMailAppPlus.openMailApp();

    dismissLoading();

    // If no mail apps found, show error
    if (!result.didOpen && !result.canOpen) {
      showAlert(
        await 'no_mail_app_message'.tr(),
        title: await 'no_mail_app_title'.tr(),
      );

      // iOS: if multiple mail apps found, show dialog to select.
      // There is no native intent/default app system in iOS so
      // you have to do it yourself.
    } else if (!result.didOpen && result.canOpen) {
      return result.options;
    } else {
      NavigatorService.popAndPushNamed(AppRoutes.loginScreen);
    }

    return null;
  }

  Future<void> onResendPressed() async {
    if (_signUpModel.email == null || _signUpModel.email!.trim().isEmpty) {
      showAlert(await 'resend_email_missing'.tr());
      return;
    }

    startLoading();
    try {
      Result result = await _signUpRepository.requestVerificationEmailResend(
        _signUpModel,
      );
      dismissLoading();
      if (result.isSuccess) {
        showAlert(await 'resend_email_sent'.tr());
      } else {
        showAlert(result.message, title: await 'signup_failed'.tr());
      }
    } catch (error) {
      dismissLoading();
      showAlert(await 'something_went_wrong'.tr());
    }
  }
}
