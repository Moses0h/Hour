//
//  User.swift
//  Hour
//
//  Created by Moses Oh on 2/19/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//
import Foundation
import Firebase
import FirebaseDatabase

struct Post {
    
    var key: String!
    var usersUid = [String: Any]()
    var name: String!
    var activity: String!
    var description: String!
    var location: String!
    var time: String!
    var groupCount: Int!
    var distance: Double!
    var category: String!
    
    init(snapshot: DataSnapshot){
        
        if let dictionary = snapshot.value as? [String: AnyObject] {
            
            key = snapshot.key
            if(snapshot.hasChild("usersUid"))
            {
                usersUid = dictionary["usersUid"] as! [String: AnyObject]
            }

            name = dictionary["name"] as? String
            activity = dictionary["activity"] as? String
            description = dictionary["description"] as? String
            location = dictionary["location"] as? String
            time = dictionary["time"] as? String
            groupCount = dictionary["groupCount"] as? Int
            category = dictionary["category"] as? String
        }
    }
    
    
//    init(uid: String, name: String, activity: String, description: String, location: String, time: String, groupCount: Int) {
//
//        self.hostUid = uid
//        self.name = name
//        self.activity = activity
//        self.description = description
//        self.location = location
//        self.time = time
//        self.groupCount = groupCount
//    }
}
