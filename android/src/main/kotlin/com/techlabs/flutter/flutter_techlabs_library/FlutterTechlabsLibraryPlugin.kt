package com.techlabs.flutter.flutter_techlabs_library

import com.techlabs.flutter.flutter_techlabs_library.lib.ServerEnvironment
import com.techlabs.flutter.flutter_techlabs_library.lib.TechLabsLibrary
import com.techlabs.flutter.flutter_techlabs_library.lib.model.NoticeCheckResult
import com.techlabs.flutter.flutter_techlabs_library.lib.model.VersionCheckResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class FlutterTechlabsLibraryPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // 재연결 시 새 scope 생성 (이전 scope가 cancel된 경우 대비)
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
        channel = MethodChannel(binding.binaryMessenger, "com.techlabs.flutter/library")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "configure" -> {
                val appId = call.argument<String>("appId") ?: run {
                    result.error("INVALID_ARGUMENT", "appId is required", null)
                    return
                }
                val envStr = call.argument<String>("environment") ?: "production"
                val environment = if (envStr == "development") ServerEnvironment.DEVELOPMENT
                else ServerEnvironment.PRODUCTION
                // Flutter int는 64비트이므로 Long으로 받아 Int로 변환
                val connectTimeoutMs = (call.argument<Any>("connectTimeoutMs") as? Number)?.toInt() ?: 10000
                val readTimeoutMs = (call.argument<Any>("readTimeoutMs") as? Number)?.toInt() ?: 10000
                TechLabsLibrary.init(appId, environment, connectTimeoutMs, readTimeoutMs)
                result.success(null)
            }

            "fetchServiceInfo" -> {
                scope.launch {
                    try {
                        val info = TechLabsLibrary.fetchServiceInfoSuspend()
                        if (isActive) result.success(serviceInfoToMap(info))
                    } catch (e: kotlinx.coroutines.CancellationException) {
                        throw e
                    } catch (e: Exception) {
                        if (isActive) result.error("FETCH_ERROR", e.message, null)
                    }
                }
            }

            "checkVersion" -> {
                val infoMap = call.argument<Map<String, Any?>>("info")
                val currentVersion = call.argument<String>("currentVersion")
                val currentBuildNumber = (call.argument<Any>("currentBuildNumber") as? Number)?.toInt()

                val versionResult = when {
                    currentBuildNumber != null -> TechLabsLibrary.checkVersion(infoMap, currentBuildNumber)
                    currentVersion != null -> TechLabsLibrary.checkVersion(infoMap, currentVersion)
                    else -> VersionCheckResult.Error
                }
                result.success(versionCheckResultToMap(versionResult))
            }

            "checkNotice" -> {
                val infoMap = call.argument<Map<String, Any?>>("info")
                val lastSeenIndex = (call.argument<Any>("lastSeenIndex") as? Number)?.toInt() ?: 0
                val noticeResult = TechLabsLibrary.checkNotice(infoMap, lastSeenIndex)
                result.success(noticeCheckResultToMap(noticeResult))
            }

            "clearCache" -> {
                TechLabsLibrary.clearCache()
                result.success(null)
            }

            "isUpdateRequired" -> {
                val serverVersion = call.argument<String>("serverVersion")
                val currentVersion = call.argument<String>("currentVersion")
                val serverBuildNumber = (call.argument<Any>("serverBuildNumber") as? Number)?.toInt()
                val currentBuildNumber = (call.argument<Any>("currentBuildNumber") as? Number)?.toInt()

                val isRequired = when {
                    serverBuildNumber != null && currentBuildNumber != null ->
                        TechLabsLibrary.isUpdateRequired(serverBuildNumber, currentBuildNumber)
                    serverVersion != null && currentVersion != null ->
                        TechLabsLibrary.isUpdateRequired(serverVersion, currentVersion)
                    else -> false
                }
                result.success(isRequired)
            }

            else -> result.notImplemented()
        }
    }

    private fun serviceInfoToMap(info: com.techlabs.flutter.flutter_techlabs_library.lib.model.ServiceInfo): Map<String, Any?> {
        return mapOf(
            "domain" to info.domain,
            "maintenance" to info.maintenance,
            "message" to info.message,
            "title" to info.title,
            "appAction" to info.appAction,
            "appVerInfo" to info.appVerInfo.map { a ->
                mapOf(
                    "device" to a.device,
                    "app_name" to a.appName,
                    "ver" to a.ver,
                    "type" to a.type,
                    "app_name2" to a.appName2,
                    "latest_ver" to a.latestVer
                )
            }
        )
    }

    private fun versionCheckResultToMap(result: VersionCheckResult): Map<String, Any?> {
        return when (result) {
            is VersionCheckResult.ForceUpdate -> mapOf(
                "result" to "forceUpdate",
                "storePackage" to result.storePackage,
                "callbackCode" to 1
            )
            is VersionCheckResult.OptionalUpdate -> mapOf(
                "result" to "optionalUpdate",
                "storePackage" to result.storePackage,
                "callbackCode" to 2
            )
            VersionCheckResult.NoUpdateNeeded -> mapOf(
                "result" to "noUpdateNeeded",
                "storePackage" to null,
                "callbackCode" to 0
            )
            VersionCheckResult.Error -> mapOf(
                "result" to "error",
                "storePackage" to null,
                "callbackCode" to 3
            )
        }
    }

    private fun noticeCheckResultToMap(result: NoticeCheckResult): Map<String, Any?> {
        return when (result) {
            is NoticeCheckResult.HasNewNotice -> mapOf(
                "result" to "hasNewNotice",
                "latestIndex" to result.latestIndex
            )
            NoticeCheckResult.NoNewNotice -> mapOf(
                "result" to "noNewNotice",
                "latestIndex" to null
            )
            NoticeCheckResult.Error -> mapOf(
                "result" to "error",
                "latestIndex" to null
            )
        }
    }
}
