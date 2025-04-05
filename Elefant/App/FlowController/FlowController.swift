//
//  FlowController.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 5/4/2568 BE.
//

import Foundation
import UIKit

@MainActor protocol FlowController {
    var rootNavigationController: UINavigationController { get }
    
    func start(on window: UIWindow)
    func start(on viewController: UIViewController)
}

extension FlowController {
    func start(on window: UIWindow) {
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
    }
    
    func start(on viewController: UIViewController) {
        viewController.present(rootNavigationController, animated: true)
    }
}
