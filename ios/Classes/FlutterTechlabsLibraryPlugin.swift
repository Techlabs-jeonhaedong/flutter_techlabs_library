import Flutter
import UIKit

public class FlutterTechlabsLibraryPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.techlabs.flutter/library",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterTechlabsLibraryPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configure":
            handleConfigure(call: call, result: result)
        case "fetchServiceInfo":
            handleFetchServiceInfo(result: result)
        case "checkVersion":
            handleCheckVersion(call: call, result: result)
        case "checkNotice":
            handleCheckNotice(call: call, result: result)
        case "clearCache":
            TechLabsLibrary.shared.clearCache()
            result(nil)
        case "isUpdateRequired":
            handleIsUpdateRequired(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleConfigure(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appId = args["appId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "appId is required", details: nil))
            return
        }
        let envStr = args["environment"] as? String ?? "production"
        let environment: ServerEnvironment = envStr == "development" ? .development : .production
        TechLabsLibrary.shared.configure(appIdentifier: appId, environment: environment)
        result(nil)
    }

    private func handleFetchServiceInfo(result: @escaping FlutterResult) {
        if #available(iOS 15.0, *) {
            Task {
                do {
                    let info = try await TechLabsLibrary.shared.fetchServiceInfo()
                    await MainActor.run {
                        result(self.serviceInfoToMap(info))
                    }
                } catch {
                    await MainActor.run {
                        result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
                    }
                }
            }
        } else {
            result(FlutterError(code: "UNSUPPORTED", message: "iOS 15.0+ required", details: nil))
        }
    }

    private func handleCheckVersion(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "arguments required", details: nil))
            return
        }
        let infoDict = args["info"] as? [String: Any]
        let currentVersion = args["currentVersion"] as? String ?? ""

        let versionResult = TechLabsLibrary.shared.checkVersion(
            dictionary: infoDict,
            currentVersion: currentVersion
        )
        result(versionCheckResultToMap(versionResult))
    }

    private func handleCheckNotice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "arguments required", details: nil))
            return
        }
        let infoDict = args["info"] as? [String: Any]
        let lastSeenIndex = args["lastSeenIndex"] as? Int ?? 0

        let noticeResult = TechLabsLibrary.shared.checkNotice(
            dictionary: infoDict,
            lastSeenIndex: lastSeenIndex
        )
        result(noticeCheckResultToMap(noticeResult))
    }

    private func handleIsUpdateRequired(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        let serverVersion = args["serverVersion"] as? String
        let currentVersion = args["currentVersion"] as? String
        // iOS는 빌드넘버(정수) 비교를 지원하지 않으므로 버전 문자열로 비교
        // serverBuildNumber/currentBuildNumber가 넘어오더라도 문자열로 변환해 처리
        let serverBuildNumber = (args["serverBuildNumber"] as? NSNumber).map { "\($0.intValue)" }
        let currentBuildNumber = (args["currentBuildNumber"] as? NSNumber).map { "\($0.intValue)" }

        if let sv = serverVersion, let cv = currentVersion {
            result(TechLabsLibrary.shared.isUpdateRequired(serverVersion: sv, currentVersion: cv))
        } else if let sv = serverBuildNumber, let cv = currentBuildNumber {
            // 빌드넘버를 정수 문자열로 비교 (큰 숫자가 더 최신)
            let serverInt = Int(sv) ?? 0
            let currentInt = Int(cv) ?? 0
            result(serverInt > currentInt)
        } else {
            result(false)
        }
    }

    // MARK: - Map helpers

    private func serviceInfoToMap(_ info: ServiceInfo) -> [String: Any] {
        [
            "domain": info.domain,
            "maintenance": info.maintenance,
            "message": info.message,
            "title": info.title,
            "appAction": info.appAction,
            "appVerInfo": info.appVerInfo.map(appVerInfoToMap)
        ]
    }

    private func appVerInfoToMap(_ a: AppVerInfo) -> [String: Any] {
        [
            "device": a.device,
            "app_name": a.appName,
            "ver": a.ver,
            "type": a.type,
            "app_name2": a.appName2,
            "latest_ver": a.latestVer
        ]
    }

    private func versionCheckResultToMap(_ vr: VersionCheckResult) -> [String: Any?] {
        switch vr {
        case .forceUpdate(let storePackage):
            return ["result": "forceUpdate", "storePackage": storePackage, "callbackCode": 1]
        case .optionalUpdate(let storePackage):
            return ["result": "optionalUpdate", "storePackage": storePackage, "callbackCode": 2]
        case .noUpdateNeeded:
            return ["result": "noUpdateNeeded", "storePackage": nil, "callbackCode": 0]
        case .error:
            return ["result": "error", "storePackage": nil, "callbackCode": 3]
        }
    }

    private func noticeCheckResultToMap(_ nr: NoticeCheckResult) -> [String: Any?] {
        switch nr {
        case .hasNewNotice(let latestIndex):
            return ["result": "hasNewNotice", "latestIndex": latestIndex]
        case .noNewNotice:
            return ["result": "noNewNotice", "latestIndex": nil]
        case .error:
            return ["result": "error", "latestIndex": nil]
        }
    }
}
