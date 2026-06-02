import '../core/constants/app_constants.dart';
import 'environment.dart';

class AppConfig {
  const AppConfig({
    this.appName = AppConstants.appName,
    this.version = AppConstants.appVersion,
    this.environment = Environment.development,
  });

  final String appName;
  final String version;
  final Environment environment;
}
