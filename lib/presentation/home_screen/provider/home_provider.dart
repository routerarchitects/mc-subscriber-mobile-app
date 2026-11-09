import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/base_bloc.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/core/utils/print_log_helper.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/home_screen/bottom_bar_item.dart';
import 'package:family_wifi/presentation/subscriber_location/models/subscriber_location.dart';
import 'package:family_wifi/presentation/home_screen/models/topology_info.dart';
import 'package:family_wifi/presentation/home_screen/repository/home_repository.dart';
import 'package:family_wifi/presentation/subscriber_location/repository/subscriber_location_repository.dart';
import 'package:family_wifi/routes/app_routes.dart';
import 'package:flutter/material.dart';

class HomeProvider with BaseBloc {
  late final HomeRepository _repository;
  late final SubscriberLocationRepository _subsLocationRepository;
  final PageController pageController = PageController(initialPage: 0);

  final ValueNotifier<BottomBarItem> selectedNavBarItem =
      ValueNotifier<BottomBarItem>(NAV_BOTTOM_BAR_ITEMS[0]);

  final ValueNotifier<TopologyInfo?> topologyInfo =
      ValueNotifier<TopologyInfo?>(null);

  HomeProvider(
    LoadingStateProvider loadingStateProvider,
    AlertStateProvider alertStateProvider,
    this._repository,
    this._subsLocationRepository,
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
    topologyInfo.dispose();
  }

  void init() {
    fetchLatestData();
  }

  Future<bool> shouldAskSubscriberLocation() async {
    startLoading();
    bool askSubscriberLocation = false;
    try {
      askSubscriberLocation = await checkSubscriberLocation() == null;
      dismissLoading();
    } catch (error) {
      dismissLoading();
      showAlert(
        error.toString(),
        title: await 'subscriber_location_failed'.tr(),
      );
    }

    return askSubscriberLocation;
  }

  Future<SubscriberLocation?> checkSubscriberLocation() async {
    try {
      Result result = await _subsLocationRepository.fetchSubscriberLocation();
      if (result.isSuccess) {
        return result.message;
      } else if (result.sessionExpired) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginScreen);
      } else if (!result.resourceNotFound) {
        throw Exception(result.message);
      }
    } catch (error) {
      logPrint(error);
      throw error;
    }

    return null;
  }

  Future<void> fetchLatestData({bool showPopupLoader = true}) async {
    await fetchTopologyInfo();
  }

  Future<void> fetchTopologyInfo() async {
    try {
      Result result = await _repository.topology();

      if (result.isSuccess) {
        final TopologyInfo? topology = result.message;
        if (topology == null || (topology.nodes?.isEmpty ?? true)) {
          topologyInfo.value = null;
          showAlert(await 'no_devices_activated_yet'.tr());
          return;
        }
        topologyInfo.value = topology;
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
