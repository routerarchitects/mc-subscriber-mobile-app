import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:family_wifi/core/network/api_constants.dart';
import 'package:family_wifi/core/network/api_exception.dart';
import 'package:family_wifi/core/network/persistent_io_client.dart';
import 'package:family_wifi/core/utils/print_log_helper.dart';
import 'package:family_wifi/core/utils/shared_preferences_helper.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  late final String _hostDefault, _portAuth, _portDefault, _suffix;
  String? _hostOverride;
  String? _portOverride;
  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  late final PersistentIoClient client;

  ApiHelper() {
    if (ApiConstants.developmentMode) {
      _hostDefault = ApiConstants.baseUrlDev;
      _suffix = ApiConstants.suffixDev;
      _portAuth = ApiConstants.authPortDev;
      _portDefault = ApiConstants.defaultPortDev;
    } else {
      _hostDefault = ApiConstants.baseUrl;
      _suffix = ApiConstants.suffix;
      _portAuth = ApiConstants.authPort;
      _portDefault = ApiConstants.defaultPort;
    }
    initClient();
  }

  String get host => _hostOverride?.isNotEmpty == true ? _hostOverride! : _hostDefault;
  String? get portOverride => _portOverride;
  void setCustomHost(String? host) {
    final trimmed = host?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      _hostOverride = null;
      _portOverride = null;
      return;
    }

    final parts = trimmed.split(':');
    if (parts.length == 2) {
      _hostOverride = parts[0];
      _portOverride = parts[1];
      return;
    }

    _hostOverride = trimmed;
    _portOverride = null;
  }

  Future<void> loadCustomHost(SharedPreferencesHelper preferencesHelper) async {
    final stored = await preferencesHelper.customServerUrl;
    setCustomHost(stored);
  }

  void initClient() {
    final httpClient = HttpClient();
    httpClient.connectionTimeout = const Duration(
      seconds: ApiConstants.connectionTimeoutSec,
    );
    httpClient.idleTimeout = const Duration(
      seconds: ApiConstants.idleTimeoutSec,
    );
    client = PersistentIoClient(httpClient);
  }

  set accessToken(token) {
    client.accessToken = token;
  }

  close() {
    client.close();
  }

  Future<Map<String, dynamic>> request(
    String path, {
    RequestType requestType = RequestType.GET,
    Map<String, dynamic>? parameters,
    Object? requestBody,
    bool checkStatus = true,
    bool utf8Decode = false,
  }) async {
    if (!await check()) {
      throw ApiException('out_of_coverage', isOutOfCoverage: true);
    }
    String hostName = host;
    final overridePort = portOverride;
    if (path == ApiConstants.subscriber &&
        overridePort != null &&
        overridePort.isNotEmpty) {
      hostName += ':$overridePort';
    } else if (path == ApiConstants.login) {
      hostName += ':${_portAuth}';
    } else {
      hostName += ':${_portDefault}';
    }
    final Uri uri = Uri.https(hostName, '$_suffix$path', parameters);
    try {
      String? encodedBody;
      http.Response? response;
      logPrint('URL--->${uri.toString()}');
      switch (requestType) {
        case RequestType.GET:
          response = await client.get(uri, headers: _headers);
          break;
        case RequestType.POST:
          encodedBody = _prepareJSONEncoded(null, requestBody);
          printWrapped('Request Body--->$encodedBody');
          response = await client.post(
            uri,
            headers: _headers,
            body: encodedBody,
          );
          break;
        case RequestType.PUT:
          encodedBody = _prepareJSONEncoded(null, requestBody);
          response = await client.put(
            uri,
            headers: _headers,
            body: encodedBody,
          );
          break;
        case RequestType.DELETE:
          response = await client.delete(uri, headers: _headers);
          break;
      }
      int responseCode = response.statusCode;
      logPrint('Response Code--->$responseCode');
      dynamic json;
      if (utf8Decode) {
        Uint8List responseBodyBytes = response.bodyBytes;
        if (responseBodyBytes.isNotEmpty) {
          json = jsonDecode(utf8.decode(responseBodyBytes));
        }
      } else {
        String responseBody = response.body;
        if (responseBody.isNotEmpty) {
          json = jsonDecode(responseBody);
        }
      }
      // printWrapped('Response Body--->$json');
      printWrapped('Response Body--->${response.body}');
      if (responseCode >= 200 && responseCode < 300) {
        if (checkStatus) {
          String? errorDescription = extractErrorDescription(json);
          if (errorDescription != null) {
            throw ApiException(
              errorDescription,
              translate: false,
              data: responseCode,
            );
          } else {
            return json;
          }
        } else {
          return json ?? new Map();
        }
      } else {
        String? errorDesc = extractErrorDescription(json);
        if (errorDesc != null) {
          throw ApiException(errorDesc, translate: false, data: responseCode);
        } else {
          throw ApiException(
            handleErrorResponseCode(responseCode),
            reportToCrashlytics: true,
            data: responseCode,
          );
        }
      }
    } on HttpException catch (e, stack) {
      bool available = await check(checkActiveInternet: true);
      logPrint('Internet Available--->$available');
      throw ApiException(
        available ? 'unable_to_reach_server' : 'out_of_coverage',
        isOutOfCoverage: !available,
      );
    } on SocketException catch (e, stack) {
      bool available = await check(checkActiveInternet: true);
      logPrint('Internet Available--->$available');
      throw ApiException(
        available ? 'unable_to_reach_server' : 'out_of_coverage',
        isOutOfCoverage: !available,
      );
    } on http.ClientException catch (e, stack) {
      bool available = await check(checkActiveInternet: true);
      logPrint('Internet Available--->$available');
      throw ApiException(
        available ? 'unable_to_reach_server' : 'out_of_coverage',
        isOutOfCoverage: !available,
      );
    } on FormatException catch (e, stack) {
      bool available = await check(checkActiveInternet: true);
      logPrint('Internet Available--->$available');
      throw ApiException('something_went_wrong');
    } catch (e, stack) {
      logPrint('request: Exception--->$e');
      if (e is ApiException) {
        rethrow;
      } else {
        bool available = await check(checkActiveInternet: true);
        logPrint('Internet Available--->$available');
        throw ApiException(
          available ? 'something_went_wrong' : 'out_of_coverage',
          isOutOfCoverage: !available,
        );
      }
    }
  }

  String? extractErrorDescription(json) {
    bool errorDescAvailable =
        json != null &&
        json['ErrorCode'] != null &&
        json['ErrorDescription'] != null &&
        json['ErrorDescription'] is String &&
        (json['ErrorDescription'] as String).isNotEmpty;
    return errorDescAvailable ? json['ErrorDescription'] : null;
  }

  String? _prepareJSONEncoded(
    Map<String, dynamic>? parameters,
    Object? requestBody,
  ) {
    if (parameters != null) {
      return jsonEncode(parameters);
    } else if (requestBody != null) {
      return jsonEncode(requestBody);
    }
    return null;
  }

  static Future<bool> check({bool checkActiveInternet = false}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      if (checkActiveInternet) {
        try {
          final result = await InternetAddress.lookup(
            'google.com',
          ).timeout(const Duration(seconds: 5));
          logPrint('InternetAddress lookup result--->$result');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } on SocketException catch (_) {
          logPrint('Socket Exception while InternetAddress lookup');
          return false;
        } catch (e) {
          logPrint('Exception while InternetAddress lookup: exception--->$e');
          return false;
        }
      }
      return true;
    }
    return false;
  }
}

String handleErrorResponseCode(int responseCode) {
  switch (responseCode) {
    case 401:
    case 403:
      return 'error_unauthorised';
    case 404:
      return 'error_not_found';
    case 504:
      return 'error_timeout';
    default:
      return 'something_went_wrong';
  }
}

bool isUnauthorized(dynamic data) =>
    data != null && data is int && (data == 401 || data == 403);

bool isResourceNotFound(dynamic data) =>
    data != null && data is int && data == 404;

enum RequestType { GET, POST, PUT, DELETE }
