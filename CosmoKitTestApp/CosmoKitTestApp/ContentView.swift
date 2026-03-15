//
//  ContentView.swift
//  CosmoKitTestApp
//
//  Created by Matheus Weber on 01/12/25.
//

import SwiftUI
import CoreLocation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmoKitTestApp", category: "ContentView")

// MARK: - Theme Colors
struct CosmoTheme {
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "FF6B35"), Color(hex: "9B59B6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let accentOrange = Color(hex: "FF6B35")
    static let accentPurple = Color(hex: "9B59B6")
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var locationProvider = LocationProvider()
    @State private var deepLinkURL: URL? = nil
    @State private var deepLinkParams: [String: String]? = nil
    @State private var lastPushTitle: String?
    @State private var lastPushBody: String?
    @State private var lastPushPayload: [String: Any]?
    @State private var showPushAnimation = false
    @State private var showDeepLinkAnimation = false
    @State private var showLocationAnimation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Header
                HeroHeaderView()
                
                // Feature Cards
                VStack(spacing: 16) {
                    // Location Card
                    LocationFeatureCard(
                        locationProvider: locationProvider,
                        showAnimation: $showLocationAnimation
                    )
                    
                    // Deep Link Card
                    DeepLinkFeatureCard(
                        deepLinkURL: deepLinkURL,
                        deepLinkParams: deepLinkParams,
                        showAnimation: $showDeepLinkAnimation
                    )
                    
                    // Push Notification Card
                    PushNotificationFeatureCard(
                        title: lastPushTitle,
                        message: lastPushBody,
                        payload: lastPushPayload,
                        showAnimation: $showPushAnimation
                    )

                    // Network Proxy Test Card
                    NetworkProxyTestCard()

                    // Log Stream Test Card
                    LogStreamTestCard()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(UIColor.systemBackground),
                    Color(UIColor.systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            logger.info("ContentView appeared")
            locationProvider.start()
        }
        .onOpenURL { url in
            logger.info("Deep link received: \(url.absoluteString)")
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.deepLinkURL = url
                self.deepLinkParams = url.queryParameters
                self.showDeepLinkAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { self.showDeepLinkAnimation = false }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .cosmoKitPushReceived)) { notification in
            let userInfo = notification.userInfo ?? [:]
            let title = (userInfo["title"] as? String) ?? ""
            let body = (userInfo["body"] as? String) ?? ""
            logger.info("Push notification displayed — title: \"\(title)\" body: \"\(body)\"")
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.lastPushTitle = title.isEmpty ? nil : title
                self.lastPushBody = body.isEmpty ? nil : body
                if let rawPayload = userInfo["userInfo"] as? [String: Any] {
                    self.lastPushPayload = extractCustomPayload(from: rawPayload)
                } else {
                    self.lastPushPayload = nil
                }
                self.showPushAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { self.showPushAnimation = false }
            }
        }
        .onChange(of: locationProvider.currentCoordinate?.latitude) { _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showLocationAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showLocationAnimation = false }
            }
        }
    }
}

// MARK: - Hero Header
struct HeroHeaderView: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated Background
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: animateGradient ? 
                            [Color(hex: "9B59B6"), Color(hex: "FF6B35")] :
                            [Color(hex: "FF6B35"), Color(hex: "9B59B6")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea(edges: .top)
            
            // Floating Particles
            FloatingParticlesView()
            
            VStack(spacing: 16) {
                // App Icon Style Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.white.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 1)
                    
                    Image(systemName: "apps.iphone")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                
                VStack(spacing: 8) {
                    Text("CosmoKit")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    
                    Text("Demo App")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("Location • Deep Links • Push • Proxy")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                }
            }
            .padding(.vertical, 40)
        }
        .frame(height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// MARK: - Floating Particles
struct FloatingParticlesView: View {
    @State private var particles: [Particle] = (0..<15).map { _ in Particle() }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles.indices, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(particles[index].opacity))
                    .frame(width: particles[index].size, height: particles[index].size)
                    .position(particles[index].position)
                    .onAppear {
                        animateParticle(index: index, in: geometry.size)
                    }
            }
        }
    }
    
    private func animateParticle(index: Int, in size: CGSize) {
        let randomX = CGFloat.random(in: 0...size.width)
        let randomY = CGFloat.random(in: 0...size.height)
        particles[index].position = CGPoint(x: randomX, y: randomY)
        
        withAnimation(
            .easeInOut(duration: Double.random(in: 4...8))
            .repeatForever(autoreverses: true)
        ) {
            particles[index].position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
        }
    }
}

