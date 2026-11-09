import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/shared_preferences_helper.dart';
import 'package:family_wifi/main.dart';
import 'package:family_wifi/presentation/login_screen/repository/login_repository.dart';
import 'package:family_wifi/widgets/style_helper.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import './provider/login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return MyApp.buildLoadingAlertProviders(
      child: MultiProvider(
        providers: [
          Provider<LoginRepository>(
            create: (_) => LoginRepository(
              context.read<ApiHelper>(),
              context.read<SharedPreferencesHelper>(),
            ),
          ),
          Provider<LoginProvider>(
            create: (lCtx) => LoginProvider(
              lCtx.read<LoadingStateProvider>(),
              lCtx.read<AlertStateProvider>(),
              lCtx.read<LoginRepository>(),
            ),
            dispose: (_, provider) => provider.dispose(),
          ),
        ],
        child: const LoginScreen(),
      ),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final LoginProvider controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<LoginProvider>(context, listen: false);
    controller.loadingStateProvider.addListener(handleLoadingState);
    controller.alertStateProvider.addListener(handleAlertState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.init();
    });
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
        appBar: CustomAppBar(
          title: 'Login',
          hasLeading: true,
          leadingIcon: ImageConstant.imgDepth4Frame0WhiteA700,
          onLeadingPressed: () {
            bool canPop = Navigator.canPop(context);
            if (canPop) {
              NavigatorService.goBack();
            } else {
              NavigatorService.popAndPushNamed(AppRoutes.networkWelcomeScreen);
            }
          },
          backgroundColor: appTheme.gray_900,
          titleColor: appTheme.white_A700,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    CustomEditText(
                      controller: controller.emailController,
                      hintText: 'Email',
                      inputType: CustomInputType.email,
                      backgroundColor: appTheme.blue_gray_900,
                      margin: EdgeInsets.symmetric(horizontal: 16.h),
                      validator: controller.validateEmail,
                    ),
                    SizedBox(height: 24.h),
                    CustomEditText(
                      controller: controller.passwordController,
                      hintText: 'Password',
                      inputType: CustomInputType.password,
                      backgroundColor: appTheme.blue_gray_900,
                      margin: EdgeInsets.symmetric(horizontal: 16.h),
                      validator: controller.validatePassword,
                    ),
                    SizedBox(height: 18.h),
                    GestureDetector(
                      onTap: () {
                        NavigatorService.pushNamed(
                          AppRoutes.forgotPasswordScreen,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 16.h),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyleHelper.instance.body14RegularInter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.h),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Login',
                      onPressed: controller.isLoading
                          ? null
                          : () {
                              controller.onLoginPressed(_formKey);
                            },
                      backgroundColor: appTheme.blue_700,
                      textColor: appTheme.whiteCustom,
                      fontSize: 16.fSize,
                      fontWeight: FontWeight.w700,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 12.h),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
