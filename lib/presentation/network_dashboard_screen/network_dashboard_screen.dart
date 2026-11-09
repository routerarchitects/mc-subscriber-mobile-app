import 'package:family_wifi/presentation/home_screen/models/topology_info.dart'
    hide Node;
import 'package:family_wifi/presentation/home_screen/provider/home_provider.dart';
import 'package:family_wifi/presentation/network_dashboard_screen/widgets/dashboard_overview_tab.dart';
import 'package:family_wifi/presentation/network_health_screen/network_health_screen_initial_page.dart';
import 'package:family_wifi/presentation/network_health_screen/provider/network_health_provider.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './provider/network_dashboard_provider.dart';

class NetworkDashboardScreen extends StatefulWidget {
  const NetworkDashboardScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    final homeController = context.read<HomeProvider>();
    return ValueListenableProvider<TopologyInfo?>.value(
      value: homeController.topologyInfo,
      child: ProxyProvider<TopologyInfo?, NetworkDashboardProvider>(
        update:
            (
              BuildContext context,
              TopologyInfo? topologyInfo,
              NetworkDashboardProvider? previous,
            ) {
              final netProvider = previous ?? NetworkDashboardProvider();
              netProvider.handleTopologyInfo(topologyInfo);
              return netProvider;
            },
        dispose: (_, provider) => provider.dispose(),
        child: const NetworkDashboardScreen(),
      ),
    );
  }

  @override
  State<NetworkDashboardScreen> createState() => _NetworkDashboardScreenState();
}

class _NetworkDashboardScreenState extends State<NetworkDashboardScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
      key: context.read<NetworkDashboardProvider>().refreshIndicatorKey,
      onRefresh: () =>
          context.read<HomeProvider>().fetchLatestData(showPopupLoader: false),
      child: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [SliverToBoxAdapter(child: _buildTabSection())];
        },
        body: _buildTabContent(),
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
          Tab(text: 'Overview'),
          Tab(text: 'Health'),
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
      children: [
        DashboardOverviewTab(),
        ChangeNotifierProvider(
          create: (context) => NetworkHealthProvider(),
          child: NetworkHealthScreenInitialPage(),
        ),
      ],
    );
  }
}
