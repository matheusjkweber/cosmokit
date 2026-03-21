//
//  ContentView.swift
//  CosmoKitTestApp
//

import SwiftUI
import CoreLocation
import MapKit
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmoKitTestApp", category: "ContentView")

// MARK: - Theme

struct CosmoTheme {
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "6C5CE7"), Color(hex: "A855F7"), Color(hex: "EC4899")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let accent = Color(hex: "6C5CE7")
    static let accentPink = Color(hex: "EC4899")
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
                HeroHeaderView()

                // Feature count strip
                FeatureStripView()
                    .padding(.top, -20)
                    .zIndex(1)

                VStack(spacing: 16) {
                    LocationFeatureCard(
                        locationProvider: locationProvider,
                        showAnimation: $showLocationAnimation
                    )

                    DeepLinkFeatureCard(
                        deepLinkURL: deepLinkURL,
                        deepLinkParams: deepLinkParams,
                        showAnimation: $showDeepLinkAnimation
                    )

                    PushNotificationFeatureCard(
                        title: lastPushTitle,
                        message: lastPushBody,
                        payload: lastPushPayload,
                        showAnimation: $showPushAnimation
                    )

                    NetworkProxyTestCard()

                    SimulatorToolsCard()

                    LogStreamTestCard()

                    // Footer
                    VStack(spacing: 8) {
                        Text("Built with CosmoKit")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("cosmokit.dev")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(CosmoTheme.accent)
                    }
                    .padding(.vertical, 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
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
            // Animated gradient background
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: animateGradient
                            ? [Color(hex: "6C5CE7"), Color(hex: "EC4899"), Color(hex: "F97316")]
                            : [Color(hex: "F97316"), Color(hex: "EC4899"), Color(hex: "6C5CE7")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea(edges: .top)

            // Mesh overlay
            FloatingParticlesView()

            VStack(spacing: 20) {
                // Logo
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 110, height: 110)
                        .blur(radius: 2)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 90, height: 90)

                    Image(systemName: "apps.iphone")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "6C5CE7"), Color(hex: "EC4899")],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                }
                .shadow(color: .black.opacity(0.25), radius: 30, y: 15)

                VStack(spacing: 6) {
                    Text("CosmoKit")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Simulator Control Panel")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }

                // Feature pills
                HStack(spacing: 8) {
                    FeaturePill(icon: "location.fill", text: "GPS")
                    FeaturePill(icon: "bell.fill", text: "Push")
                    FeaturePill(icon: "link", text: "Links")
                    FeaturePill(icon: "network", text: "Proxy")
                }
            }
            .padding(.vertical, 40)
        }
        .frame(height: 320)
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.white.opacity(0.2), in: Capsule())
    }
}

// MARK: - Feature Count Strip

struct FeatureStripView: View {
    var body: some View {
        HStack(spacing: 0) {
            FeatureCountItem(count: "6", label: "Features", icon: "star.fill")
            Divider().frame(height: 30)
            FeatureCountItem(count: "3", label: "Speeds", icon: "speedometer")
            Divider().frame(height: 30)
            FeatureCountItem(count: "9+", label: "HTTP Tests", icon: "arrow.up.arrow.down")
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 20, y: 5)
        )
        .padding(.horizontal, 30)
    }
}

struct FeatureCountItem: View {
    let count: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(CosmoTheme.accent)
                Text(count)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
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
                    .onAppear { animateParticle(index: index, in: geometry.size) }
            }
        }
    }

    private func animateParticle(index: Int, in size: CGSize) {
        particles[index].position = CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height)
        )
        withAnimation(.easeInOut(duration: Double.random(in: 4...8)).repeatForever(autoreverses: true)) {
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
    var opacity: Double = Double.random(in: 0.08...0.25)
}

// MARK: - Feature Card Base

struct FeatureCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isActive: Bool
    let showAnimation: Bool
    @ViewBuilder let content: Content

    init(icon: String, iconColor: Color, title: String, subtitle: String = "",
         isActive: Bool, showAnimation: Bool, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.isActive = isActive
        self.showAnimation = showAnimation
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(isActive ? Color.green : Color.gray.opacity(0.4))
                                .frame(width: 7, height: 7)
                            Text(isActive ? "Active" : "Waiting...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(isActive ? .green : .secondary)
                        }
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

            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.06), radius: 15, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(showAnimation ? iconColor.opacity(0.4) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(showAnimation ? 1.015 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showAnimation)
    }
}

// MARK: - Location Feature Card

struct LocationFeatureCard: View {
    @ObservedObject var locationProvider: LocationProvider
    @Binding var showAnimation: Bool
    @State private var mapPosition: MapCameraPosition = .automatic

