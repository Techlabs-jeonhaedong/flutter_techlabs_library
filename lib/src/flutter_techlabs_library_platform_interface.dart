import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_techlabs_library_method_channel.dart';

abstract class FlutterTechlabsLibraryPlatform extends PlatformInterface {
  FlutterTechlabsLibraryPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTechlabsLibraryPlatform _instance =
      MethodChannelFlutterTechlabsLibrary();

  static FlutterTechlabsLibraryPlatform get instance => _instance;

  static set instance(FlutterTechlabsLibraryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> configure({
    required String appId,
    required String environment,
    int connectTimeoutMs = 10000,
    int readTimeoutMs = 10000,
  }) {
    throw UnimplementedError('configure() has not been implemented.');
  }

  Future<Map<Object?, Object?>> fetchServiceInfo() {
    throw UnimplementedError('fetchServiceInfo() has not been implemented.');
  }

  Future<Map<Object?, Object?>> checkVersion({
    Map<String, Object?>? info,
    String? currentVersion,
    int? currentBuildNumber,
  }) {
    throw UnimplementedError('checkVersion() has not been implemented.');
  }

  Future<Map<Object?, Object?>> checkNotice({
    Map<String, Object?>? info,
    required int lastSeenIndex,
  }) {
    throw UnimplementedError('checkNotice() has not been implemented.');
  }

  Future<void> clearCache() {
    throw UnimplementedError('clearCache() has not been implemented.');
  }

  Future<bool> isUpdateRequired({
    String? serverVersion,
    String? currentVersion,
    int? serverBuildNumber,
    int? currentBuildNumber,
  }) {
    throw UnimplementedError('isUpdateRequired() has not been implemented.');
  }
}
