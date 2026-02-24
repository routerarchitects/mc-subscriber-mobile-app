import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_icon_button.dart';
import '../models/mobile_device_info_model.dart';

class MobileDeviceItemView extends StatelessWidget {
  final MobileDeviceInfoModel device;
  final VoidCallback? onIconTap;
  final VoidCallback? onPauseTap;

  const MobileDeviceItemView({
    Key? key,
    required this.device,
    this.onIconTap,
    this.onPauseTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: device.isHistoricalDevice ? Colors.grey[700] : appTheme.gray_900,
      ),
      child: Row(
        spacing: 16.h,
        children: [
          CustomIconButton(
            iconPath: device.iconPath,
            onTap: onIconTap,
            height: 48.h,
            width: 48.h,
            backgroundColor: device.isHistoricalDevice
                ? Colors.grey
                : appTheme.blue_gray_900,
            borderRadius: 8.h,
          ),
          Expanded(
            child: Column(
              spacing: 4.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    device.deviceName,
                    style: TextStyleHelper.instance.title16MediumInter,
                  ),
                ),
                if (!device.isHistoricalDevice)
                  FittedBox(
                    child: Text(
                      '${device.uploadSpeed} ${device.downloadSpeed}',
                      style: TextStyleHelper.instance.body14RegularInter,
                    ),
                  ),
              ],
            ),
          ),
          if (device.isPauseResumeInProgress)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                height: 20.h,
                width: 20.h,
                child: CircularProgressIndicator(color: appTheme.white_A700),
              ),
            )
          else
            CustomButton(
              width: 84.0,
              text: device.isPaused ? 'Resume' : 'Pause',
              onPressed: onPauseTap,
              backgroundColor: device.isHistoricalDevice
                  ? Colors.grey
                  : appTheme.blue_gray_900,
              fontSize: 14.fSize,
              fontWeight: FontWeight.w500,
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            ),
        ],
      ),
    );
  }
}
