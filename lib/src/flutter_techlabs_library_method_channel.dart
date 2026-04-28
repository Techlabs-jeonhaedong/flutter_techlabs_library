import 'package:flutter/services.dart';

import 'flutter_techlabs_library_platform_interface.dart';

class MethodChannelFlutterTechlabsLibrary
    extends FlutterTechlabsLibraryPlatform {
  static const MethodChannel _channel =
      MethodChannel('com.techlabs.flutter/library');

  @override
  Future<void> configure({
    required String appId,
    required String environment,
    int connectTimeoutMs = 10000,
    int readTimeoutMs = 10000,
  }) async {
    await _channel.invokeMethod<void>('configure', {
      'appId': appId,
      'environment': environment,
      'connectTimeoutMs': connectTimeoutMs,
      'readTimeoutMs': readTimeoutMs,
    });
  }

  @override
  Future<Map<Object?, Object?>> fetchServiceInfo() async {
    final result =
        await _channel.invokeMapMethod<Object?, Object?>('fetchServiceInfo', {});
    return result ?? {};
  }

  @override
  Future<Map<Object?, Object?>> checkVersion({
    Map<String, Object?>? info,
    String? currentVersion,
    int? currentBuildNumber,
  }) async {
    final result =
        await _channel.invokeMapMethod<Object?, Object?>('checkVersion', {
      'info': info,
      'currentVersion': currentVersion,
      'currentBuildNumber': currentBuildNumber,
    });
    return result ?? {};
  }

  @override
  Future<Map<Object?, Object?>> checkNotice({
    Map<String, Object?>? info,
    required int lastSeenIndex,
  }) async {
    final result =
        await _channel.invokeMapMethod<Object?, Object?>('checkNotice', {
      'info': info,
      'lastSeenIndex': lastSeenIndex,
    });
    return result ?? {};
  }

  @override
  Future<void> clearCache() async {
    await _channel.invokeMethod<void>('clearCache', {});
  }

  @override
  Future<bool> isUpdateRequired({
    String? serverVersion,
    String? currentVersion,
    int? serverBuildNumber,
    int? currentBuildNumber,
  }) async {
    final result = await _channel.invokeMethod<bool>('isUpdateRequired', {
      'serverVersion': serverVersion,
      'currentVersion': currentVersion,
      'serverBuildNumber': serverBuildNumber,
      'currentBuildNumber': currentBuildNumber,
    });
    return result ?? false;
  }
}
