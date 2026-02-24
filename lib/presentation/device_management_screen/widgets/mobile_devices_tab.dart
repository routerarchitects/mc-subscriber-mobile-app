import 'package:family_wifi/presentation/device_management_screen/models/mobile_device_info_model.dart';
import 'package:family_wifi/presentation/device_management_screen/provider/device_management_provider.dart';
import 'package:family_wifi/presentation/device_management_screen/widgets/mobile_device_item_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileDevicesTab extends StatelessWidget {
  late final bool shrinkWrap;
  MobileDevicesTab({super.key, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<DeviceManagementProvider>();
    return _buildMobileDevicesList(controller);
  }

  Widget _buildMobileDevicesList(
    DeviceManagementProvider deviceMngmtController,
  ) {
    return StreamProvider<List<MobileDeviceInfoModel>?>.value(
      initialData: deviceMngmtController.mobileDevicesInitialData,
      value: deviceMngmtController.mobileDevices,
      child: Consumer<List<MobileDeviceInfoModel>?>(
        builder:
            (
              BuildContext context,
              List<MobileDeviceInfoModel>? value,
              Widget? child,
            ) {
              final itemCount = value?.length ?? 0;
              final items = value ?? [];
              return ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                shrinkWrap: shrinkWrap,
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return MobileDeviceItemView(
                    device: items[index],
                    /*onIconTap: () {
                        NavigatorService.pushNamed(
                          AppRoutes.networkDevicesManagementScreen,
                        );
                      },*/
                    onPauseTap: () {
                      deviceMngmtController.toggleDevicePause(
                        items[index],
                        context,
                      );
                    },
                  );
                },
              );
            },
      ),
    );
  }
}