struct Particle {
    var position: CGPoint = .zero
    var size: CGFloat = CGFloat.random(in: 4...12)
    var opacity: Double = Double.random(in: 0.1...0.3)
}

// MARK: - Feature Card Base
struct FeatureCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let isActive: Bool
    let showAnimation: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isActive ? Color.green : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                        
                        Text(isActive ? "Active" : "Waiting...")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isActive ? .green : .secondary)
                    }
                }
                
                Spacer()
                
                if showAnimation {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Content
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.08), radius: 15, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    showAnimation ? iconColor.opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        )
        .scaleEffect(showAnimation ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showAnimation)
    }
}

// MARK: - Location Feature Card
struct LocationFeatureCard: View {
    @ObservedObject var locationProvider: LocationProvider
    @Binding var showAnimation: Bool
    
    var body: some View {
        FeatureCard(
            icon: "location.fill",
            iconColor: .blue,
            title: "Location Simulation",
            isActive: locationProvider.currentCoordinate != nil,
            showAnimation: showAnimation
        ) {
            if let coordinate = locationProvider.currentCoordinate {
                VStack(spacing: 12) {
                    // Map Preview Placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 100)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                            
                            Text("📍 Location Set")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Coordinates Display
                    HStack(spacing: 16) {
                        CoordinateDisplay(
                            label: "Latitude",
                            value: String(format: "%.6f", coordinate.latitude),
                            icon: "arrow.up.arrow.down"
                        )
                        
                        CoordinateDisplay(
                            label: "Longitude",
                            value: String(format: "%.6f", coordinate.longitude),
                            icon: "arrow.left.arrow.right"
                        )
                    }
                }
            } else {
                HStack {
                    Image(systemName: "location.slash")
                        .foregroundColor(.secondary)
                    Text(locationProvider.statusMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
    }
}

struct CoordinateDisplay: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
}

// MARK: - Deep Link Feature Card
struct DeepLinkFeatureCard: View {
    let deepLinkURL: URL?
    let deepLinkParams: [String: String]?
    @Binding var showAnimation: Bool
    
    var body: some View {
        FeatureCard(
            icon: "link",
            iconColor: CosmoTheme.accentOrange,
            title: "Deep Links",
            isActive: deepLinkURL != nil,
            showAnimation: showAnimation
        ) {
            if let url = deepLinkURL {
                VStack(alignment: .leading, spacing: 12) {
                    // URL Display
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Received URL")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(url.absoluteString)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(CosmoTheme.accentOrange)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(CosmoTheme.accentOrange.opacity(0.1))
                            )
                    }
                    
                    // Parameters
                    if let params = deepLinkParams, !params.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Parameters")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            ForEach(params.sorted(by: <), id: \.key) { key, value in
                                HStack {
                                    Text(key)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(value)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.tertiarySystemBackground))
                                )
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "link.badge.plus")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("Send a deep link from CosmoKit")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
    }
}

// MARK: - Push Notification Feature Card
struct PushNotificationFeatureCard: View {
    let title: String?
    let message: String?
    let payload: [String: Any]?
    @Binding var showAnimation: Bool
    
