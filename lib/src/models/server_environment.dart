enum ServerEnvironment {
  development,
  production;

  String get value {
    switch (this) {
      case ServerEnvironment.development:
        return 'development';
      case ServerEnvironment.production:
        return 'production';
    }
  }
}
