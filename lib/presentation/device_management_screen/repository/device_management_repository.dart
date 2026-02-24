import 'dart:async';

import 'package:family_wifi/core/network/api_constants.dart';
import 'package:family_wifi/core/network/api_exception.dart';
import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/network/common/configure_payload.dart';
import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/print_log_helper.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';

class DeviceManagementRepository {
  late final ApiHelper _apiHelper;

  DeviceManagementRepository(ApiHelper apiHelper) {
    this._apiHelper = apiHelper;
  }

  Future<Result> deleteDevice(String macAddress) async {
    try {
      await _apiHelper.request(
        '${ApiConstants.manageDevice}${macAddress}',
        requestType: RequestType.DELETE,
        checkStatus: false,
      );
      // if (result['Code'] != null) {
      //   return Result.success(true);
      // } else {
      //   return Result.error(
      //     await result['description'] ?? 'invalid_response'.tr(),
      //   );
      // }
      return Result.success(true);
    } catch (error, stack) {
      logPrint('$error, \n$stack');
      return handleApiException(error);
    }
  }

  Future<Result> pauseResumeDevice(String macAddress, bool pause) async {
    try {
      Map<String, dynamic> result = await _apiHelper.request(
        ApiConstants.action,
        requestType: RequestType.POST,
        parameters: {'action': ApiConstants.actionConfigure},
        requestBody: ConfigurePayload(
          clientItems: [
            ClientItem(mac: macAddress, access: pause ? 'deny' : 'allow'),
          ],
        ),
      );
      if (result['Code'] != null) {
        return Result.success(true);
      } else {
        return Result.error(await result['Details'] ?? 'invalid_response'.tr());
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
