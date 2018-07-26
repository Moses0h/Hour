//
//  Group.swift
//  Hour
//
//  Created by Moses Oh on 3/26/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Group {
    
    
    var groupName: String?
    var lastMessage: String?
    var uid: String?
    var lastUser: String?
    var timestamp: Double?
    
    
    init(uid: String) {
        self.uid = uid
        let groupRef = Database.database().reference().child("groups").child(uid)
        groupRef.observeSingleEvent(of: .value) { (_snapshot) in
            if let dictionary = _snapshot.value as? [String: AnyObject] {
                
                self.groupName = dictionary["name"] as? String
                self.lastMessage = dictionary["last message"] as? String
                self.timestamp = dictionary["timestamp"] as? Double
                
            }
        }
    }
}
