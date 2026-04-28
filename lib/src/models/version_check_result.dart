sealed class VersionCheckResult {
  const VersionCheckResult();

  int get callbackCode;
}

final class ForceUpdate extends VersionCheckResult {
  final String storePackage;

  const ForceUpdate(this.storePackage);

  @override
  int get callbackCode => 1;
}

final class OptionalUpdate extends VersionCheckResult {
  final String storePackage;

  const OptionalUpdate(this.storePackage);

  @override
  int get callbackCode => 2;
}

final class NoUpdateNeeded extends VersionCheckResult {
  const NoUpdateNeeded();

  @override
  int get callbackCode => 0;
}

final class VersionCheckError extends VersionCheckResult {
  const VersionCheckError();

  @override
  int get callbackCode => 3;
}
