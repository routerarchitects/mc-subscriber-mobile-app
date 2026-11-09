import 'package:family_wifi/core/app_export.dart';
import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/main.dart';
import 'package:family_wifi/presentation/add_device_setup_screen/provider/add_device_setup_provider.dart';
import 'package:family_wifi/presentation/add_device_setup_screen/repository/add_device_setup_repository.dart';
import 'package:family_wifi/widgets/custom_app_bar.dart';
import 'package:family_wifi/widgets/custom_button.dart';
import 'package:family_wifi/widgets/custom_edit_text.dart';
import 'package:family_wifi/widgets/custom_image_view.dart';
import 'package:family_wifi/widgets/style_helper.dart';
import 'package:flutter/material.dart';

class AddDeviceSetupScreen extends StatefulWidget {
  const AddDeviceSetupScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return MyApp.buildLoadingAlertProviders(
      child: MultiProvider(
        providers: [
          Provider<AddDeviceSetupRepository>(
            create: (_) => AddDeviceSetupRepository(context.read<ApiHelper>()),
          ),
          Provider<AddDeviceSetupProvider>(
            create: (lCtx) => AddDeviceSetupProvider(
              lCtx.read<LoadingStateProvider>(),
              lCtx.read<AlertStateProvider>(),
              lCtx.read<AddDeviceSetupRepository>(),
            ),
            dispose: (_, provider) => provider.dispose(),
          ),
        ],
        child: const AddDeviceSetupScreen(),
      ),
    );
  }

  @override
  State<AddDeviceSetupScreen> createState() => _AddDeviceSetupScreenState();
}

class _AddDeviceSetupScreenState extends State<AddDeviceSetupScreen> {
  late final AddDeviceSetupProvider controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<AddDeviceSetupProvider>(context, listen: false);
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
      child: ValueListenableProvider.value(
        value: controller.configurationState,
        child: Consumer<ConfigurationState>(
          builder:
              (BuildContext context, ConfigurationState value, Widget? child) {
                return PopScope(
                  canPop: value != ConfigurationState.CONFIGURED,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop) Navigator.pop(context, true);
                  },
                  child: Scaffold(
                    backgroundColor: appTheme.gray_900,
                    appBar: _buildAppBar(context),
                    body: _buildBody(value),
                  ),
                );
              },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'Add a device',
      hasLeading: true,
      leadingIcon: ImageConstant.imgDepth4Frame0WhiteA70024x24,
      onLeadingPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildBody(ConfigurationState state) {
    Widget bodyView;
    if (state == ConfigurationState.CONFIGURING) {
      bodyView = _buildConfiguringView();
    } else if (state == ConfigurationState.CONFIGURED) {
      bodyView = _buildConfiguredView();
    } else {
      bodyView = _buildMainView();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: bodyView,
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.0),
                _buildMainTitle(context),
                SizedBox(height: 14.0),
                _buildDescription(context),
                SizedBox(height: 22.0),
                _buildMacAddressInput(),
              ],
            ),
          ),
        ),
        _buildBottomSection(),
      ],
    );
  }

  Widget _buildMainTitle(BuildContext context) {
    return Text(
      'Connect your device',
      style: TextStyleHelper.instance.headline24BoldInter.copyWith(
        height: 1.25,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      'Connect your device to the internet and enter the MAC address below. We\'ll automatically detect it once it\'s online.',
      style: TextStyleHelper.instance.title16RegularInter.copyWith(
        color: appTheme.white_A700,
        height: 1.5,
      ),
    );
  }

  Widget _buildMacAddressInput() {
    return Form(
      key: controller.formKey,
      child: CustomEditText(
        controller: controller.macAddressController,
        hintText: 'MAC Address',
        inputType: CustomInputType.text,
        backgroundColor: appTheme.blue_gray_900,
        hasBorder: false,
        contentPadding: EdgeInsets.all(16.0),
        validator: (value) => controller.validateMacAddress(value),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: CustomButton(
        text: 'Next',
        onPressed: () => controller.onNextPressed(context),
        backgroundColor: appTheme.blue_700,
        textColor: appTheme.white_A700,
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        width: double.infinity,
      ),
    );
  }

  Widget _buildConfiguringView() {
    return Column(
      children: [
        SizedBox(height: 20.0),
        Expanded(
          child: Text(
            'Configuring the device...',
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.headline24BoldInter.copyWith(
              height: 1.25,
            ),
          ),
        ),
        LinearProgressIndicator(
          backgroundColor: appTheme.blue_gray_700,
          color: appTheme.blue_700,
          minHeight: 10.0,
          borderRadius: BorderRadius.circular(6.0),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildConfiguredView() {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              Text(
                'Device configured successfully!',
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.headline28BoldInter.copyWith(
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: CustomImageView(
                  imagePath: ImageConstant.imgDepth4Frame06,
                  fit: BoxFit.cover,
                  radius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Remove the mesh point from its current location and place it in the desired location.',
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.title16RegularInter.copyWith(
                  color: appTheme.white_A700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
        Column(
          children: [
            CustomButton(
              text: 'Done',
              onPressed: () {
                Navigator.pop(context, true);
              },
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12.0),
              backgroundColor: appTheme.blue_700,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
            ),
          ],
        ),
      ],
    );
  }
}
