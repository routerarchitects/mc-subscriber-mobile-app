import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/presentation/device_management_screen/repository/device_management_repository.dart';
import 'package:family_wifi/presentation/device_management_screen/widgets/mobile_devices_tab.dart';
import 'package:family_wifi/presentation/device_management_screen/widgets/router_mesh_devices_tab.dart';
import 'package:family_wifi/presentation/home_screen/models/topology_info.dart';
import 'package:family_wifi/presentation/home_screen/provider/home_provider.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './provider/device_management_provider.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    final homeController = Provider.of<HomeProvider>(context, listen: false);
    return ProxyProvider<ApiHelper, DeviceManagementRepository>(
      update: (_, apiHelper, addDeviceRepo) {
        return addDeviceRepo ?? DeviceManagementRepository(apiHelper);
      },
      child: ValueListenableProvider<TopologyInfo?>.value(
        value: homeController.topologyInfo,
        child:
            ProxyProvider2<
              TopologyInfo?,
              DeviceManagementRepository,
              DeviceManagementProvider
            >(
              update:
                  (
                    BuildContext context,
                    TopologyInfo? topologyInfo,
                    DeviceManagementRepository repository,
                    DeviceManagementProvider? previous,
                  ) {
                    final deviceMngmtProvider =
                        previous ??
                        DeviceManagementProvider(
                          homeController.loadingStateProvider,
                          homeController.alertStateProvider,
                          repository,
                        );
                    deviceMngmtProvider.handleTopologyInfo(topologyInfo);
                    return deviceMngmtProvider;
                  },
              child: const DeviceManagementScreen(),
            ),
      ),
    );
  }

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen>
    with TickerProviderStateMixin {
  late final HomeProvider homeController;
  late final DeviceManagementProvider deviceManagementProvider;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    homeController = Provider.of<HomeProvider>(context, listen: false);
    deviceManagementProvider = Provider.of<DeviceManagementProvider>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    deviceManagementProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      // Customize which scroll notifications the RefreshIndicator listens to.
      notificationPredicate: (notification) {
        // return notification.depth == 2; // Common solution for TabBarView
        // A more general solution to allow the outer scroll view to trigger the refresh
        return notification.depth == 2;
      },
      key: deviceManagementProvider.refreshIndicatorKey,
      onRefresh: () => homeController.fetchTopologyInfo(),
      child: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [SliverToBoxAdapter(child: _buildTabSection())];
        },
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: _buildTabContent(),
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: appTheme.blue_gray_700, width: 1.h),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: appTheme.white_A700, width: 2.h),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: appTheme.white_A700,
        unselectedLabelColor: appTheme.indigo_200,
        labelStyle: TextStyleHelper.instance.body14BoldInter,
        unselectedLabelStyle: TextStyleHelper.instance.body14BoldInter,
        tabs: [
          Tab(text: 'Mobile devices'),
          Tab(text: 'Router/mesh devices'),
        ],
        onTap: (index) {
          _tabController.animateTo(index);
        },
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [MobileDevicesTab(), RouterMeshDevicesTab()],
    );
  }
}
