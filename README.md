# flutter_techlabs_library

Techlabs 서비스 점검 / 버전체크 / 공지 라이브러리의 Flutter 브릿지.
Android(Kotlin) 및 iOS(Swift) 네이티브 라이브러리를 MethodChannel로 연결한다.

## 지원 플랫폼

| Platform | 최소 버전 |
|---|---|
| Android | API 24 (Android 7.0) |
| iOS | 15.0 |

## 사용법

### 1. configure

앱 시작 시 반드시 호출해야 한다.

```dart
import 'package:flutter_techlabs_library/flutter_techlabs_library.dart';

await TechLabsLibrary.instance.configure(
  appId: 'techlabs.global.yeppo',
  environment: ServerEnvironment.development, // 또는 .production
);
```

### 2. fetchServiceInfo

S3에서 서비스 정보를 가져온다.

```dart
final ServiceInfo info = await TechLabsLibrary.instance.fetchServiceInfo();
print(info.isUnderMaintenance); // 점검 여부
```

### 3. checkVersion

```dart
final versionInfo = info.iosAppVerInfo?.toVersionCheckInfo()
    ?? info.androidAppVerInfo?.toVersionCheckInfo();

final result = await TechLabsLibrary.instance.checkVersion(
  info: versionInfo,
  currentVersion: '1.0.0',        // iOS
  currentBuildNumber: 100,         // Android (우선)
);

switch (result) {
  case ForceUpdate(:final storePackage):
    // 강제 업데이트 → 스토어로 이동
    break;
  case OptionalUpdate(:final storePackage):
    // 선택 업데이트
    break;
  case NoUpdateNeeded():
    // 최신 버전
    break;
  case VersionCheckError():
    // 에러
    break;
}
```

### 4. checkNotice

```dart
final result = await TechLabsLibrary.instance.checkNotice(
  lastSeenIndex: 0, // 사용자가 마지막으로 본 공지 인덱스
);

switch (result) {
  case HasNewNotice(:final latestIndex):
    // 새 공지 있음
    break;
  case NoNewNotice():
    break;
  case NoticeCheckError():
    break;
}
```

### 5. clearCache

```dart
await TechLabsLibrary.instance.clearCache();
```

## 지원 appId

| appId | DEV URL | PROD URL |
|---|---|---|
| `techlabs.global.yeppo` | https://status.yeppo.net/dev-yeppo-service.json | https://status.yeppo.net/www-yeppo-service.json |
