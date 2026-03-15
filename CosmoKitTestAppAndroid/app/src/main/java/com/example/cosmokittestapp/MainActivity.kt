package com.example.cosmokittestapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.tooling.preview.Preview
import com.example.cosmokittestapp.ui.theme.CosmoKitTestAppTheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import java.net.InetSocketAddress
import java.net.Proxy
import java.security.KeyStore
import java.security.cert.CertificateException
import java.security.cert.X509Certificate
import javax.net.ssl.HostnameVerifier
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.TrustManagerFactory
import javax.net.ssl.X509TrustManager

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            CosmoKitTestAppTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    TLSInterceptionTestScreen(modifier = Modifier.padding(innerPadding))
                }
            }
        }
    }
}

@Composable
fun TLSInterceptionTestScreen(modifier: Modifier = Modifier) {
    var isMakingTestRequest by remember { mutableStateOf(false) }
    var responseText by remember { mutableStateOf<String?>(null) }
    var errorText by remember { mutableStateOf<String?>(null) }
    val scrollState = rememberScrollState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(scrollState),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text("CosmoKitTestApp (Android)", style = MaterialTheme.typography.titleLarge)
        Text("TLS Interception Test", style = MaterialTheme.typography.titleMedium)

        Button(
            onClick = {
                isMakingTestRequest = true
                responseText = null
                errorText = null
            },
            enabled = !isMakingTestRequest
        ) {
            if (isMakingTestRequest) {
                CircularProgressIndicator(strokeWidth = 2.dp, modifier = Modifier.height(18.dp))
            } else {
                Text("Test TLS Interception")
            }
        }

        if (isMakingTestRequest) {
            LaunchedEffect(Unit) {
                val result = withContext(Dispatchers.IO) {
                    runTlsTest()
                }
                when (result) {
                    is TestResult.Success -> responseText = result.text
                    is TestResult.Failure -> errorText = result.reason
                }
                isMakingTestRequest = false
            }
        }

        if (responseText != null) {
            Text("Response:", style = MaterialTheme.typography.labelLarge)
            Text(responseText!!, style = MaterialTheme.typography.bodySmall)
        }

        if (errorText != null) {
            Text("Error:", style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.error)
            Text(errorText!!, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.error)
        }
    }
}

private sealed class TestResult {
    data class Success(val text: String) : TestResult()
    data class Failure(val reason: String) : TestResult()
}

private fun runTlsTest(): TestResult {
    val testUrl = "https://httpbin.org/get?test=cosmo-proxy-tls&from=cosmo-kit-test-app-android"

    // For Android Emulator: use 10.0.2.2 to reach host machine (macOS) services.
    // For a physical Android device: use your Mac's LAN IP.
    val proxyHost = "10.0.2.2"
    val proxyPort = 9090

    println("[TEST] Making request to: $testUrl")
    println("[TEST] Configured proxy: $proxyHost:$proxyPort (Android Emulator -> host)")

    return try {
        val trustManager = createCosmoProxyFriendlyTrustManager()
        val sslContext = SSLContext.getInstance("TLS")
        sslContext.init(null, arrayOf<TrustManager>(trustManager), null)

        val client = OkHttpClient.Builder()
            .proxy(Proxy(Proxy.Type.HTTP, InetSocketAddress(proxyHost, proxyPort)))
            .sslSocketFactory(sslContext.socketFactory, trustManager)
            .hostnameVerifier(HostnameVerifier { hostname, session ->
                val ok = javax.net.ssl.HttpsURLConnection.getDefaultHostnameVerifier().verify(hostname, session)
                if (!ok) println("[TEST] ⚠️ Hostname verification failed for: $hostname")
                ok
            })
            .build()

        val request = Request.Builder().url(testUrl).get().build()
        client.newCall(request).execute().use { response ->
            val handshake = response.handshake
            if (handshake != null) {
                val peerCerts = handshake.peerCertificates
                var foundCosmoProxy = false
                for ((idx, cert) in peerCerts.withIndex()) {
                    val x509 = cert as? X509Certificate
                    val subject = x509?.subjectX500Principal?.name ?: cert.type
                    println("[TEST] Certificate $idx: $subject")
                    if (subject.contains("CosmoProxy", ignoreCase = true)) {
                        foundCosmoProxy = true
                    }
                }
                if (foundCosmoProxy) {
                    println("[TEST] ✅ Found CosmoProxy CA in certificate chain")
                    println("[TEST] ✅ Trusting CosmoProxy certificate for: httpbin.org")
                }
            }

            val body = response.body?.string().orEmpty()
            println("[TEST] Response status: ${response.code}")
            println("[TEST] Response received (${body.length} chars)")
            TestResult.Success(body)
        }
    } catch (t: Throwable) {
        println("[TEST] Request failed: ${t.message}")
        TestResult.Failure(t.message ?: t.toString())
    }
}

private fun createCosmoProxyFriendlyTrustManager(): X509TrustManager {
    val tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm())
    tmf.init(null as KeyStore?)
    val defaultTrustManager = tmf.trustManagers.first { it is X509TrustManager } as X509TrustManager

    return object : X509TrustManager {
        override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {
            defaultTrustManager.checkClientTrusted(chain, authType)
        }

        override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {
            val hasCosmoProxy = chain.any { cert ->
                val subject = cert.subjectX500Principal?.name ?: ""
                subject.contains("CosmoProxy", ignoreCase = true)
            }

            if (hasCosmoProxy) {
                // Mirror the iOS delegate behavior: if CosmoProxy CA is in the chain,
                // accept it for debugging purposes.
                return
            }

            try {
                defaultTrustManager.checkServerTrusted(chain, authType)
            } catch (e: CertificateException) {
                throw e
            }
        }

        override fun getAcceptedIssuers(): Array<X509Certificate> = defaultTrustManager.acceptedIssuers
    }
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    CosmoKitTestAppTheme {
        TLSInterceptionTestScreen()
    }
}