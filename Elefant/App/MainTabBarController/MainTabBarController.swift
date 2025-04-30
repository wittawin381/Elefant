//
//  MainTabBarController.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 4/4/2568 BE.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {   
    enum Tab: Int {
        case timeline = 1
        case timelineMock = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timelineViewController = TimelineViewControllerBuilder.build()
        
        timelineViewController.tabBarItem = UITabBarItem(title: "Timeline", image: UIImage(systemName: "text.rectangle.page"), selectedImage: UIImage(systemName: "text.rectangle.page"))
        timelineViewController.tabBarItem.tag = Tab.timeline.rawValue
        let timelineNavigationController = UINavigationController(rootViewController: timelineViewController)

        
        let timelineViewController2 = TimelineViewControllerBuilder.build()
        
        timelineViewController2.tabBarItem = UITabBarItem(title: "Timeline2", image: UIImage(systemName: "newspaper"), selectedImage: UIImage(systemName: "newspaper.fill"))
        timelineViewController2.tabBarItem.tag = Tab.timeline.rawValue
        
        setViewControllers([timelineNavigationController, timelineViewController2 ], animated: true)
    }
}
