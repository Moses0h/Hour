//
//  StartViewController.swift
//  Hour
//
//  Created by Moses Oh on 9/5/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GeoFire
import CoreLocation

class StartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppDelegate.THEME
        checkIfUserIsLoggedIn()

    }
    
    func checkIfUserIsLoggedIn() {
        let users = Database.database().reference().child("users")
        if(Auth.auth().currentUser != nil)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                users.observeSingleEvent(of: .value) { (users) in
                    if(users.hasChild(Auth.auth().currentUser!.uid))
                    {
                        print("passed")
                        let customTabBarController = CustomTabBarController()
                        AppDelegate.controller?.window?.rootViewController = customTabBarController
                        
                    }
                    else
                    {
                        self.perform(#selector(self.handleLogout), with: nil, afterDelay: 0)
                    }
                }
            }
        }
        else
        {
            self.perform(#selector(self.handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
}
