import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/utils/alert_state_provider.dart';
import 'package:family_wifi/core/utils/loading_state_provider.dart';
import 'package:family_wifi/core/utils/shared_preferences_helper.dart';
import 'package:family_wifi/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/single_child_widget.dart';

import 'core/app_export.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final sharedPreferencesHelper = SharedPreferencesHelper();
  final apiHelper = ApiHelper();
  await apiHelper.loadCustomHost(sharedPreferencesHelper);

  runApp(
    MyApp(
      sharedPreferencesHelper: sharedPreferencesHelper,
      apiHelper: apiHelper,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferencesHelper sharedPreferencesHelper;
  final ApiHelper apiHelper;

  const MyApp({
    super.key,
    required this.sharedPreferencesHelper,
    required this.apiHelper,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _buildProviders(),
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            title: 'Family WiFi',
            debugShowCheckedModeBanner: false,
            theme: theme,
            // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
            // 🚨 END CRITICAL SECTION
            navigatorKey: NavigatorService.navigatorKey,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            initialRoute: AppRoutes.onboardingScreen,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }

  List<SingleChildWidget> _buildProviders() {
    return [
      Provider.value(value: sharedPreferencesHelper),
      Provider.value(value: apiHelper),
    ];
  }

  static Widget buildLoadingAlertProviders({Widget? child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoadingStateProvider(false)),
        ChangeNotifierProvider(create: (_) => AlertStateProvider(false)),
      ],
      child: child,
    );
  }
}
