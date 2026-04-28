import 'package:flutter/material.dart';
import 'package:flutter_techlabs_library/flutter_techlabs_library.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechLabs Library Example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _library = TechLabsLibrary.instance;
  ServiceInfo? _serviceInfo;
  String _log = '(결과 없음)';
  bool _loading = false;

  void _setLog(String msg) => setState(() => _log = msg);

  Future<void> _configure() async {
    setState(() => _loading = true);
    try {
      await _library.configure(
        appId: 'techlabs.global.yeppo',
        environment: ServerEnvironment.development,
      );
      _setLog('configure() 완료');
    } catch (e) {
      _setLog('configure 에러: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchServiceInfo() async {
    setState(() => _loading = true);
    try {
      final info = await _library.fetchServiceInfo();
      setState(() {
        _serviceInfo = info;
        _log = 'ServiceInfo:\n'
            '  domain: ${info.domain}\n'
            '  maintenance: ${info.maintenance} (점검중: ${info.isUnderMaintenance})\n'
            '  appVerInfo 수: ${info.appVerInfo.length}';
      });
    } catch (e) {
      _setLog('fetchServiceInfo 에러: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkVersion() async {
    setState(() => _loading = true);
    try {
      final info = _serviceInfo?.iosAppVerInfo?.toVersionCheckInfo()
          ?? _serviceInfo?.androidAppVerInfo?.toVersionCheckInfo();
      final result = await _library.checkVersion(
        info: info,
        currentVersion: '1.0.0',
        currentBuildNumber: 1,
      );
      final msg = switch (result) {
        ForceUpdate(storePackage: final pkg) => 'ForceUpdate: $pkg (code=${result.callbackCode})',
        OptionalUpdate(storePackage: final pkg) => 'OptionalUpdate: $pkg (code=${result.callbackCode})',
        NoUpdateNeeded() => 'NoUpdateNeeded (code=${result.callbackCode})',
        VersionCheckError() => 'Error (code=${result.callbackCode})',
      };
      _setLog('checkVersion: $msg');
    } catch (e) {
      _setLog('checkVersion 에러: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkNotice() async {
    setState(() => _loading = true);
    try {
      final result = await _library.checkNotice(lastSeenIndex: 0);
      final msg = switch (result) {
        HasNewNotice(latestIndex: final idx) => 'HasNewNotice: latestIndex=$idx',
        NoNewNotice() => 'NoNewNotice',
        NoticeCheckError() => 'Error',
      };
      _setLog('checkNotice: $msg');
    } catch (e) {
      _setLog('checkNotice 에러: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _clearCache() async {
    await _library.clearCache();
    setState(() {
      _serviceInfo = null;
      _log = 'clearCache() 완료';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TechLabs Library Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _configure,
              child: const Text('Configure (dev / yeppo)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _fetchServiceInfo,
              child: const Text('Fetch Service Info'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _checkVersion,
              child: const Text('Check Version (currentVersion: 1.0.0)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _checkNotice,
              child: const Text('Check Notice (lastSeenIndex: 0)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loading ? null : _clearCache,
              child: const Text('Clear Cache'),
            ),
            const SizedBox(height: 24),
            if (_loading) const Center(child: CircularProgressIndicator()),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(_log, style: const TextStyle(fontFamily: 'monospace')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
