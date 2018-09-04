//
//  CustomTabBarController.swift
//  Hour
//
//  Created by Moses Oh on 2/25/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//
import UIKit
import Foundation

class CustomTabBarController: UITabBarController{
    static var controller: CustomTabBarController?
    
    var pastIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomTabBarController.controller = self
        
        let feedController = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        FeedController.controller = feedController
        let feedNavigationController = UINavigationController(rootViewController: feedController)
        feedNavigationController.title = "Feed"
        feedNavigationController.tabBarItem.image = #imageLiteral(resourceName: "feed")
        
        let messagesController = MessagesController(nibName: nil, bundle: nil)
        MessagesController.controller = messagesController
        let messagesNavigationController = UINavigationController(rootViewController: messagesController)
        messagesNavigationController.title = "Messages"
        messagesNavigationController.tabBarItem.image = #imageLiteral(resourceName: "messages")

        let notificationController = NotificationController(nibName: nil, bundle: nil)
        NotificationController.controller = notificationController
        let notificationNavigationController = UINavigationController(rootViewController: notificationController)
        notificationNavigationController.title = "Notification"
        notificationNavigationController.tabBarItem.image = #imageLiteral(resourceName: "notification")

        let profileController = ProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        ProfileController.controller = profileController
        let profileNavigationController = UINavigationController(rootViewController: profileController)
        profileNavigationController.title = "Profile"
        profileNavigationController.tabBarItem.image = #imageLiteral(resourceName: "profile")

        viewControllers = [feedNavigationController, messagesNavigationController, notificationNavigationController, profileNavigationController]
        tabBar.isTranslucent = false
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor.init(r: 229, g: 231, b: 235).cgColor
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = tabBar.items?.index(of: item)        
        switch index {
        case 0:
            if(index == pastIndex)
            {
                let cv_attribute = FeedController.controller?.collectionView?.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: IndexPath.init(item: 0, section: 0))
                if(cv_attribute != nil)
                {
                    FeedController.controller?.collectionView?.scrollRectToVisible((cv_attribute?.frame)!, animated: true)
                }
            }
        case 1:
            break
        case 2:
            break
        case 3:
            if(index == pastIndex)
            {
                let cv_attribute = ProfileController.controller?.collectionView?.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: IndexPath.init(item: 0, section: 0))
                if(cv_attribute != nil)
                {
                    ProfileController.controller?.collectionView?.scrollRectToVisible((cv_attribute?.frame)!, animated: true)
                }
            }
        default:
            break
            
        }
        pastIndex = index!

    }
    
}

