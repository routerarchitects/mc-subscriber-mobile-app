import 'dart:async';

import 'package:family_wifi/core/network/api_constants.dart';
import 'package:family_wifi/core/network/api_exception.dart';
import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/network/common/configure_payload.dart';
import 'package:family_wifi/core/network/result.dart';
import 'package:family_wifi/core/utils/print_log_helper.dart';
import 'package:family_wifi/core/utils/shared_preferences_helper.dart';
import 'package:family_wifi/l10n/app_localization_extension.dart';
import 'package:family_wifi/presentation/edit_network_screen/models/edit_network_model.dart';
import 'package:family_wifi/presentation/login_screen/models/login_result.dart';

class EditNetworkRepository {
  late final ApiHelper _apiHelper;
  late final SharedPreferencesHelper _sharedPreferencesHelper;

  EditNetworkRepository(
    ApiHelper apiHelper,
    SharedPreferencesHelper sharedPreferencesHelper,
  ) {
    this._apiHelper = apiHelper;
    this._sharedPreferencesHelper = sharedPreferencesHelper;
  }

  Future<Result> editNetwork(EditNetworkModel editNetworkModel) async {
    try {
      Map<String, dynamic> result = await _apiHelper.request(
        ApiConstants.action,
        requestType: RequestType.POST,
        parameters: {'action': ApiConstants.actionConfigure},
        requestBody: ConfigurePayload(
          editNetworkItem: EditNetworkItem(
            name: editNetworkModel.ssid,
            password: editNetworkModel.password,
          ),
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

  Future<void> saveAccessToken(accessToken) async {
    _apiHelper.accessToken = accessToken;
    return _sharedPreferencesHelper.setAccessToken(accessToken);
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
