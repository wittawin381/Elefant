//
//  SessionManager.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 4/4/2568 BE.
//

import Foundation

@MainActor protocol SessionManagerDelegate: AnyObject {
    func sessionManager(_ sessionManager: ProfileController, didStartWith profile: Profile)
    func sessionManager(_ sessionManager: ProfileController, didFailToStart profile: Profile)
    func sessionManager(_ sessionManager: ProfileController, didChangeActiveProfile profile: Profile?)
}

class SessionManager {
    weak var delegate: SessionManagerDelegate?
}
