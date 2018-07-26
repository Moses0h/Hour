//
//  Message.swift
//  Hour
//
//  Created by Moses Oh on 3/19/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var message: String?
    var timestamp: Double?
//    var toId: String?
    
//    func chatPartnerId() -> String? {
//        if fromId == Auth.auth().currentUser?.uid {
//            return (toId)
//        }
//        else {
//            return (fromId)
//        }
//    }
    
    init(snapshot: DataSnapshot) {
        if let dictionary = snapshot.value as? [String: AnyObject] {
            
            fromId = dictionary["fromId"] as? String
            message = dictionary["message"] as? String
            timestamp = dictionary["timestamp"] as? Double

        }
    }
}
