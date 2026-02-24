import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/base_bloc.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/home_screen/bottom_bar_item.dart';
import 'package:family_wifi/presentation/home_screen/models/subscriber_info.dart';
import 'package:family_wifi/presentation/home_screen/models/topology_info.dart';
import 'package:family_wifi/presentation/home_screen/repository/home_repository.dart';
import 'package:family_wifi/routes/app_routes.dart';
import 'package:flutter/material.dart';

class HomeProvider with BaseBloc {
  late final HomeRepository _repository;
  final PageController pageController = PageController(initialPage: 0);

  final ValueNotifier<BottomBarItem> selectedNavBarItem =
      ValueNotifier<BottomBarItem>(NAV_BOTTOM_BAR_ITEMS[0]);

  final ValueNotifier<SubscriberInfo?> subscriberInfo =
      ValueNotifier<SubscriberInfo?>(null);

  final ValueNotifier<TopologyInfo?> topologyInfo =
      ValueNotifier<TopologyInfo?>(null);

  HomeProvider(
    LoadingStateProvider loadingStateProvider,
    AlertStateProvider alertStateProvider,
    this._repository,
  ) {
    initialize(loadingStateProvider, alertStateProvider);
  }

  void onNavBarItemSelected(index) {
    selectedNavBarItem.value = NAV_BOTTOM_BAR_ITEMS.firstWhere(
      (item) => item.index == index,
    );
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    selectedNavBarItem.dispose();
    subscriberInfo.dispose();
    super.dispose();
  }

  void init() {
    fetchLatestData();
  }

  Future<void> fetchLatestData({bool showPopupLoader = true}) async {
    await initialSubscribe(showPopupLoader: showPopupLoader);
    if (subscriberInfo.value != null) {
      fetchTopologyInfo();
    }
  }

  Future<void> initialSubscribe({bool showPopupLoader = true}) async {
    if (showPopupLoader) startLoading();

    try {
      Result result = await _repository.subscriber();

      if (showPopupLoader) dismissLoading();
      if (result.isSuccess) {
        subscriberInfo.value = result.message;
      } else if (result.sessionExpired) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
      } else {
        showAlert(result.message, title: await 'subscribe_failed'.tr());
      }
    } catch (error) {
      dismissLoading();
    }
  }

  Future<void> fetchTopologyInfo() async {
    try {
      Result result = await _repository.topology();

      if (result.isSuccess) {
        topologyInfo.value = result.message;
      } else if (result.sessionExpired) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
      } else {
        showAlert(result.message, title: await 'topology_request_failed'.tr());
      }
    } catch (error) {
      dismissLoading();
    }
  }
}