    var body: some View {
        FeatureCard(
            icon: "bell.fill",
            iconColor: CosmoTheme.accentPurple,
            title: "Push Notifications",
            isActive: title != nil || message != nil,
            showAnimation: showAnimation
        ) {
            if let pushTitle = title, let pushBody = message {
                VStack(alignment: .leading, spacing: 12) {
                    // Notification Preview
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(CosmoTheme.primaryGradient)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "app.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pushTitle)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(pushBody)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                        
                        Spacer()
                        
                        Text("now")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(UIColor.tertiarySystemBackground))
                    )
                    
                    // Payload
                    if let payload = payload, !payload.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Custom Payload")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(formatPayload(payload))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(CosmoTheme.accentPurple)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(CosmoTheme.accentPurple.opacity(0.1))
                                )
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("Send a push notification from CosmoKit")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
    }
}

// MARK: - Network Proxy Test Card
private let networkLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmoKitTestApp", category: "NetworkProxy")

struct NetworkProxyTestCard: View {
    @State private var results: [NetworkResult] = []
    @State private var isLoading = false

    struct NetworkResult: Identifiable {
        let id = UUID()
        let method: String
        let url: String
        let statusCode: Int?
        let size: String
        let duration: String
        let isError: Bool
    }

    var body: some View {
        FeatureCard(
            icon: "network",
            iconColor: .teal,
            title: "Network Proxy",
            isActive: !results.isEmpty,
            showAnimation: false
        ) {
            VStack(spacing: 12) {
                Text("Tap to fire HTTP requests (intercepted by CosmoKit proxy)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Request buttons
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        RequestButton(label: "GET", color: .blue) {
                            await fireRequest(method: "GET", urlString: "https://httpbin.org/get")
                        }
                        RequestButton(label: "POST", color: .green) {
                            await fireRequest(method: "POST", urlString: "https://httpbin.org/post")
                        }
                        RequestButton(label: "PUT", color: .orange) {
                            await fireRequest(method: "PUT", urlString: "https://httpbin.org/put")
                        }
                    }

                    HStack(spacing: 8) {
                        RequestButton(label: "404", color: .red) {
                            await fireRequest(method: "GET", urlString: "https://httpbin.org/status/404")
                        }
                        RequestButton(label: "500", color: .purple) {
                            await fireRequest(method: "GET", urlString: "https://httpbin.org/status/500")
                        }
                        RequestButton(label: "JSON", color: .teal) {
                            await fireRequest(method: "GET", urlString: "https://httpbin.org/json")
                        }
                    }

                    HStack(spacing: 8) {
                        RequestButton(label: "Delay 2s", color: .gray) {
                            await fireRequest(method: "GET", urlString: "https://httpbin.org/delay/2")
                        }
                        RequestButton(label: "Image", color: .pink) {
                            await fireRequest(method: "GET", urlString: "https://httpbin.org/image/png")
                        }
                        RequestButton(label: "Headers", color: .indigo) {
                            await fireRequest(method: "GET", urlString: "https://httpbin.org/headers")
                        }
                    }
                }

                // Results
                if !results.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Recent Requests")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Clear") {
                                withAnimation { results.removeAll() }
                            }
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.teal)
                        }