    var body: some View {
        FeatureCard(
            icon: "location.fill",
            iconColor: .blue,
            title: "Location Simulation",
            subtitle: "GPS mock + route simulation",
            isActive: locationProvider.currentCoordinate != nil,
            showAnimation: showAnimation
        ) {
            if let coordinate = locationProvider.currentCoordinate {
                VStack(spacing: 12) {
                    // Live map with trail
                    Map(position: $mapPosition, interactionModes: []) {
                        // Trail tail — fades behind current position
                        if locationProvider.trail.count >= 2 {
                            MapPolyline(coordinates: locationProvider.trail)
                                .stroke(
                                    .linearGradient(
                                        colors: [.cyan.opacity(0), .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 3
                                )
                        }

                        // Current position
                        Annotation("", coordinate: coordinate) {
                            ZStack {
                                if locationProvider.isMoving {
                                    Circle()
                                        .fill(.blue.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                }
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 14, height: 14)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 2.5)
                                    )
                                    .shadow(color: .blue.opacity(0.4), radius: 4)
                            }
                        }
                    }
                    .mapStyle(.standard(pointsOfInterest: .excludingAll))
                    .frame(height: locationProvider.isMoving ? 180 : 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .id(locationProvider.trail.count) // force map rebuild when trail updates
                    .animation(.easeInOut(duration: 0.3), value: locationProvider.isMoving)
                    .onChange(of: locationProvider.currentCoordinate?.latitude) { _, _ in
                        updateMapPosition()
                    }
                    .onChange(of: locationProvider.currentCoordinate?.longitude) { _, _ in
                        updateMapPosition()
                    }
                    .onAppear { updateMapPosition() }

                    // Movement indicator
                    if locationProvider.isMoving {
                        HStack(spacing: 6) {
                            Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.blue)
                            Text("Route in progress")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                            Spacer()
                            Text("\(locationProvider.trail.count) points")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.08))
                        )
                    }

                    HStack(spacing: 12) {
                        CoordinateDisplay(label: "Latitude", value: String(format: "%.6f", coordinate.latitude), icon: "arrow.up.arrow.down")
                        CoordinateDisplay(label: "Longitude", value: String(format: "%.6f", coordinate.longitude), icon: "arrow.left.arrow.right")
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

    private func updateMapPosition() {
        guard let coord = locationProvider.currentCoordinate else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            mapPosition = .camera(.init(
                centerCoordinate: coord,
                distance: locationProvider.mapDistance
            ))
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
                Image(systemName: icon).font(.system(size: 10))
                Text(label).font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.tertiarySystemBackground)))
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
            iconColor: .orange,
            title: "Deep Links",
            subtitle: "URL scheme testing",
            isActive: deepLinkURL != nil,
            showAnimation: showAnimation
        ) {
            if let url = deepLinkURL {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Received URL")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)

                        Text(url.absoluteString)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.orange)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.08)))
                    }

                    if let params = deepLinkParams, !params.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Parameters")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)

                            ForEach(params.sorted(by: <), id: \.key) { key, value in
                                HStack {
                                    Text(key)
                                        .font(.system(size: 13, weight: .semibold))
                                    Spacer()
                                    Text(value)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.tertiarySystemBackground)))
                            }
                        }
                    }
                }
            } else {
                EmptyStateView(icon: "link.badge.plus", text: "Send a deep link from CosmoKit")
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
            iconColor: CosmoTheme.accentPink,
            title: "Push Notifications",
            subtitle: "APNS payload testing",
            isActive: title != nil || message != nil,
            showAnimation: showAnimation
        ) {
            if let pushTitle = title, let pushBody = message {
                VStack(alignment: .leading, spacing: 12) {
                    // iOS-style notification preview
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
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(UIColor.tertiarySystemBackground)))

                    if let payload = payload, !payload.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Custom Payload")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(formatPayload(payload))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(CosmoTheme.accentPink)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 10).fill(CosmoTheme.accentPink.opacity(0.08)))
                        }
                    }
                }
            } else {
                EmptyStateView(icon: "bell.slash", text: "Send a push notification from CosmoKit")
            }
        }
    }
}

// MARK: - Network Proxy Test Card

private let networkLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmoKitTestApp", category: "NetworkProxy")

