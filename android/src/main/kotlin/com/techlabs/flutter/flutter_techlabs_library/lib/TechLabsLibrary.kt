package com.techlabs.flutter.flutter_techlabs_library.lib

import com.techlabs.flutter.flutter_techlabs_library.lib.model.AppVersion
import com.techlabs.flutter.flutter_techlabs_library.lib.model.NoticeCheckInfo
import com.techlabs.flutter.flutter_techlabs_library.lib.model.NoticeCheckResult
import com.techlabs.flutter.flutter_techlabs_library.lib.model.ServiceInfo
import com.techlabs.flutter.flutter_techlabs_library.lib.model.VersionCheckInfo
import com.techlabs.flutter.flutter_techlabs_library.lib.model.VersionCheckResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL

enum class ServerEnvironment {
    DEVELOPMENT,
    PRODUCTION
}

object TechLabsLibrary {

    @Volatile private var _appId: String? = null
    @Volatile private var _environment: ServerEnvironment? = null
    @Volatile private var _connectTimeoutMs: Int = 10_000
    @Volatile private var _readTimeoutMs: Int = 10_000
    @Volatile private var _serviceInfo: ServiceInfo? = null
    @Volatile private var _versionCheckInfo: VersionCheckInfo? = null

    private const val UPDATE_TYPE_FORCE = "0"
    private const val UPDATE_TYPE_OPTIONAL = "1"

    fun init(
        appId: String,
        environment: ServerEnvironment,
        connectTimeoutMs: Int = 10_000,
        readTimeoutMs: Int = 10_000
    ) {
        synchronized(this) {
            val changed = _appId != appId || _environment != environment
            _appId = appId
            _environment = environment
            _connectTimeoutMs = connectTimeoutMs
            _readTimeoutMs = readTimeoutMs
            if (changed) {
                _serviceInfo = null
                _versionCheckInfo = null
            }
        }
    }

    val appId: String
        get() = _appId ?: throw IllegalStateException("TechLabsLibrary is not initialized. Call init() first.")

    val s3Url: String?
        get() = synchronized(this) {
            val appId = _appId ?: throw IllegalStateException("TechLabsLibrary is not initialized.")
            val environment = _environment ?: throw IllegalStateException("TechLabsLibrary is not initialized.")
            getS3Url(appId, environment)
        }

    val serviceInfo: ServiceInfo? get() = _serviceInfo
    val versionCheckInfo: VersionCheckInfo? get() = _versionCheckInfo

    fun clearCache() {
        synchronized(this) {
            _serviceInfo = null
            _versionCheckInfo = null
        }
    }

    fun fetchServiceInfo(): ServiceInfo {
        val url = s3Url
            ?: throw IllegalStateException("No S3 URL registered for appId '${appId}'.")
        val json = fetchJson(url)
        val info = ServiceInfo.fromJsonString(json)
        synchronized(this) { _serviceInfo = info }
        return info
    }

    suspend fun fetchServiceInfoSuspend(): ServiceInfo {
        return withContext(Dispatchers.IO) { fetchServiceInfo() }
    }

    fun checkVersion(info: VersionCheckInfo?, currentBuildNumber: Int): VersionCheckResult {
        if (info == null) return VersionCheckResult.Error
        if (info.ver.isEmpty()) return VersionCheckResult.NoUpdateNeeded
        val serverBuildNumber = info.ver.toIntOrNull() ?: return VersionCheckResult.NoUpdateNeeded
        val isUpdateRequired = isUpdateRequired(serverBuildNumber, currentBuildNumber)
        return resolveResult(isUpdateRequired, info)
    }

    fun checkVersion(info: VersionCheckInfo?, currentVersion: String): VersionCheckResult {
        if (info == null) return VersionCheckResult.Error
        if (info.ver.isEmpty()) return VersionCheckResult.NoUpdateNeeded
        val isUpdateRequired = isUpdateRequired(info.ver, currentVersion)
        return resolveResult(isUpdateRequired, info)
    }

    fun checkVersion(infoMap: Map<String, Any?>?, currentBuildNumber: Int): VersionCheckResult {
        if (infoMap == null) return VersionCheckResult.Error
        return checkVersion(VersionCheckInfo.fromMap(infoMap), currentBuildNumber)
    }

    fun checkVersion(infoMap: Map<String, Any?>?, currentVersion: String): VersionCheckResult {
        if (infoMap == null) return VersionCheckResult.Error
        return checkVersion(VersionCheckInfo.fromMap(infoMap), currentVersion)
    }

    private fun resolveResult(isUpdateRequired: Boolean, info: VersionCheckInfo): VersionCheckResult {
        if (!isUpdateRequired) return VersionCheckResult.NoUpdateNeeded
        return when (info.type) {
            UPDATE_TYPE_FORCE -> VersionCheckResult.ForceUpdate(info.appName2)
            UPDATE_TYPE_OPTIONAL -> VersionCheckResult.OptionalUpdate(info.appName2)
            else -> VersionCheckResult.Error
        }
    }

    fun checkNotice(info: NoticeCheckInfo?, lastSeenIndex: Int): NoticeCheckResult {
        if (info == null) return NoticeCheckResult.Error
        val serverIndex = info.ntcLastIdx.toIntOrNull()
        if (info.ntcLastIdx.isEmpty() || serverIndex == null) return NoticeCheckResult.NoNewNotice
        return if (serverIndex > lastSeenIndex) NoticeCheckResult.HasNewNotice(serverIndex)
        else NoticeCheckResult.NoNewNotice
    }

    fun checkNotice(infoMap: Map<String, Any?>?, lastSeenIndex: Int): NoticeCheckResult {
        if (infoMap == null) return NoticeCheckResult.Error
        return checkNotice(NoticeCheckInfo.fromMap(infoMap), lastSeenIndex)
    }

    fun isUpdateRequired(serverVersion: String, currentVersion: String): Boolean {
        if (serverVersion.isBlank()) return false
        val server = AppVersion.fromString(serverVersion)
        val current = AppVersion.fromString(currentVersion)
        return server > current
    }

    fun isUpdateRequired(serverBuildNumber: Int, currentBuildNumber: Int): Boolean {
        return currentBuildNumber < serverBuildNumber
    }

    private fun fetchJson(url: String): String {
        val connection = (URL(url).openConnection() as HttpURLConnection).apply {
            requestMethod = "GET"
            connectTimeout = _connectTimeoutMs
            readTimeout = _readTimeoutMs
        }
        try {
            val responseCode = connection.responseCode
            if (responseCode != HttpURLConnection.HTTP_OK) {
                throw IOException("Failed to fetch service info (HTTP $responseCode)")
            }
            return connection.inputStream.bufferedReader().use { it.readText() }
        } finally {
            connection.disconnect()
        }
    }

    private fun getS3Url(appId: String, environment: ServerEnvironment): String? {
        return when (appId) {
            "techlabs.global.yeppo" -> when (environment) {
                ServerEnvironment.DEVELOPMENT -> "https://status.yeppo.net/dev-yeppo-service.json"
                ServerEnvironment.PRODUCTION -> "https://status.yeppo.net/www-yeppo-service.json"
            }
            else -> null
        }
    }
}
