import 'dart:convert';

import 'package:family_wifi/core/utils/navigator_service.dart';
import 'package:family_wifi/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get translator {
    return AppLocalizations.of(this)!;
  }
}

AppLocalizations? get globalAppLoc {
  if (NavigatorService.navigatorKey.currentContext != null) {
    return AppLocalizations.of(NavigatorService.navigatorKey.currentContext!);
  }
  return null;
}

extension TranslateStringExtension on String {
  Future<String> tr({Map<String, dynamic>? placeholders}) async {
    AppLocalizations? appLocalizations = globalAppLoc;
    if (appLocalizations != null) {
      String localeName = appLocalizations.localeName;
      String arbContent = await rootBundle.loadString(
        'lib/l10n/app_$localeName.arb',
      );
      final contentMap = jsonDecode(arbContent) as Map<String, dynamic>;
      String content = contentMap[this];
      if (placeholders?.isEmpty ?? true) {
        return content;
      } else {
        final regex = RegExp(r'\{(\w+)\}');
        return content.replaceAllMapped(regex, (match) {
          return placeholders![match.group(1)] ?? match.group(0);
        });
      }
    }
    return 'translate_error';
  }
}
