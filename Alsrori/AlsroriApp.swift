import SwiftUI
import UserNotifications
import OneSignalFramework

@main
struct AlsroriApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // 1. OneSignal Initialization with Alsrori OneSignal App ID
        OneSignal.initialize("e67e683b-fba8-4f63-9935-c641b134a400", withLaunchOptions: launchOptions)
        
        // 2. Request Native iOS Push Notification Permissions (Alerts, Badges, Sounds)
        // Prompts the standard Apple iOS system permission dialog outside the app
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
        
        // 4. Handle Notification Clicks (When user taps notification outside app on lock screen / banner)
        OneSignal.Notifications.addClickListener { event in
            let notification = event.notification
            print("OneSignal Notification Clicked: \(notification.title ?? "")")
            
            var targetUrl: String? = nil
            if let launchUrl = notification.launchURL, !launchUrl.isEmpty {
                targetUrl = launchUrl
            } else if let customData = notification.additionalData as? [String: Any] {
                if let url = customData["url"] as? String, !url.isEmpty {
                    targetUrl = url
                } else if let link = customData["link"] as? String, !link.isEmpty {
                    targetUrl = link
                }
            }
            
            if let targetUrl = targetUrl {
                // Normalize custom app schemes like sngine:// or sngine_timeline:// to https://alsrori.com/
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
        }
        
        // 5. Observe OneSignal Subscription updates
        OneSignal.User.pushSubscription.addObserver(self)
        
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Successfully registered APNs token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

// Observe OneSignal Subscription changes
extension AppDelegate: OSPushSubscriptionObserver {
    func onPushSubscriptionDidChange(state: OSPushSubscriptionChangedState) {
        if let subId = state.current.id, !subId.isEmpty {
            print("OneSignal Subscription ID updated: \(subId)")
            NotificationCenter.default.post(
                name: NSNotification.Name("AlsroriOneSignalSubscribed"),
                object: subId
            )
        }
    }
}
