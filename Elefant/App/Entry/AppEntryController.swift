//
//  AppEntryController.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 2/4/2568 BE.
//

import Foundation
import UIKit

class AppEntryController: UINavigationController, FlowController {
    var rootNavigationController: UINavigationController { self }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.SessionManagerDidSelectActiveProfile,
            object: nil,
            queue: .main,
            using: handleSessionDidSelectActiveProfile
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.SessionManagerDidFailToSelectActiveProfile,
            object: nil,
            queue: .main,
            using: handleSessionDidFailToSelectProfile
        )
    }
    
    nonisolated private func handleSessionDidSelectActiveProfile(notification: Notification) {
        let profile = notification.userInfo?[kSessionProfileNotificationDataKey] as? Profile
        Task { @MainActor in
            if let profile {
                handleProfileChanged(profile: profile)
            }
        }
    }
    
    private func handleProfileChanged(profile: Profile) {
        print(profile)
        let viewController = MainTabBarController()
        self.setViewControllers([viewController], animated: true)
        dismiss(animated: true)
    }
    
    nonisolated func handleSessionDidFailToSelectProfile(notification: Notification) {
        Task { await handleProfileFailToSelect() }
    }
    
    private func handleProfileFailToSelect() {
        popToRootViewController(animated: true)
        let onboardingFlow = OnboardingFlowController()
        onboardingFlow.modalPresentationStyle = .fullScreen
        onboardingFlow.start(on: self)
    }
}
