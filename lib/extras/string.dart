class Strings {
  Strings._();

  static const String appName            = 'School Konnect';
  static const String appTagline         = 'Loading your experience';

  static const String statusInitializing = 'Initializing...';
  static const String statusFetching     = 'Fetching groups...';
  static const String statusRetrying     = 'Retrying...';
  static String statusLoaded(int count)  => '$count groups loaded!';

  static const String errorTimeout       = 'Connection timed out. Check your network.';
  static const String errorNoInternet    = 'No internet connection.';
  static const String errorUnexpected    = 'Unexpected error occurred.';
  static String errorServer(int? code, dynamic data) =>
      'Server error ($code): $data';

  static const String btnRetry           = 'Retry';
  static const String tokenStorageKey           = 'auth_bearer_token';


}