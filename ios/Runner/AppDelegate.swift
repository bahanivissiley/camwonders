import UIKit
import Flutter

import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback {(registry) in GeneratedPluginRegistrant.register(with: registry)}

        // Enregistrement des plugins Flutter
        GeneratedPluginRegistrant.register(with: self)

        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Ajout de la gestion des permissions de localisation en arrière-plan
    override func applicationDidEnterBackground(_ application: UIApplication) {
        // Gestion des tâches en arrière-plan si nécessaire
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        // Gestion des tâches lors du retour en premier plan
    }
}