import 'app_ver_info.dart';

class ServiceInfo {
  final String domain;
  final String maintenance;
  final String message;
  final String title;
  final String appAction;
  final List<AppVerInfo> appVerInfo;

  const ServiceInfo({
    required this.domain,
    required this.maintenance,
    required this.message,
    required this.title,
    required this.appAction,
    required this.appVerInfo,
  });

  bool get isUnderMaintenance => maintenance == 'Y';

  AppVerInfo? get androidAppVerInfo =>
      appVerInfo.where((e) => e.device == 'android').firstOrNull;

  AppVerInfo? get iosAppVerInfo =>
      appVerInfo.where((e) => e.device == 'ios').firstOrNull;

  factory ServiceInfo.fromMap(Map<Object?, Object?> map) {
    final rawList = map['appVerInfo'];
    final List<AppVerInfo> verInfoList;
    if (rawList is List) {
      verInfoList = rawList
          .whereType<Map<Object?, Object?>>()
          .map(AppVerInfo.fromMap)
          .toList();
    } else {
      verInfoList = [];
    }

    return ServiceInfo(
      domain: (map['domain'] as String?) ?? '',
      maintenance: (map['maintenance'] as String?) ?? 'N',
      message: (map['message'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      appAction: (map['appAction'] as String?) ?? '',
      appVerInfo: verInfoList,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'domain': domain,
      'maintenance': maintenance,
      'message': message,
      'title': title,
      'appAction': appAction,
      'appVerInfo': appVerInfo.map((e) => e.toMap()).toList(),
    };
  }
}
