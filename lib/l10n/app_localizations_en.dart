// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Family WiFi';

  @override
  String get alert => 'Alert';

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';

  @override
  String get signup_failed => 'Sign up Failed';

  @override
  String get login_failed => 'Login Failed';

  @override
  String get unable_to_reach_server => 'Unable to reach server at the moment.';

  @override
  String get out_of_coverage => 'Please check your internet connection.';

  @override
  String get something_went_wrong =>
      'Something went wrong. Pls try again later.';

  @override
  String get error_not_found => 'Resource not found. Pls try again later.';

  @override
  String get error_timeout => 'Request timed out. Pls try again later.';

  @override
  String get invalid_signup_result =>
      'Invalid signup response received from server.';

  @override
  String get signup_successful_title => 'Signup Successful';

  @override
  String get signup_successful_msg =>
      'Your account is successfully created. Please check your email to setup password for your account.';

  @override
  String get invalid_login_result =>
      'Invalid login response received from server.';

  @override
  String get no_mail_app_title => 'Open Mail App';

  @override
  String get no_mail_app_message => 'No mail apps installed';

  @override
  String get subscribe_failed => 'Subscribe Failed';

  @override
  String get topology_request_failed => 'Topology Request Failed';

  @override
  String get edit_network_success => 'Network settings saved successfully';

  @override
  String get edit_network_failed => 'SSID/Password Update Failed';

  @override
  String get invalid_response => 'Invalid data received from server.';

  @override
  String get add_device_success => 'Device added successfully';

  @override
  String get add_device_failed => 'Failed to add device';

  @override
  String get remove_device_confirm_title => 'Remove Device';

  @override
  String get remove_device_confirm_message =>
      'Are you sure you want to remove this device?';

  @override
  String get remove_device_confirm_action => 'Remove';

  @override
  String get remove_device_failed => 'Failed to remove device';

  @override
  String get pause_device_success => 'Device paused successfully';

  @override
  String get pause_device_error => 'Failed to pause device';

  @override
  String get resume_device_success => 'Device resumed successfully';

  @override
  String get resume_device_error => 'Failed to resume device';
}
