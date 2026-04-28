# flutter_techlabs_library

Techlabs 서비스 점검 / 버전체크 / 공지 라이브러리의 Flutter 브릿지.
Android(Kotlin) 및 iOS(Swift) 네이티브 라이브러리를 MethodChannel로 연결한다.

## 요구사항

- Flutter 3.24 이상 (iOS Swift Package Manager 통합 사용)
- Android: minSdk 24
- iOS: 15.0 이상

## 의존성 설정 (호스트 앱 측)

### Android

호스트 앱의 `android/settings.gradle` 또는 `android/build.gradle`의 `allprojects.repositories`에 **JitPack 추가**:

```gradle
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://www.jitpack.io' }
    }
}
```

> Gradle 7.x 이상에서 `PREFER_SETTINGS` 모드를 사용하는 경우, 라이브러리 수준의 repository 선언이 무시될 수 있으므로 반드시 호스트 앱의 `settings.gradle`에 JitPack을 추가해야 한다.

### iOS

Flutter 3.24+의 Swift Package Manager 통합을 사용한다. 별도 설정 불필요. (CocoaPods 단독 모드는 미지원)

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

## Android 보안 설정

이 라이브러리는 `yeppo.net`에 대한 HTTPS 통신만 허용하는 `network_security_config.xml` 파일을 포함한다.
호스트 앱의 `AndroidManifest.xml` `<application>` 태그에 아래와 같이 적용하면 평문 HTTP 트래픽을 차단할 수 있다.

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ... >
```

> 호스트 앱에 이미 자체 `networkSecurityConfig`가 있는 경우, 해당 파일에 `yeppo.net` 도메인 설정을 직접 병합하거나
> `tools:replace="android:networkSecurityConfig"`를 사용해 충돌을 해결할 것.

## configure 호출 정책

- 앱 시작 직후, 임의의 API 호출 전에 반드시 `configure`를 호출해야 한다.
- 유효하지 않은 `appId`를 전달하면 `PlatformException(INVALID_APP_ID)` 예외가 발생한다 (iOS).
- 멀티 엔진(multi-engine) 환경에서는 엔진마다 플러그인 인스턴스가 독립적으로 생성된다.
  단, `TechLabsLibrary`는 싱글톤이므로 마지막 `configure` 호출이 전역 상태를 덮어쓴다. 주의할 것.
