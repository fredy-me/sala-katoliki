enum Environment {
  development,
  staging,
  production;

  static Environment get current {
    return switch (const String.fromEnvironment('APP_ENV')) {
      'production' => Environment.production,
      'staging' => Environment.staging,
      _ => Environment.development,
    };
  }
}
