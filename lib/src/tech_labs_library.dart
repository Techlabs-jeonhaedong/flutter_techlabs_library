import 'models/notice_check_info.dart';
import 'models/notice_check_result.dart';
import 'models/server_environment.dart';
import 'models/service_info.dart';
import 'models/version_check_info.dart';
import 'models/version_check_result.dart';
import 'flutter_techlabs_library_platform_interface.dart';

class TechLabsLibrary {
  TechLabsLibrary._();

  static final TechLabsLibrary instance = TechLabsLibrary._();

  FlutterTechlabsLibraryPlatform get _platform =>
      FlutterTechlabsLibraryPlatform.instance;

  Future<void> configure({
    required String appId,
    required ServerEnvironment environment,
    int connectTimeoutMs = 10000,
    int readTimeoutMs = 10000,
  }) {
    return _platform.configure(
      appId: appId,
      environment: environment.value,
      connectTimeoutMs: connectTimeoutMs,
      readTimeoutMs: readTimeoutMs,
    );
  }

  Future<ServiceInfo> fetchServiceInfo() async {
    final map = await _platform.fetchServiceInfo();
    return ServiceInfo.fromMap(map);
  }

  Future<VersionCheckResult> checkVersion({
    VersionCheckInfo? info,
    String? currentVersion,
    int? currentBuildNumber,
  }) async {
    if (info == null) return const VersionCheckError();
    if (currentVersion == null && currentBuildNumber == null) {
      assert(false, 'checkVersion: currentVersion 또는 currentBuildNumber 중 하나는 필수');
      return const VersionCheckError();
    }
    final result = await _platform.checkVersion(
      info: info.toMap(),
      currentVersion: currentVersion,
      currentBuildNumber: currentBuildNumber,
    );
    return _parseVersionCheckResult(result);
  }

  Future<NoticeCheckResult> checkNotice({
    NoticeCheckInfo? info,
    required int lastSeenIndex,
  }) async {
    if (info == null) return const NoticeCheckError();
    final result = await _platform.checkNotice(
      info: info.toMap(),
      lastSeenIndex: lastSeenIndex,
    );
    return _parseNoticeCheckResult(result);
  }

  Future<void> clearCache() {
    return _platform.clearCache();
  }

  Future<bool> isUpdateRequired({
    String? serverVersion,
    String? currentVersion,
    int? serverBuildNumber,
    int? currentBuildNumber,
  }) {
    return _platform.isUpdateRequired(
      serverVersion: serverVersion,
      currentVersion: currentVersion,
      serverBuildNumber: serverBuildNumber,
      currentBuildNumber: currentBuildNumber,
    );
  }

  VersionCheckResult _parseVersionCheckResult(Map<Object?, Object?> map) {
    final resultStr = map['result'] as String?;
    final storePackage = (map['storePackage'] as String?) ?? '';
    switch (resultStr) {
      case 'forceUpdate':
        return ForceUpdate(storePackage);
      case 'optionalUpdate':
        return OptionalUpdate(storePackage);
      case 'noUpdateNeeded':
        return const NoUpdateNeeded();
      case 'error':
        return const VersionCheckError();
      default:
        assert(false, 'Unknown VersionCheckResult: $resultStr');
        return const VersionCheckError();
    }
  }

  NoticeCheckResult _parseNoticeCheckResult(Map<Object?, Object?> map) {
    final resultStr = map['result'] as String?;
    final latestIndex = map['latestIndex'] as int?;
    switch (resultStr) {
      case 'hasNewNotice':
        return HasNewNotice(latestIndex ?? 0);
      case 'noNewNotice':
        return const NoNewNotice();
      case 'error':
        return const NoticeCheckError();
      default:
        assert(false, 'Unknown NoticeCheckResult: $resultStr');
        return const NoticeCheckError();
    }
  }
}