struct NetworkProxyTestCard: View {
    @State private var results: [NetworkResult] = []

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
            subtitle: "Request interception & mocking",
            isActive: !results.isEmpty,
            showAnimation: false
        ) {
            VStack(spacing: 12) {
                // Request buttons grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    RequestButton(label: "GET", color: .blue) {
                        await fireRequest(method: "GET", urlString: "https://httpbin.org/get")
                    }
                    RequestButton(label: "POST", color: .green) {
                        await fireRequest(method: "POST", urlString: "https://httpbin.org/post")
                    }
                    RequestButton(label: "PUT", color: .orange) {
                        await fireRequest(method: "PUT", urlString: "https://httpbin.org/put")
                    }
                    RequestButton(label: "404", color: .red) {
                        await fireRequest(method: "GET", urlString: "https://httpbin.org/status/404")
                    }
                    RequestButton(label: "500", color: .purple) {
                        await fireRequest(method: "GET", urlString: "https://httpbin.org/status/500")
                    }
                    RequestButton(label: "JSON", color: .teal) {
                        await fireRequest(method: "GET", urlString: "https://httpbin.org/json")
                    }
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

                // Results
                if !results.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Recent Requests")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Clear") { withAnimation { results.removeAll() } }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.teal)
                        }

                        ForEach(results.prefix(5)) { result in
                            HStack(spacing: 8) {
                                Text(result.method)
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5).padding(.vertical, 2)
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
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 8).fill(result.isError ? Color.red.opacity(0.06) : Color(UIColor.tertiarySystemBackground)))
                        }
                    }
                }
            }
        }
    }

    private func fireRequest(method: String, urlString: String) async {
        let start = Date()
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
            networkLogger.info("\(method) \(urlString) -> \(httpResponse?.statusCode ?? 0) (\(durationStr))")
            let result = NetworkResult(method: method, url: URL(string: urlString)?.path ?? urlString, statusCode: httpResponse?.statusCode, size: sizeStr, duration: durationStr, isError: (httpResponse?.statusCode ?? 0) >= 400)
            withAnimation { results.insert(result, at: 0) }
        } catch {
            let elapsed = Date().timeIntervalSince(start)
            let durationStr = elapsed < 1 ? String(format: "%.0fms", elapsed * 1000) : String(format: "%.1fs", elapsed)
            let result = NetworkResult(method: method, url: URL(string: urlString)?.path ?? urlString, statusCode: nil, size: "-", duration: durationStr, isError: true)
            withAnimation { results.insert(result, at: 0) }
        }
    }

    private func methodColor(_ method: String) -> Color {
        switch method {
        case "GET": return .blue; case "POST": return .green; case "PUT": return .orange; case "DELETE": return .red; default: return .gray
        }
    }

    private func statusColor(_ code: Int) -> Color {
        switch code {
        case 200..<300: return .green; case 300..<400: return .orange; case 400..<500: return .red; case 500...: return .purple; default: return .secondary
        }
    }
}

// MARK: - Simulator Tools Card

struct SimulatorToolsCard: View {
    @State private var currentAppearance = "System"

    var body: some View {
        FeatureCard(
            icon: "wrench.and.screwdriver.fill",
            iconColor: .indigo,
            title: "Simulator Tools",
            subtitle: "Appearance, status bar, permissions",
            isActive: true,
            showAnimation: false
        ) {
            VStack(spacing: 12) {
                // Appearance info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Environment")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        InfoChip(icon: "paintbrush.fill", label: "Appearance", value: UITraitCollection.current.userInterfaceStyle == .dark ? "Dark" : "Light")
                        InfoChip(icon: "textformat.size", label: "Text Size", value: UIApplication.shared.preferredContentSizeCategory.rawValue.replacingOccurrences(of: "UICTContentSizeCategory", with: ""))
                        InfoChip(icon: "iphone.gen3", label: "Device", value: UIDevice.current.name)
                        InfoChip(icon: "gear", label: "iOS", value: UIDevice.current.systemVersion)
                    }
                }

                // Feature checklist
                VStack(alignment: .leading, spacing: 6) {
                    Text("CosmoKit can control")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        ToolBadge(icon: "moon.fill", text: "Dark Mode", color: .indigo)
                        ToolBadge(icon: "wifi", text: "Status Bar", color: .blue)
                        ToolBadge(icon: "faceid", text: "Face ID", color: .green)
                    }
                    HStack(spacing: 8) {
                        ToolBadge(icon: "key.fill", text: "Keychain", color: .orange)
                        ToolBadge(icon: "doc.on.clipboard", text: "Pasteboard", color: .teal)
                        ToolBadge(icon: "photo", text: "Media", color: .pink)
                    }
                }
            }
        }
    }
}

struct InfoChip: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.indigo)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.tertiarySystemBackground)))
    }
}

struct ToolBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10))
            Text(text).font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8).padding(.vertical, 5)
        .background(color.opacity(0.1), in: Capsule())
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Log Stream Test Card

