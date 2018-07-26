//
//  CustomTabBarController.swift
//  Hour
//
//  Created by Moses Oh on 2/25/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//
import UIKit
import Foundation

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let feedController = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let feedNavigationController = UINavigationController(rootViewController: feedController)
        feedNavigationController.title = "News Feed"
        feedNavigationController.tabBarItem.image = UIImage()
        
        let messagesController = MessagesController()
        let messagesNavigationController = UINavigationController(rootViewController: messagesController)
        messagesNavigationController.title = "Messages"
        messagesNavigationController.tabBarItem.image = UIImage()
        
        let notificationController = NotificationController()
        let notificationNavigationController = UINavigationController(rootViewController: notificationController)
        notificationNavigationController.title = "Notification"
        notificationNavigationController.tabBarItem.image = UIImage()
        
        let settingController = SettingController()
        let settingNavigationController = UINavigationController(rootViewController: settingController)
        settingNavigationController.title = "Setting"
        settingNavigationController.tabBarItem.image = UIImage()
        
        viewControllers = [feedNavigationController, messagesNavigationController, notificationNavigationController, settingNavigationController]
        tabBar.isTranslucent = false
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor.init(r: 229, g: 231, b: 235).cgColor
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
    }
    
}
