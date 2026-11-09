import 'package:family_wifi/core/app_export.dart';
import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/main.dart';
import 'package:family_wifi/presentation/device_management_screen/device_management_screen.dart';
import 'package:family_wifi/presentation/home_screen/bottom_bar_item.dart';
import 'package:family_wifi/presentation/home_screen/provider/home_provider.dart';
import 'package:family_wifi/presentation/home_screen/repository/home_repository.dart';
import 'package:family_wifi/presentation/subscriber_location/add_subscriber_location.dart';
import 'package:family_wifi/presentation/subscriber_location/repository/subscriber_location_repository.dart';
import 'package:family_wifi/presentation/network_dashboard_screen/network_dashboard_screen.dart';
import 'package:family_wifi/presentation/setting_screen/setting_screen.dart';
import 'package:family_wifi/widgets/custom_app_bar.dart';
import 'package:family_wifi/widgets/custom_image_view.dart';
import 'package:family_wifi/widgets/style_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Widget builder(BuildContext context) {
    return MyApp.buildLoadingAlertProviders(
      child: MultiProvider(
        providers: [
          Provider<HomeRepository>(
            create: (_) => HomeRepository(context.read<ApiHelper>()),
          ),
          Provider<SubscriberLocationRepository>(
            create: (_) =>
                SubscriberLocationRepository(context.read<ApiHelper>()),
          ),
          Provider<HomeProvider>(
            create: (lCtx) => HomeProvider(
              lCtx.read<LoadingStateProvider>(),
              lCtx.read<AlertStateProvider>(),
              lCtx.read<HomeRepository>(),
              lCtx.read<SubscriberLocationRepository>(),
            ),
            dispose: (_, provider) => provider.dispose(),
          ),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final HomeProvider controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<HomeProvider>(context, listen: false);
    controller.loadingStateProvider.addListener(handleLoadingState);
    controller.alertStateProvider.addListener(handleAlertState);
    WidgetsBinding.instance.addPostFrameCallback(postFrameCallback);
  }

  Future<void> postFrameCallback(Duration duration) async {
    bool showSubscriberLocationPopup = await controller
        .shouldAskSubscriberLocation();
    if (showSubscriberLocationPopup) {
      dynamic result = await StyleHelper.showAdaptiveBottomSheet(
        context,
        child: Provider.value(
          value: context.read<SubscriberLocationRepository>(),
          child: AddSubscriberLocation.builder(context),
        ),
      );
      if (result == true) {
        controller.init();
      }
    } else {
      controller.init();
    }
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
        value: controller.selectedNavBarItem,
        child: Consumer<BottomBarItem>(
          builder: (BuildContext context, BottomBarItem value, Widget? child) {
            return PopScope(
              canPop: value.index == 0,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) controller.onNavBarItemSelected(0);
              },
              child: Scaffold(
                backgroundColor: appTheme.gray_900,
                appBar: _buildCustomAppBar(value),
                body: _buildBody(),
                bottomNavigationBar: _buildBottomNavigationBar(value),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BottomBarItem selectedBottomBar) {
    return CustomAppBar(
      title: selectedBottomBar.appBarTitle,
      centerTitle: true,
      hasLeading: selectedBottomBar.appBarHasLeading,
      leadingIcon: ImageConstant.imgDepth4Frame0WhiteA700,
      onLeadingPressed: () => controller.onNavBarItemSelected(0),
      backgroundColor: appTheme.gray_900,
      titleColor: appTheme.white_A700,
      actions: selectedBottomBar.appBarHasTrailing
          ? [_buildSettingAppBarAction()]
          : null,
    );
  }

  Widget _buildSettingAppBarAction() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: CustomImageView(
        imagePath: ImageConstant.imgDepth3Frame1,
        height: 48.h,
        width: 48.h,
      ),
    );
  }

  Widget _buildBody() {
    return PageView(
      controller: controller.pageController,
      children: [
        NetworkDashboardScreen.builder(context),
        DeviceManagementScreen.builder(context),
        SettingScreen.builder(context),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BottomBarItem selectedBottomBar) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: appTheme.blue_gray_900, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedBottomBar.index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: appTheme.blue_gray_900_01,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFF91ADC9),
        selectedLabelStyle: TextStyleHelper.instance.bodyTextInter.copyWith(
          height: 1.25,
        ),
        unselectedLabelStyle: TextStyleHelper.instance.bodyTextInter.copyWith(
          fontSize: 12,
          height: 1.25,
        ),
        onTap: (index) {
          controller.onNavBarItemSelected(index);
        },
        items: List.generate(NAV_BOTTOM_BAR_ITEMS.length, (index) {
          BottomBarItem bottomBarItem = NAV_BOTTOM_BAR_ITEMS[index];
          return buildBottomBarItem(
            bottomBarItem.label,
            bottomBarItem.icon,
            bottomBarItem.index == selectedBottomBar.index,
          );
        }),
      ),
    );
  }

  BottomNavigationBarItem buildBottomBarItem(
    String label,
    String imagePath,
    bool selected,
  ) {
    return BottomNavigationBarItem(
      icon: CustomImageView(
        imagePath: imagePath,
        height: 24.h,
        width: 24.h,
        color: selected ? Colors.white : appTheme.indigo_200,
      ),
      label: label,
    );
  }
}