private let logStreamLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmoKitTestApp", category: "LogStreamTest")

struct LogStreamTestCard: View {
    @State private var logCount = 0

    var body: some View {
        FeatureCard(
            icon: "text.alignleft",
            iconColor: .green,
            title: "Log Stream",
            subtitle: "Real-time log monitoring",
            isActive: logCount > 0,
            showAnimation: false
        ) {
            VStack(spacing: 10) {
                Text("Emit logs visible in CosmoKit's Log Stream viewer")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    LogButton(label: "Info", color: .blue) {
                        logStreamLogger.info("Info log at \(Date().formatted(date: .omitted, time: .standard))")
                        logCount += 1
                    }
                    LogButton(label: "Warning", color: .orange) {
                        logStreamLogger.warning("Warning log at \(Date().formatted(date: .omitted, time: .standard))")
                        logCount += 1
                    }
                    LogButton(label: "Error", color: .red) {
                        logStreamLogger.error("Error log at \(Date().formatted(date: .omitted, time: .standard))")
                        logCount += 1
                    }
                }

                if logCount > 0 {
                    Text("\(logCount) log\(logCount == 1 ? "" : "s") emitted")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.08)))
                }
            }
        }
    }
}

// MARK: - Shared Components

struct EmptyStateView: View {
    let icon: String
    let text: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.4))
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
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
                .background(color.opacity(0.08))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
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
                .background(color.opacity(0.08))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Utilities

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

private let locationLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmoKitTestApp", category: "Location")

final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var statusMessage: String = "Requesting location..."
    @Published var trail: [CLLocationCoordinate2D] = []
    @Published var isMoving = false

    /// Camera distance that fits the trail nicely
    var mapDistance: Double {
        guard isMoving, trail.count >= 2,
              let first = trail.first, let last = trail.last else {
            return 1500  // static location: ~1.5km view
        }
        // Haversine distance between first and last trail point
        let R = 6_371_000.0
        let dLat = (last.latitude - first.latitude) * .pi / 180
        let dLon = (last.longitude - first.longitude) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(first.latitude * .pi / 180) * cos(last.latitude * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        let meters = R * 2 * atan2(sqrt(a), sqrt(1 - a))
        // Camera distance ~4x the trail span, with min/max bounds
        return max(800, min(meters * 4, 50_000))
    }

    private let manager = CLLocationManager()
    private var lastUpdateTime: Date?
    private var movementTimer: Timer?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func start() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .restricted, .denied: statusMessage = "Location access denied. Enable in Settings."
        case .authorizedWhenInUse, .authorizedAlways: manager.startUpdatingLocation()
        @unknown default: statusMessage = "Unknown authorization state."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { start() }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationLogger.info("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        DispatchQueue.main.async {
            let coord = location.coordinate

            // Detect movement
            if let prev = self.currentCoordinate {
                let dLat = abs(coord.latitude - prev.latitude)
                let dLon = abs(coord.longitude - prev.longitude)
                if dLat > 0.00001 || dLon > 0.00001 {
                    // Large jump (> ~500m) = new location/route, clear trail
                    if dLat > 0.005 || dLon > 0.005 {
                        self.trail = [coord]
                    } else {
                        self.trail.append(coord)
                        // Short tail: keep only last 15 points
                        if self.trail.count > 15 { self.trail.removeFirst() }
                    }
                    self.isMoving = true
                    self.resetMovementTimer()
                }
            } else {
                self.trail = [coord]
            }

            self.currentCoordinate = coord
            self.statusMessage = self.isMoving ? "Route in progress..." : "Location updated."
        }
    }

    private func resetMovementTimer() {
        movementTimer?.invalidate()
        movementTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isMoving = false
                self?.statusMessage = "Location updated."
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationLogger.error("Location failed: \(error.localizedDescription)")
        DispatchQueue.main.async { self.statusMessage = "Failed: \(error.localizedDescription)" }
    }
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return nil }
        var parameters = [String: String]()
        for item in queryItems { parameters[item.name] = item.value }
        return parameters.isEmpty ? nil : parameters
    }
}

private func formatPayload(_ payload: [String: Any]) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]),
          let string = String(data: data, encoding: .utf8) else { return "\(payload)" }
    return string
}

private func extractCustomPayload(from rawPayload: [String: Any]) -> [String: Any]? {
    if let data = rawPayload["data"] as? [String: Any], !data.isEmpty { return data }
    var sanitized = rawPayload
    sanitized.removeValue(forKey: "aps")
    return sanitized.isEmpty ? nil : sanitized
}

#Preview {
    ContentView()
}
