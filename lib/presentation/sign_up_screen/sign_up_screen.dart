import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/shared_preferences_helper.dart';
import 'package:family_wifi/main.dart';
import 'package:family_wifi/presentation/sign_up_screen/repository/sign_up_repository.dart';
import 'package:family_wifi/widgets/style_helper.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import './provider/sign_up_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return MyApp.buildLoadingAlertProviders(
      child: MultiProvider(
        providers: [
          Provider<SignUpRepository>(
            create: (_) => SignUpRepository(context.read<ApiHelper>()),
          ),
          Provider<SignUpProvider>(
            create: (lCtx) => SignUpProvider(
              lCtx.read<LoadingStateProvider>(),
              lCtx.read<AlertStateProvider>(),
              lCtx.read<SignUpRepository>(),
              lCtx.read<SharedPreferencesHelper>(),
              lCtx.read<ApiHelper>(),
            ),
            dispose: (_, provider) => provider.dispose(),
          ),
        ],
        child: const SignUpScreen(),
      ),
    );
  }

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final SignUpProvider controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<SignUpProvider>(context, listen: false);
    controller.loadingStateProvider.addListener(handleLoadingState);
    controller.alertStateProvider.addListener(handleAlertState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.init().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
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
          title: 'Sign up',
          hasLeading: true,
          leadingIcon: ImageConstant.imgDepth4Frame0WhiteA700,
          onLeadingPressed: () => NavigatorService.goBack(),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        "Let's get started",
                        style: TextStyleHelper.instance.title22BoldInter,
                      ),
                      SizedBox(height: 19.h),
                      Text(
                        'Enter your email address and operator ID.',
                        style: TextStyleHelper.instance.title16RegularInter
                            .copyWith(color: appTheme.white_A700),
                      ),
                      SizedBox(height: 46.h),
                      CustomEditText(
                        controller: controller.emailController,
                        hintText: 'Email address',
                        inputType: CustomInputType.email,
                        backgroundColor: appTheme.blue_gray_900,
                        validator: controller.validateEmail,
                      ),
                      SizedBox(height: 24.h),
                      CustomEditText(
                        controller: controller.operatorIdController,
                        hintText: 'Operator ID',
                        backgroundColor: appTheme.blue_gray_900,
                        validator: controller.validateOperatorId,
                      ),
                      SizedBox(height: 24.h),
                      CustomEditText(
                        controller: controller.customServerUrlController,
                        hintText: 'Server URL',
                        backgroundColor: appTheme.blue_gray_900,
                        validator: controller.validateServerUrl,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.h),
                child: CustomButton(
                  text: 'Next',
                  backgroundColor: appTheme.blue_700,
                  textColor: appTheme.white_A700,
                  fontSize: 16.fSize,
                  fontWeight: FontWeight.w700,
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 12.h),
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          controller.onNextPressed(_formKey);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
