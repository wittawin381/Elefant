//
//  SessionManager.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 4/4/2568 BE.
//

import Foundation
import ElefantAPI

@MainActor protocol SessionManagerDelegate: AnyObject {
    func sessionManager(_ sessionManager: ProfileController, didStartWith profile: Profile)
    func sessionManager(_ sessionManager: ProfileController, didFailToStart profile: Profile)
    func sessionManager(_ sessionManager: ProfileController, didChangeActiveProfile profile: Profile?)
}

@MainActor protocol AppEnvironmentDataProvider {
    var profileController: ProfileController { get }
    var client: any NetworkClient { get }
}

@MainActor struct AppEnvironment: AppEnvironmentDataProvider {
    private static let anonymousClient = ElefantClient(
        session: URLSession.shared,
        server: ElefantClient.Server(domain: "mastodon.social"),
        middlewares: MiddlewareGroup(middlewares: []))
    
    private static var defaultProfileController: ProfileController = {
        let profileController = ProfileController(keychain: Keychain(), userDefaults: UserDefaults(suiteName: "suite.com.wittawin.Elefant") ?? UserDefaults.standard)
        
        return profileController
    } ()
    
    let client: any NetworkClient
    let profileController: ProfileController
    let timelineDataSource: TimelineAsyncDataSource
    
    init(client: any NetworkClient, profileController: ProfileController = defaultProfileController) {
        self.client = client
        self.profileController = profileController
        self.timelineDataSource = TimelineAsyncDataSource()
    }
}

extension AppEnvironment {
    static let anonymous: AppEnvironment = AppEnvironment(
        client: anonymousClient)
    
    static func signedIn(client: any NetworkClient) -> AppEnvironment {
        AppEnvironment(client: client)
    }
}

class SessionManager {
    weak var delegate: SessionManagerDelegate?
}
