import SwiftUI
import UserNotifications
import OneSignalFramework

@main
struct AlsroriApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // 1. OneSignal Native Initialization
        OneSignal.initialize("e67e683b-fba8-4f63-9935-c641b134a400", withLaunchOptions: launchOptions)
        
        // 2. Request Push Notification Permission
        OneSignal.Notifications.requestPermission({ accepted in
            print("OneSignal iOS Push Notification Permission accepted: \(accepted)")
            if accepted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }, fallbackToSettings: true)
        
        // 3. Register for Remote Notifications with Apple APNs
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Foreground notification presentation: Show banners, sounds, and badges even if app is open
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // When notification is tapped by user on Lock Screen or Notification Banner (Native Apple Handler)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        var targetUrl: String? = nil
        if let custom = userInfo["custom"] as? [String: Any], let a = custom["a"] as? [String: Any] {
            if let url = a["url"] as? String, !url.isEmpty {
                targetUrl = url
            } else if let link = a["link"] as? String, !link.isEmpty {
                targetUrl = link
            }
        }
        
        if targetUrl == nil {
            if let url = userInfo["launchURL"] as? String, !url.isEmpty {
                targetUrl = url
            } else if let url = userInfo["url"] as? String, !url.isEmpty {
                targetUrl = url
            }
        }
        
        if let targetUrl = targetUrl {
            var cleanUrl = targetUrl
            if cleanUrl.hasPrefix("sngine://") {
                cleanUrl = cleanUrl.replacingOccurrences(of: "sngine://", with: "https://")
            } else if cleanUrl.hasPrefix("sngine_messenger://") {
                cleanUrl = cleanUrl.replacingOccurrences(of: "sngine_messenger://", with: "https://")
            } else if cleanUrl.hasPrefix("sngine_timeline://") {
                cleanUrl = cleanUrl.replacingOccurrences(of: "sngine_timeline://", with: "https://")
            }
            
            NotificationCenter.default.post(
                name: NSNotification.Name("AlsroriNavigateToURL"),
                object: cleanUrl
            )
        }
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Successfully registered APNs token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
