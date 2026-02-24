import 'package:family_wifi/presentation/device_management_screen/models/router_device_info_model.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_icon_button.dart';

class RouterDeviceItemView extends StatelessWidget {
  final RouterDeviceInfoModel deviceItem;
  final VoidCallback? onButtonTap;
  final Future<bool> Function()? onDeleteAction;

  const RouterDeviceItemView({
    Key? key,
    required this.deviceItem,
    this.onButtonTap,
    this.onDeleteAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showActionButton = deviceItem.actionButtonText != null;
    return wrapDismissableIfNeeded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(color: appTheme.gray_900),
        child: Row(
          children: [
            CustomIconButton(
              iconPath: deviceItem.deviceIcon,
              height: 48.h,
              width: 48.h,
              backgroundColor: appTheme.blue_gray_900,
              borderRadius: 8.h,
              padding: 12.h,
            ),
            SizedBox(width: 16.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(
                      deviceItem.deviceName,
                      style: TextStyleHelper.instance.title16MediumInter
                          .copyWith(height: 1.25),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  FittedBox(
                    child: Text(
                      deviceItem.deviceUptime,
                      style: TextStyleHelper.instance.body14RegularInter
                          .copyWith(height: 1.21),
                    ),
                  ),
                ],
              ),
            ),
            if (showActionButton) SizedBox(width: 16.h),
            if (showActionButton)
              CustomButton(
                width: 96.0,
                text: deviceItem.actionButtonText!,
                onPressed: onButtonTap,
                backgroundColor: appTheme.blue_gray_900,
                textColor: appTheme.white_A700,
                fontSize: 14.fSize,
                fontWeight: FontWeight.w500,
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              ),
          ],
        ),
      ),
    );
  }

  Widget wrapDismissableIfNeeded({required Widget child}) {
    if (onDeleteAction != null) {
      return Dismissible(
        key: ValueKey(this.deviceItem.deviceName),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => onDeleteAction!(),
        onDismissed: (direction) {},
        background: Container(
          color: appTheme.redCustom.withAlpha(180),
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
                size: 28.0,
              ),
              const SizedBox(width: 16.0),
              Text(
                'Remove',
                style: TextStyleHelper.instance.title16MediumInter,
              ),
            ],
          ),
        ),
        child: child,
      );
    }
    return child;
  }
}
