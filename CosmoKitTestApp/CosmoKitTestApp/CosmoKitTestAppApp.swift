//
//  CosmoKitTestAppApp.swift
//  CosmoKitTestApp
//
//  Created by Matheus Weber on 01/12/25.
//

import SwiftUI
import UserNotifications
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmoKitTestApp", category: "AppDelegate")

@main
struct CosmoKitTestAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        logger.info("App launched")
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                logger.error("Notification auth error: \(error.localizedDescription)")
            }
            if granted {
                logger.info("Notification authorization granted")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                logger.warning("Notification authorization denied")
            }
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        logger.info("Registered for remote notifications — token: \(tokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        logger.info("Push received (foreground) — title: \"\(content.title)\" body: \"\(content.body)\"")
        postNotificationDetails(from: content)
        completionHandler([.banner, .sound, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        logger.info("Push tapped — title: \"\(content.title)\" body: \"\(content.body)\"")
        postNotificationDetails(from: content)
        completionHandler()
    }

    private func postNotificationDetails(from content: UNNotificationContent) {
        NotificationCenter.default.post(name: .cosmoKitPushReceived, object: nil, userInfo: [
            "title": content.title,
            "body": content.body,
            "userInfo": content.userInfo
        ])
    }
}

extension Notification.Name {
    static let cosmoKitPushReceived = Notification.Name("CosmoKitPushReceived")
}
