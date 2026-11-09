import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/shared_preferences_helper.dart';
import 'package:family_wifi/main.dart';
import 'package:family_wifi/presentation/edit_network_screen/repository/edit_network_repository.dart';
import 'package:family_wifi/widgets/style_helper.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import './provider/edit_network_provider.dart';

class EditNetworkScreen extends StatefulWidget {
  const EditNetworkScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    final input = ModalRoute.of(context)?.settings.arguments as Map;
    return MyApp.buildLoadingAlertProviders(
      child: MultiProvider(
        providers: [
          Provider<EditNetworkRepository>(
            create: (_) => EditNetworkRepository(
              context.read<ApiHelper>(),
              context.read<SharedPreferencesHelper>(),
            ),
          ),
          Provider<EditNetworkProvider>(
            create: (lCtx) => EditNetworkProvider(
              lCtx.read<LoadingStateProvider>(),
              lCtx.read<AlertStateProvider>(),
              lCtx.read<EditNetworkRepository>(),
              input['macAddress'],
              input['networkName'],
            ),
            dispose: (_, provider) => provider.dispose(),
          ),
        ],
        child: const EditNetworkScreen(),
      ),
    );
  }

  @override
  State<EditNetworkScreen> createState() => _EditNetworkScreenState();
}

class _EditNetworkScreenState extends State<EditNetworkScreen> {
  late final EditNetworkProvider controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<EditNetworkProvider>(context, listen: false);
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(72.h),
          child: CustomAppBar(
            title: 'Edit Network',
            hasLeading: true,
            leadingIcon: ImageConstant.imgDepth4Frame0WhiteA700,
            onLeadingPressed: () => Navigator.pop(context),
            backgroundColor: appTheme.gray_900,
          ),
        ),
        body: Form(
          key: controller.formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        _buildNetworkNameSection(),
                        SizedBox(height: 26.h),
                        _buildPasswordSection(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Network Name (SSID)',
          style: TextStyleHelper.instance.title16MediumInter,
        ),
        SizedBox(height: 8.h),
        CustomEditText(
          controller: controller.networkNameController,
          hintText: 'Enter network name',
          backgroundColor: appTheme.blue_gray_900,
          contentPadding: EdgeInsets.all(12.h),
          validator: controller.validateNetworkName,
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password (Key)',
          style: TextStyleHelper.instance.title16MediumInter,
        ),
        SizedBox(height: 6.h),
        CustomEditText(
          controller: controller.passwordController,
          hintText: 'Enter password',
          inputType: CustomInputType.password,
          backgroundColor: appTheme.blue_gray_900,
          contentPadding: EdgeInsets.all(12.h),
          validator: controller.validatePassword,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: CustomButton(
        text: 'Save Changes',
        onPressed: () => controller.saveChanges(context),
        backgroundColor: appTheme.blue_700,
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        margin: EdgeInsets.only(bottom: 12.h),
      ),
    );
  }
}
