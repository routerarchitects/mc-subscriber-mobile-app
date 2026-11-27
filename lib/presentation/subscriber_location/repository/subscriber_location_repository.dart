import 'dart:async';

import 'package:family_wifi/core/network/api_constants.dart';
import 'package:family_wifi/core/network/api_exception.dart';
import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/print_log_helper.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/subscriber_location/models/subscriber_location.dart';

class SubscriberLocationRepository {
  late final ApiHelper _apiHelper;

  SubscriberLocationRepository(ApiHelper apiHelper) {
    this._apiHelper = apiHelper;
  }

  Future<Result> fetchSubscriberLocation() async {
    try {
      Map<String, dynamic> result = await _apiHelper.request(
        ApiConstants.subscriberLocation,
        requestType: RequestType.GET,
      );
      SubscriberLocation subscriberLocation = SubscriberLocation.fromJson(
        result,
      );
      return Result.success(subscriberLocation);
    } catch (error, stack) {
      logPrint('$error, \n$stack');
      return handleApiException(error);
    }
  }

  Future<Result> addSubscriberLocation(String name, String timezone) async {
    try {
      Map<String, dynamic> result = await _apiHelper.request(
        ApiConstants.subscriberLocation,
        requestType: RequestType.POST,
        requestBody: SubscriberLocation(name: name, timezone: timezone),
      );
      if (result['Code'] != null) {
        return Result.success(true);
      } else {
        return Result.error(
          await result['description'] ?? 'invalid_response'.tr(),
        );
      }
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

      bool sessionExpired = isUnauthorized(exception.data);
      bool resourceNotFound = isResourceNotFound(exception.data);
      return Result.error(
        errorMsg,
        sessionExpired: sessionExpired,
        resourceNotFound: resourceNotFound,
      );
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
