//
//  AppDelegate.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 27/3/2568 BE.
//

import UIKit
import CoreData
import ElefantAPI

let kSessionProfileNotificationDataKey = "session_profile_notification_key"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var environment: AppEnvironment = .anonymous

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        environment.profileController.delegate = self
        Task {
            await environment.profileController.loadProfile()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Elefant")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: ProfileControllerDelegate {
    func profileController(_ profileController: ProfileController, didSelectActiveProfile profile: Profile) {
        environment = .signedIn(
            client: ElefantClient(
                session: URLSession.shared,
                server: ElefantClient.Server(domain: profile.domain),
                middlewares: .init(middlewares: [
                    OauthMiddleware(profileController: profileController)
                ])))
            NotificationCenter.default.post(
            name: NSNotification.Name.SessionManagerDidSelectActiveProfile,
            object: nil,
            userInfo: [kSessionProfileNotificationDataKey: profile])
    }
    
    func profileControllerDidFailToSelectActiveProfile(_ profileController: ProfileController) {
        NotificationCenter.default.post(
            name: NSNotification.Name.SessionManagerDidFailToSelectActiveProfile,
            object: nil)
    }
}

extension NSNotification.Name {
    static let SessionManagerDidSelectActiveProfile = NSNotification.Name("session_manager_did_change_active_profile")
    static let SessionManagerDidFailToSelectActiveProfile = NSNotification.Name("session_manager_did_faile_to_select_active_profile")
}
