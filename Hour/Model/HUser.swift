//
//  User.swift
//  Hour
//
//  Created by Moses Oh on 3/19/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class HUser: NSObject {
    var name: String?
    var email: String?
    var uid: String?
    
    init(snapshot: DataSnapshot) {
        if let dictionary = snapshot.value as? [String: AnyObject] {
            
            name = dictionary["name"] as? String
            email = dictionary["email"] as? String
            uid = dictionary["uid"] as? String
            
        }
    }
}
