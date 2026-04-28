# flutter_techlabs_library

Flutter 앱의 서비스 점검 여부 확인 및 버전 업데이트 체크 기능을 제공하는 라이브러리.
Android(Kotlin) / iOS(Swift) 네이티브 라이브러리를 MethodChannel로 연결한 Flutter 브릿지.

## 요구 사항

- Flutter 3.24+ (iOS Swift Package Manager 통합 사용)
- Dart 3.0+
- Android: minSdk 24 (Android 7.0)
- iOS: 15.0+

## 설치

`pubspec.yaml`에 git 의존성으로 추가한다.

```yaml
dependencies:
  flutter_techlabs_library:
    git:
      url: https://github.com/thyadang-techlabs/flutter-techlabs-library.git
      ref: main
```

### Android 추가 설정

호스트 앱의 `android/settings.gradle`(또는 `android/build.gradle`)의 `repositories`에 **JitPack**을 추가한다.

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

### iOS 추가 설정

Flutter 3.24+의 Swift Package Manager 통합을 사용한다. 별도 설정 불필요. (CocoaPods 단독 모드는 미지원)

## 사용

### 1. 초기화

앱 시작 시점에 `appId`와 `environment`를 1회 등록한다.

```dart
import 'package:flutter_techlabs_library/flutter_techlabs_library.dart';

await TechLabsLibrary.instance.configure(
  appId: 'techlabs.global.yeppo', // 여기 등록한 식별자를 기준으로 서버에서 필요한 정보를 가져옴.
  environment: ServerEnvironment.production, // 개발서버, 실서버 구별.
);
```

### 2. 서비스 정보 fetch

`fetchServiceInfo()`는 `configure`에서 등록한 `appId`에 매핑된 S3 URL에서 자동으로 JSON을 가져온다.

```dart
final ServiceInfo info = await TechLabsLibrary.instance.fetchServiceInfo();
```

### 3. 점검 여부 + 버전 체크 통합 예제

```dart
import 'package:flutter_techlabs_library/flutter_techlabs_library.dart';

Future<void> bootstrap() async {
  await TechLabsLibrary.instance.configure(
    appId: 'techlabs.global.yeppo',
    environment: ServerEnvironment.production,
  );

  try {
    final info = await TechLabsLibrary.instance.fetchServiceInfo();
    if (info.isUnderMaintenance) {
      // 점검 화면 표시
      return;
    }

    final versionInfo = info.iosAppVerInfo?.toVersionCheckInfo()
        ?? info.androidAppVerInfo?.toVersionCheckInfo();

    final result = await TechLabsLibrary.instance.checkVersion(
      info: versionInfo,
      currentVersion: '8.4.5',     // iOS
      currentBuildNumber: 100,     // Android (우선)
    );

    switch (result) {
      case ForceUpdate():       break; // 강제 업데이트 다이얼로그
      case OptionalUpdate():    break; // 선택 업데이트 다이얼로그
      case NoUpdateNeeded():    break; // 정상 진입
      case VersionCheckError(): break; // 에러 발생. 주로 서버에서 합의되지 않은 응답을 내려준 경우.
    }
  } catch (e) {
    // fetch 실패 처리
  }
}
```

### 4. 공지 체크 (선택)

```dart
final result = await TechLabsLibrary.instance.checkNotice(
  lastSeenIndex: 0, // 사용자가 마지막으로 본 공지 인덱스
);

switch (result) {
  case HasNewNotice(): break; // 새 공지 있음
  case NoNewNotice(): break;
  case NoticeCheckError(): break;
}
```

### 5. 캐시 클리어 (선택)

```dart
await TechLabsLibrary.instance.clearCache();
```

## 현재 지원 appId

`"techlabs.global.yeppo"` — dev/prod 각각 별도 S3 URL로 매핑됨.

매핑되지 않은 식별자로 `configure`를 호출하면 iOS는 `PlatformException(INVALID_APP_ID)`를 던지고, 버전 체크 결과는 항상 `VersionCheckError`를 반환한다.
새로운 호스트 앱을 추가하려면 라이브러리 메인테이너에게 매핑 테이블 등록을 요청해줘.

## Android 보안 설정 (권장)

이 라이브러리는 `yeppo.net`에 대한 HTTPS 통신만 허용하는 `network_security_config.xml`을 포함한다.
호스트 앱의 `AndroidManifest.xml` `<application>` 태그에 적용하면 평문 HTTP 트래픽을 차단할 수 있다.

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ... >
```

> 호스트 앱에 이미 자체 `networkSecurityConfig`가 있는 경우, 해당 파일에 `yeppo.net` 도메인 설정을 직접 병합하거나 `tools:replace="android:networkSecurityConfig"`를 사용해 충돌을 해결할 것.

## configure 호출 정책

- 앱 시작 직후, 임의의 API 호출 전에 반드시 `configure`를 호출해야 한다.
- 멀티 엔진(multi-engine) 환경에서는 엔진마다 플러그인 인스턴스가 독립적으로 생성되지만, `TechLabsLibrary`는 싱글톤이므로 마지막 `configure` 호출이 전역 상태를 덮어쓴다.

## 테스트

```bash
flutter test
```
