import 'package:family_wifi/core/utils/action_result.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/core/utils/size_utils.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/subscriber_location/provider/subscriber_location_provider.dart';
import 'package:family_wifi/presentation/subscriber_location/repository/subscriber_location_repository.dart';
import 'package:family_wifi/theme/text_style_helper.dart';
import 'package:family_wifi/theme/theme_helper.dart';
import 'package:family_wifi/widgets/custom_button.dart';
import 'package:family_wifi/widgets/style_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSubscriberLocation extends StatefulWidget {
  const AddSubscriberLocation({super.key});

  static Widget builder(BuildContext context) {
    return Provider<SubscriberLocationProvider>(
      create: (lCtx) =>
          SubscriberLocationProvider(lCtx.read<SubscriberLocationRepository>()),
      dispose: (_, provider) => provider.dispose(),
      child: const AddSubscriberLocation(),
    );
  }

  @override
  State<AddSubscriberLocation> createState() => _AddSubscriberLocationState();
}

class _AddSubscriberLocationState extends State<AddSubscriberLocation> {
  late final SubscriberLocationProvider controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<SubscriberLocationProvider>(
      context,
      listen: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appTheme.gray_900,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ValueListenableProvider<ConfigurationState>.value(
        value: controller.configurationState,
        child: Consumer<ConfigurationState>(
          builder:
              (BuildContext context, ConfigurationState state, Widget? child) {
                bool isPending = state == ConfigurationState.PENDING;
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.0),
                            _buildMainTitle(state),

                            SizedBox(height: 24.h),
                            _buildLocationNameInput(isPending),
                            SizedBox(height: 20.h),
                            _buildTimezoneInput(isPending),
                          ],
                        ),
                      ),
                    ),
                    if (state == ConfigurationState.CONFIGURING)
                      _buildInProgressView()
                    else if (state == ConfigurationState.CONFIGURED)
                      _buildBackToHomeButton()
                    else
                      _buildAddLocationButton(),
                  ],
                );
              },
        ),
      ),
    );
  }

  Widget _buildMainTitle(ConfigurationState state) {
    String title = context.translator.location_setup_pending;
    if (state == ConfigurationState.CONFIGURING) {
      title = context.translator.location_setup_configuring;
    } else if (state == ConfigurationState.CONFIGURED) {
      title = context.translator.location_setup_configured;
    }
    return Text(
      title,
      style: TextStyleHelper.instance.headline24BoldInter.copyWith(
        height: 1.25,
      ),
    );
  }

  Widget _buildLocationNameInput(bool isPending) {
    return ValueListenableProvider<String?>.value(
      value: controller.locationError,
      child: Consumer<String?>(
        builder: (BuildContext context, String? error, Widget? child) {
          return _buildTextInput(
            controller.locationNameController,
            hintText: context.translator.location_name,
            onValueChange: controller.onLocationNameChanged,
            errorText: error,
            enabled: isPending,
          );
        },
      ),
    );
  }

  Widget _buildTimezoneInput(bool isPending) {
    return TextFieldTapRegion(
      onTapOutside: (PointerDownEvent event) {
        FocusScope.of(context).unfocus();
      },
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue tev) {
          if (tev.text.isEmpty) {
            return controller.timezones();
          }
          return controller.timezones().where(
            (option) => option.toLowerCase().contains(tev.text.toLowerCase()),
          );
        },
        fieldViewBuilder:
            (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return ValueListenableProvider<String?>.value(
                value: controller.timezoneError,
                child: Consumer<String?>(
                  builder:
                      (BuildContext context, String? value, Widget? child) {
                        return _buildTextInput(
                          textEditingController,
                          hintText: context.translator.timezone,
                          onValueChange: controller.onTimezoneSelected,
                          focusNode: focusNode,
                          errorText: value,
                          enabled: isPending,
                        );
                      },
                ),
              );
            },
        optionsViewBuilder:
            (
              BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options,
            ) {
              final double maxDropdownHeight =
                  MediaQuery.of(context).size.height * 0.28;
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxDropdownHeight),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 0.5, color: appTheme.gray_900),
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return ListTile(
                          title: Text(
                            option,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey,
                            ),
                          ),
                          tileColor: Colors.white,
                          hoverColor: appTheme.blue_gray_900,
                          contentPadding: EdgeInsetsDirectional.symmetric(
                            horizontal: 20.0,
                          ),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
        onSelected: (String value) => controller.onTimezoneSelected(value),
      ),
    );
  }

  Widget _buildTextInput(
    TextEditingController textEditingController, {
    String? hintText,
    FocusNode? focusNode,
    ValueChanged<String>? onValueChange,
    String? errorText,
    bool enabled = true,
  }) {
    return TextField(
      controller: textEditingController,
      focusNode: focusNode,
      enabled: enabled,
      onChanged: onValueChange,
      style: TextStyleHelper.instance.title16RegularInter.copyWith(
        color: appTheme.indigo_200,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyleHelper.instance.title16RegularInter.copyWith(
          color: appTheme.indigo_200,
          height: 1.5,
        ),
        errorText: errorText,
        filled: true,
        fillColor: appTheme.blue_gray_900,
        contentPadding: EdgeInsets.all(16.0),
        border: _buildBorder(),
        enabledBorder: _buildBorder(),
        focusedBorder: _buildBorder(),
        errorBorder: _buildBorder(isError: true),
        focusedErrorBorder: _buildBorder(isError: true),
      ),
    );
  }

  InputBorder _buildBorder({bool isError = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.h),
      borderSide: isError
          ? BorderSide(color: appTheme.redCustom, width: 1.0)
          : BorderSide.none,
    );
  }

  Widget _buildAddLocationButton() {
    return CustomButton(
      text: context.translator.add_location,
      onPressed: addLocationHandler,
      backgroundColor: appTheme.blue_700,
      textColor: appTheme.whiteCustom,
      fontSize: 16.fSize,
      fontWeight: FontWeight.w700,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
    );
  }

  Widget _buildInProgressView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: LinearProgressIndicator(
        backgroundColor: appTheme.blue_gray_700,
        color: appTheme.blue_700,
        minHeight: 10.0,
        borderRadius: BorderRadius.circular(6.0),
      ),
    );
  }

  Future<void> addLocationHandler() async {
    ActionResult? result = await controller.addLocation();
    if (result != null) {
      if (result.isSuccess) {
        SnackBar(
          content: Text(context.translator.add_subscriber_location_success),
          backgroundColor: appTheme.colorFF4CAF,
        );
      } else if (result.errorMessage != null) {
        StyleHelper.showAlertDialog(
          context,
          result.errorMessage!,
          context.translator.ok,
          title: context.translator.add_subscriber_location_failed,
        );
      }
    }
  }

  Widget _buildBackToHomeButton() {
    return CustomButton(
      text: context.translator.back_to_home,
      onPressed: () {
        NavigatorService.goBack(result: true);
      },
      backgroundColor: appTheme.blue_700,
      textColor: appTheme.whiteCustom,
      fontSize: 16.fSize,
      fontWeight: FontWeight.w700,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
    );
  }
}
