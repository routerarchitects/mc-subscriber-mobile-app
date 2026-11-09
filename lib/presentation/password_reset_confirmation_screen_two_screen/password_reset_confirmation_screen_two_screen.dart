import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/main.dart';
import 'package:family_wifi/presentation/sign_up_screen/repository/sign_up_repository.dart';
import 'package:family_wifi/widgets/style_helper.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_app_plus/open_mail_app_plus.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import './provider/password_reset_confirmation_screen_two_provider.dart';

class PasswordResetConfirmationScreenTwo extends StatefulWidget {
  const PasswordResetConfirmationScreenTwo({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    final input =
        (ModalRoute.of(context)?.settings.arguments as Map?) ??
        <String, dynamic>{};
    return MyApp.buildLoadingAlertProviders(
      child: MultiProvider(
        providers: [
          Provider<SignUpRepository>(
            create: (_) => SignUpRepository(context.read<ApiHelper>()),
          ),
          Provider<PasswordResetConfirmationScreenTwoProvider>(
            create: (lCtx) => PasswordResetConfirmationScreenTwoProvider(
              lCtx.read<LoadingStateProvider>(),
              lCtx.read<AlertStateProvider>(),
              lCtx.read<SignUpRepository>(),
              input['email'],
              input['registrationId'],
            ),
          ),
        ],
        child: const PasswordResetConfirmationScreenTwo(),
      ),
    );
  }

  @override
  State<PasswordResetConfirmationScreenTwo> createState() =>
      _PasswordResetConfirmationScreenTwoState();
}

class _PasswordResetConfirmationScreenTwoState
    extends State<PasswordResetConfirmationScreenTwo> {
  late final PasswordResetConfirmationScreenTwoProvider controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<PasswordResetConfirmationScreenTwoProvider>(
      context,
      listen: false,
    );
    controller.loadingStateProvider.addListener(handleLoadingState);
    controller.alertStateProvider.addListener(handleAlertState);
  }

  handleLoadingState() {
    if (controller.isLoading) {
      final state = controller.loadingStateProvider;
      StyleHelper.showProgressDialog(context, state.title, state.message);
    } else {
      NavigatorService.goBack();
    }
  }

  handleAlertState() {
    if (controller.isAlertDisplaying) {
      final state = controller.alertStateProvider;
      StyleHelper.showAlertDialog(
        context,
        state.alertMsg,
        state.yesMsg,
        title: state.title,
        yesHandler: state.yesHandler,
        noLabel: state.noAction,
        noHandler: state.noHandler,
      );
    } else {
      NavigatorService.goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: appTheme.gray_900,
        appBar: _buildAppBar(context),
        body: Consumer<PasswordResetConfirmationScreenTwoProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Expanded(child: _buildMainContent(context)),
                _buildBottomSection(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'Reset password',
      hasLeading: true,
      leadingIcon: ImageConstant.imgDepth4Frame0WhiteA700,
      onLeadingPressed: () => NavigatorService.goBack(),
      backgroundColor: appTheme.gray_900,
      titleColor: appTheme.white_A700,
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            'Check your email',
            style: TextStyleHelper.instance.title22BoldInter.copyWith(
              height: 1.23,
            ),
          ),
          SizedBox(height: 19.h),
          Text(
            'We\'ve sent a link to your email address. Please check your inbox to set your password. After setting your password, return to the app and use the login button to access your account.',
            style: TextStyleHelper.instance.title16RegularInter.copyWith(
              color: appTheme.white_A700,
              height: 1.5,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    PasswordResetConfirmationScreenTwoProvider provider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Column(
        children: [
          CustomButton(
            text: 'Open email app',
            onPressed: onOpenEmailAppSelected,
            backgroundColor: appTheme.blue_700,
            textColor: appTheme.white_A700,
            fontSize: 16.fSize,
            fontWeight: FontWeight.w700,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12.h),
          ),
          FutureBuilder<String>(
            future: 'resend_button'.tr(),
            initialData: '',
            builder: (context, snapshot) {
              return CustomButton(
                text: snapshot.data ?? '',
                onPressed: provider.onResendPressed,
                backgroundColor: appTheme.blue_gray_900,
                textColor: appTheme.white_A700,
                fontSize: 16.fSize,
                fontWeight: FontWeight.w700,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12.h),
              );
            },
          ),
        ],
      ),
    );
  }

  onOpenEmailAppSelected() async {
    List<MailApp>? openMailAppList = await controller.onOpenEmailApp();
    if (openMailAppList?.isNotEmpty ?? false) {
      await showDialog(
        context: context,
        builder: (_) {
          return MailAppPickerDialog(mailApps: openMailAppList!);
        },
      );
      NavigatorService.popAndPushNamed(AppRoutes.loginScreen);
    }
  }
}
