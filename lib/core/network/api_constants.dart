class ApiConstants {
  static const String baseUrlDev = 'openwifi3.routerarchitects.com';
  static const String suffixDev = 'api/v1/';
  static const String authPortDev = '16001';
  static const String defaultPortDev = '16006';

  static const String baseUrl = 'openwifi.routerarchitects.com';
  static const String suffix = 'api/v1/';
  static const String authPort = '16001';
  static const String defaultPort = '16006';

  static const String signup = 'signup';
  static const String login = 'suboauth2';
  static const String subscriber = 'subscriber';
  static const String subscriberLocation = subscriber + '/location';
  static const String topology = 'topology';
  static const String action = 'action';
  static const String actionConfigure = 'configure';
  static const String manageDevice = subscriber + '/devices/';

  static const int connectionTimeoutSec = 30;
  static const int idleTimeoutSec = 90;

  static const bool developmentMode = true;
}
