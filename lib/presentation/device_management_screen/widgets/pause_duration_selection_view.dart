import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/presentation/device_management_screen/models/pause_duration_info_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_wifi/core/utils/size_utils.dart';
import 'package:family_wifi/presentation/device_management_screen/provider/pause_device_provider.dart';
import 'package:family_wifi/theme/text_style_helper.dart';
import 'package:family_wifi/theme/theme_helper.dart';
import 'package:family_wifi/widgets/custom_button.dart';

class PauseDurationSelectionView extends StatelessWidget {
  static Widget builder() {
    return ChangeNotifierProvider(
      create: (_) => PauseDeviceProvider(),
      child: PauseDurationSelectionView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),

          const SizedBox(height: 24.0),
          _buildDurationSelection(),

          const SizedBox(height: 36.0),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Pause Device',
      style: TextStyleHelper.instance.headline24BoldInter.copyWith(
        height: 1.25,
      ),
    );
  }

  Widget _buildDurationSelection() {
    return Consumer<PauseDeviceProvider>(
      builder:
          (
            BuildContext context,
            PauseDeviceProvider controller,
            Widget? child,
          ) {
            return SizedBox(
              height: 84.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.pauseDurationOptions.length,
                itemBuilder: (BuildContext context, int index) {
                  PauseDurationInfoModel durationInfo =
                      controller.pauseDurationOptions[index];
                  return OutlinedButton(
                    onPressed: () => controller.handleNewDurationSelection(
                      durationInfo.duration,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        durationInfo.label,
                        style: TextStyleHelper.instance.title16MediumInter,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: durationInfo.isSelected
                          ? appTheme.gray_900
                          : appTheme.blue_gray_900,
                      side: BorderSide(
                        width: 2.0,
                        color: durationInfo.isSelected
                            ? appTheme.indigo_200
                            : appTheme.blue_gray_900_01,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          durationInfo.isSelected ? 48.0 : 18.0,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: 16.0),
              ),
            );
          },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: NavigatorService.goBack,
          style: TextButton.styleFrom(foregroundColor: appTheme.white_A700),
          child: Text('Cancel'),
        ),
        CustomButton(
          text: 'Save',
          onPressed: () {
            NavigatorService.goBack(
              result: context.read<PauseDeviceProvider>().selectedDuration(),
            );
          },
          backgroundColor: appTheme.blue_700,
          textColor: appTheme.whiteCustom,
          fontSize: 18.fSize,
          fontWeight: FontWeight.w700,
          border: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.h),
          ),
        ),
      ],
    );
  }
}
