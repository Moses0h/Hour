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
    
    
    init(uid: String?, groupName: String?, lastMessage: String?, timestamp: Double?) {
        self.uid = uid
        self.groupName = groupName
        self.lastMessage = lastMessage
        self.timestamp = timestamp
    }
}
