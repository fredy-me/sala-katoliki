import '../core/constants/app_constants.dart';
import 'environment.dart';

class AppConfig {
  const AppConfig({
    this.appName = AppConstants.appName,
    this.version = AppConstants.appVersion,
    this.environment = Environment.development,
    this.apiBaseUrl = '',
    this.sentryDsn = '',
    this.analyticsEnabled = false,
  });

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      environment: Environment.current,
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
      sentryDsn: const String.fromEnvironment('SENTRY_DSN'),
      analyticsEnabled: const bool.fromEnvironment('ANALYTICS_ENABLED'),
    );
  }

  final String appName;
  final String version;
  final Environment environment;
  final String apiBaseUrl;
  final String sentryDsn;
  final bool analyticsEnabled;
}
