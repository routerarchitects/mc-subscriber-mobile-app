import 'dart:async';

import 'package:family_wifi/core/network/api_constants.dart';
import 'package:family_wifi/core/network/api_exception.dart';
import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/print_log_helper.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/home_screen/models/subscriber_info.dart';
import 'package:family_wifi/presentation/home_screen/models/topology_info.dart';

class HomeRepository {
  late final ApiHelper _apiHelper;

  HomeRepository(ApiHelper apiHelper) {
    this._apiHelper = apiHelper;
  }

  Future<Result> subscriber() async {
    try {
      Map<String, dynamic> result = await _apiHelper.request(
        ApiConstants.subscriber,
        requestType: RequestType.GET,
      );
      SubscriberInfo subscriberInfo = SubscriberInfo.fromJson(result);
      return Result.success(subscriberInfo);
    } catch (error, stack) {
      logPrint('$error, \n$stack');
      return handleApiException(error);
    }
  }

  Future<Result> topology() async {
    try {
      Map<String, dynamic> result = await _apiHelper.request(
        ApiConstants.topology,
        requestType: RequestType.GET,
        // parameters: {'boardId': '5591dbe0-f836-4a92-83a2-d5c0b75b10a'},
        // parameters: {'boardId': '28bd72da-8ae7-45ed-9af3-b56d386311e'},
      );
      TopologyInfo topologyInfo = TopologyInfo.fromJson(result);
      return Result.success(topologyInfo);
    } catch (error, stack) {
      logPrint('$error, \n$stack');
      return handleApiException(error);
    }
  }

  Future<Result> handleApiException(dynamic exception) async {
    if (exception is ApiException) {
      String errorMsg = exception.translate
          ? await exception.message.tr()
          : exception.message;
      if (isUnauthorized(exception.data)) {
        return Result.error(errorMsg, sessionExpired: true);
      }
      return Result.error(errorMsg);
    } else if (exception is TimeoutException) {
      bool available = await ApiHelper.check(checkActiveInternet: true);
      return Result.error(
        available
            ? await 'unable_to_reach_server'.tr()
            : await 'out_of_coverage'.tr(),
      );
    } else {
      return Result.error(await 'something_went_wrong'.tr());
    }
  }
}
