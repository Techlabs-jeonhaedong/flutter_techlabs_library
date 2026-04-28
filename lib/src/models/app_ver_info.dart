import 'version_check_info.dart';

class AppVerInfo {
  final String device;
  final String appName;
  final String ver;
  final String type;
  final String appName2;
  final String latestVer;

  const AppVerInfo({
    required this.device,
    required this.appName,
    required this.ver,
    required this.type,
    required this.appName2,
    required this.latestVer,
  });

  factory AppVerInfo.fromMap(Map<Object?, Object?> map) {
    return AppVerInfo(
      device: (map['device'] as String?) ?? '',
      appName: (map['app_name'] as String?) ?? '',
      ver: (map['ver'] as String?) ?? '',
      type: (map['type'] as String?) ?? '',
      appName2: (map['app_name2'] as String?) ?? '',
      latestVer: (map['latest_ver'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'device': device,
      'app_name': appName,
      'ver': ver,
      'type': type,
      'app_name2': appName2,
      'latest_ver': latestVer,
    };
  }

  VersionCheckInfo toVersionCheckInfo() {
    return VersionCheckInfo(
      ver: ver,
      latestVer: latestVer,
      type: type,
      appName2: appName2,
    );
  }
}
