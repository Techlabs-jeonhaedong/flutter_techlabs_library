## 0.2.0 - 2026-04-28
### Changed
- 네이티브 라이브러리를 패키지 내부 복사본 → 표준 의존성으로 전환
  - Android: JitPack via `com.github.thyadang-techlabs:android-techlabs-library:v2.1.1`
  - iOS: Swift Package Manager via `iOS-techlabs-library 1.0.0`
- iOS는 Flutter 3.24+ 요구 (SwiftPM 통합 사용)

## 0.1.1

- [fix] iOS `resolveResult` unknown type 시 `.forceUpdate` → `.error` 반환으로 Android와 동일하게 수정.
- [fix] iOS `VersionCheckInfo` type 기본값 `"0"` → `""` 변경 (unknown type을 forceUpdate로 오판하던 문제 해결).
- [fix] iOS Plugin `handleCheckVersion`: `info` nil 시 즉시 error 반환, `currentBuildNumber` 경로 추가, `currentVersion` nil 시 error 반환.
- [fix] iOS Plugin `handleCheckNotice`: `info` nil 시 즉시 error 반환.
- [fix] iOS Plugin `handleConfigure`: 유효하지 않은 `appId` 시 `INVALID_APP_ID` 에러 반환.
- [fix] iOS Plugin `detachFromEngine`: inflight Task 취소 구현으로 메모리 누수 방지.
- [fix] iOS Plugin `FETCH_ERROR` 메시지 일반화 (내부 에러 메시지 노출 방지).
- [fix] Android `fetchServiceInfo` coroutine `CancellationException` 재전파 (scope 취소 시 오동작 방지).
- [fix] Android `fetchJson` HTTP 에러 메시지 마스킹 (응답 메시지 직접 노출 방지).
- [feat] Android `network_security_config.xml` 추가 (cleartext 트래픽 차단 설정 제공).
- [fix] Dart `_parseVersionCheckResult`/`_parseNoticeCheckResult`: `'error'` 명시 매칭, default에 assert 추가.
- [fix] Dart `checkVersion`: `info` null 시 즉시 `VersionCheckError` 반환, 두 인자 모두 null 시 assert + error.
- [fix] Dart `checkNotice`: `info` null 시 즉시 `NoticeCheckError` 반환.

## 0.1.0

- Initial release.
- Android/iOS 브릿지: configure, fetchServiceInfo, checkVersion, checkNotice, clearCache, isUpdateRequired.