                        ForEach(results.prefix(5)) { result in
                            HStack(spacing: 8) {
                                Text(result.method)
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(methodColor(result.method))
                                    .cornerRadius(4)

                                if let code = result.statusCode {
                                    Text("\(code)")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(statusColor(code))
                                } else {
                                    Text("ERR")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(.red)
                                }

                                Text(result.url)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(result.duration)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(result.isError ? Color.red.opacity(0.08) : Color(UIColor.tertiarySystemBackground))
                            )
                        }
                    }
                }
            }
        }
    }

    private func fireRequest(method: String, urlString: String) async {
        let start = Date()
        networkLogger.info("Firing \(method) \(urlString)")

        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = method

        if method == "POST" || method == "PUT" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"test\": true, \"app\": \"CosmoKitTestApp\"}".data(using: .utf8)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let httpResponse = response as? HTTPURLResponse
            let elapsed = Date().timeIntervalSince(start)
            let sizeStr = data.count < 1024 ? "\(data.count) B" : String(format: "%.1f KB", Double(data.count) / 1024)
            let durationStr = elapsed < 1 ? String(format: "%.0fms", elapsed * 1000) : String(format: "%.1fs", elapsed)

            networkLogger.info("\(method) \(urlString) → \(httpResponse?.statusCode ?? 0) (\(durationStr), \(sizeStr))")

            let result = NetworkResult(
                method: method,
                url: URL(string: urlString)?.path ?? urlString,
                statusCode: httpResponse?.statusCode,
                size: sizeStr,
                duration: durationStr,
                isError: (httpResponse?.statusCode ?? 0) >= 400
            )
            withAnimation { results.insert(result, at: 0) }
        } catch {
            let elapsed = Date().timeIntervalSince(start)
            let durationStr = elapsed < 1 ? String(format: "%.0fms", elapsed * 1000) : String(format: "%.1fs", elapsed)
            networkLogger.error("\(method) \(urlString) failed: \(error.localizedDescription)")

            let result = NetworkResult(
                method: method,
                url: URL(string: urlString)?.path ?? urlString,
                statusCode: nil,
                size: "-",
                duration: durationStr,
                isError: true
            )
            withAnimation { results.insert(result, at: 0) }
        }
    }

    private func methodColor(_ method: String) -> Color {
        switch method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        default: return .gray
        }
    }

    private func statusColor(_ code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .orange
        case 400..<500: return .red
        case 500...: return .purple
        default: return .secondary
        }
    }
}

private struct RequestButton: View {
    let label: String
    let color: Color
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(color.opacity(0.1))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Log Stream Test Card
private let logStreamLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmoKitTestApp", category: "LogStreamTest")

struct LogStreamTestCard: View {
    var body: some View {
        FeatureCard(
            icon: "text.alignleft",
            iconColor: .green,
            title: "Log Stream Test",
            isActive: true,
            showAnimation: false
        ) {
            VStack(spacing: 10) {
                Text("Tap to emit log entries visible in CosmoKit's Log Stream.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    LogButton(label: "Info", color: .blue) {
                        logStreamLogger.info("Info log — tapped at \(Date().formatted(date: .omitted, time: .standard))")
                    }
                    LogButton(label: "Warning", color: .orange) {
                        logStreamLogger.warning("Warning log — something to watch at \(Date().formatted(date: .omitted, time: .standard))")
                    }
                    LogButton(label: "Error", color: .red) {
                        logStreamLogger.error("Error log — simulated failure at \(Date().formatted(date: .omitted, time: .standard))")
                    }
                }
            }
        }
    }
}

private struct LogButton: View {
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(color.opacity(0.1))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

private let locationLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmoKitTestApp", category: "Location")

final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var statusMessage: String = "Requesting location…"

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func start() {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationLogger.info("Requesting location authorization")
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationLogger.warning("Location access denied")
            statusMessage = "Location access denied. Enable it in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            locationLogger.info("Starting location updates")
            manager.startUpdatingLocation()
        @unknown default:
            locationLogger.warning("Unknown location authorization state")
            statusMessage = "Unknown location authorization state."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationLogger.info("Location authorization changed: \(manager.authorizationStatus.rawValue)")
        start()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationLogger.info("Location updated — lat: \(location.coordinate.latitude), lon: \(location.coordinate.longitude)")
        DispatchQueue.main.async {
            self.currentCoordinate = location.coordinate
            self.statusMessage = "Location updated."
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationLogger.error("Location manager failed: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.statusMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }

        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters.isEmpty ? nil : parameters
    }
}

private func formatPayload(_ payload: [String: Any]) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]),
          let string = String(data: data, encoding: .utf8) else {
        return "\(payload)"
    }
    return string
}

private func extractCustomPayload(from rawPayload: [String: Any]) -> [String: Any]? {
    if let data = rawPayload["data"] as? [String: Any], !data.isEmpty {
        return data
    }
    var sanitized = rawPayload
    sanitized.removeValue(forKey: "aps")
    return sanitized.isEmpty ? nil : sanitized
}

// MARK: - Preview
#Preview {
    ContentView()
}
