import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Family WiFi'**
  String get appTitle;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @signup_failed.
  ///
  /// In en, this message translates to:
  /// **'Sign up Failed'**
  String get signup_failed;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get login_failed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @unable_to_reach_server.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach server at the moment.'**
  String get unable_to_reach_server;

  /// No description provided for @out_of_coverage.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection.'**
  String get out_of_coverage;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Pls try again later.'**
  String get something_went_wrong;

  /// No description provided for @error_not_found.
  ///
  /// In en, this message translates to:
  /// **'Resource not found. Pls try again later.'**
  String get error_not_found;

  /// No description provided for @error_timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Pls try again later.'**
  String get error_timeout;

  /// No description provided for @invalid_signup_result.
  ///
  /// In en, this message translates to:
  /// **'Invalid signup response received from server.'**
  String get invalid_signup_result;

  /// No description provided for @signup_successful_title.
  ///
  /// In en, this message translates to:
  /// **'Signup Successful'**
  String get signup_successful_title;

  /// No description provided for @signup_successful_msg.
  ///
  /// In en, this message translates to:
  /// **'Your account is successfully created. Please check your email to setup password for your account.'**
  String get signup_successful_msg;

  /// No description provided for @invalid_login_result.
  ///
  /// In en, this message translates to:
  /// **'Invalid login response received from server.'**
  String get invalid_login_result;

  /// No description provided for @no_mail_app_title.
  ///
  /// In en, this message translates to:
  /// **'Open Mail App'**
  String get no_mail_app_title;

  /// No description provided for @no_mail_app_message.
  ///
  /// In en, this message translates to:
  /// **'No mail apps installed'**
  String get no_mail_app_message;

  /// No description provided for @subscribe_failed.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Failed'**
  String get subscribe_failed;

  /// No description provided for @back_to_home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get back_to_home;

  /// No description provided for @add_location.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get add_location;

  /// No description provided for @location_name.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get location_name;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @empty_location_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter location name'**
  String get empty_location_name;

  /// No description provided for @invalid_location_timezone.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid timezone'**
  String get invalid_location_timezone;

  /// No description provided for @location_setup_pending.
  ///
  /// In en, this message translates to:
  /// **'Setup your location'**
  String get location_setup_pending;

  /// No description provided for @location_setup_configuring.
  ///
  /// In en, this message translates to:
  /// **'Please wait while your location is being configured...'**
  String get location_setup_configuring;

  /// No description provided for @location_setup_configured.
  ///
  /// In en, this message translates to:
  /// **'Your location is successfully configured'**
  String get location_setup_configured;

  /// No description provided for @subscriber_location_failed.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Location Failed'**
  String get subscriber_location_failed;

  /// No description provided for @add_subscriber_location_success.
  ///
  /// In en, this message translates to:
  /// **'Location added successfully'**
  String get add_subscriber_location_success;

  /// No description provided for @add_subscriber_location_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add location'**
  String get add_subscriber_location_failed;

  /// No description provided for @topology_request_failed.
  ///
  /// In en, this message translates to:
  /// **'Topology Request Failed'**
  String get topology_request_failed;

  /// No description provided for @no_devices_activated_yet.
  ///
  /// In en, this message translates to:
  /// **'No devices activated yet.'**
  String get no_devices_activated_yet;

  /// No description provided for @edit_network_success.
  ///
  /// In en, this message translates to:
  /// **'Network settings saved successfully'**
  String get edit_network_success;

  /// No description provided for @edit_network_failed.
  ///
  /// In en, this message translates to:
  /// **'SSID/Password Update Failed'**
  String get edit_network_failed;

  /// No description provided for @invalid_response.
  ///
  /// In en, this message translates to:
  /// **'Invalid data received from server.'**
  String get invalid_response;

  /// No description provided for @add_device_success.
  ///
  /// In en, this message translates to:
  /// **'Device added successfully'**
  String get add_device_success;

  /// No description provided for @add_device_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add device'**
  String get add_device_failed;

  /// No description provided for @remove_device_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Remove Device'**
  String get remove_device_confirm_title;

  /// No description provided for @remove_device_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this device?'**
  String get remove_device_confirm_message;

  /// No description provided for @remove_device_confirm_action.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove_device_confirm_action;

  /// No description provided for @remove_device_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove device'**
  String get remove_device_failed;

  /// No description provided for @pause_device_success.
  ///
  /// In en, this message translates to:
  /// **'Device paused successfully'**
  String get pause_device_success;

  /// No description provided for @pause_device_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to pause device'**
  String get pause_device_error;

  /// No description provided for @pause_action.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause_action;

  /// No description provided for @resume_device_success.
  ///
  /// In en, this message translates to:
  /// **'Device resumed successfully'**
  String get resume_device_success;

  /// No description provided for @resume_device_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to resume device'**
  String get resume_device_error;

  /// No description provided for @resume_action.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume_action;

  /// No description provided for @resend_button.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend_button;

  /// No description provided for @resend_email_missing.
  ///
  /// In en, this message translates to:
  /// **'Email address is missing.'**
  String get resend_email_missing;

  /// No description provided for @resend_email_sent.
  ///
  /// In en, this message translates to:
  /// **'Resend email sent. Please check your inbox or spam folder.'**
  String get resend_email_sent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
