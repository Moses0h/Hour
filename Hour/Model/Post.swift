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
    var usersUid = [String: AnyObject]()
    var name: String!
    var activity: String!
    var description: String!
    var location: String!
    var date: String!
    var startTime: String!
    var endTime: String!
    var groupCount: Int!
    var distance: Double!
    var category: String!
    var time: Double!
    var imageUrl: String!
    
    init(snapshot: DataSnapshot){
        
        if let dictionary = snapshot.value as? [String: AnyObject] {
            
            key = snapshot.key
            if(snapshot.hasChild("usersUid"))
            {
                usersUid = dictionary["usersUid"] as! [String: AnyObject]
                print(usersUid)
            }

            name = dictionary["name"] as? String
            activity = dictionary["activity"] as? String
            description = dictionary["description"] as? String
            location = dictionary["location"] as? String
            date = dictionary["date"] as? String
            startTime = dictionary["startTime"] as? String
            endTime = dictionary["endTime"] as? String
            groupCount = dictionary["groupCount"] as? Int
            category = dictionary["category"] as? String
            time = dictionary["time"] as? Double
            imageUrl = dictionary["imageUrl"] as? String
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
