class VersionCheckInfo {
  final String ver;
  final String latestVer;
  final String type;
  final String appName2;

  const VersionCheckInfo({
    required this.ver,
    required this.latestVer,
    required this.type,
    required this.appName2,
  });

  factory VersionCheckInfo.fromMap(Map<Object?, Object?> map) {
    return VersionCheckInfo(
      ver: (map['ver'] as String?) ?? '',
      latestVer: (map['latest_ver'] as String?) ?? '',
      type: (map['type'] as String?) ?? '',
      appName2: (map['app_name2'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'ver': ver,
      'latest_ver': latestVer,
      'type': type,
      'app_name2': appName2,
    };
  }
}
