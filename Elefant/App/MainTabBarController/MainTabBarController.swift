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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timelineViewController = TimelineViewController()
        
        timelineViewController.tabBarItem = UITabBarItem(title: "Timeline", image: UIImage(systemName: "newspaper"), selectedImage: UIImage(systemName: "newspaper.fill"))
        timelineViewController.tabBarItem.tag = Tab.timeline.rawValue
        
        setViewControllers([timelineViewController], animated: true)
    }
}
