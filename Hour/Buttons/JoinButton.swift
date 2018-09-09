//
//  JoinButton.swift
//  Hour
//
//  Created by Moses Oh on 7/27/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class JoinButton: UIButton {
    var isOn = false
    enum status {
        case privateJoin
        case privateJoined
        case host
        case requested
        case publicJoin
        case publicJoined
        case full
        case unknown
    }
    
    var inFeedView: Bool?
    var postKey: String?
    var index: Int?
    var privateEnabled: Int?
    var chatEnabled: Int?
    var currentStatus: status = status.unknown
    var ref = Database.database().reference()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 1.1, y:1.1)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
        super.touchesBegan(touches, with: event)
        self.adjustsImageWhenHighlighted = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 18)!
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func buttonPressed() {
        print("pressed")
        let uid = (Auth.auth().currentUser?.uid)!
        switch currentStatus {
        case .host:
            break
        case .privateJoin:
            setUserStatus(stat: .requested)
            var imageUrl = ""
            
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid").child(uid)
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    imageUrl = dictionary["imageUrl"] as! String
                    let value = ["status": 0, "imageUrl": imageUrl] as [String: Any]
                    ref.updateChildValues(value)
                    if(self.inFeedView)!
                    {
                        FeedController.controller?.posts[self.index!].usersUid[uid] = value as AnyObject
                    }
                    else
                    {
                        ProfileController.controller?.posts[self.index!].usersUid[uid] = value as AnyObject
                    }
                }
            }
            let userRef = Database.database().reference().child("users").child(uid).child("posts")
            let userValue = [postKey!: 0] as [String: Any]
            userRef.updateChildValues(userValue)
            break
        case .privateJoined:
            setUserStatus(stat: .privateJoin)
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid").child(uid)
            let userRef = Database.database().reference().child("users").child(uid).child("posts").child(postKey!)
            
            let groupRef = Database.database().reference().child("users").child(uid).child("groups").child(postKey!)
            
            ref.removeValue()
            userRef.removeValue()
            groupRef.removeValue { (err, ref) in
                if(self.inFeedView)!
                {
                    FeedController.controller?.posts[self.index!].usersUid.removeValue(forKey: uid)
                }
                else
                {
                    ProfileController.controller?.posts[self.index!].usersUid.removeValue(forKey: uid)
                }
            }
            
            break
        case .requested:
            setUserStatus(stat: .privateJoin)
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid").child(uid)
            let userRef = Database.database().reference().child("users").child(uid).child("posts").child(postKey!)
            
            let groupRef = Database.database().reference().child("users").child(uid).child("groups").child(postKey!)

            ref.removeValue()
            userRef.removeValue()
            groupRef.removeValue { (err, ref) in
                if(self.inFeedView)!
                {
                    FeedController.controller?.posts[self.index!].usersUid.removeValue(forKey: uid)
                }
                else
                {
                    ProfileController.controller?.posts[self.index!].usersUid.removeValue(forKey: uid)
                }
            }
            break
        case .publicJoin:
            setUserStatus(stat: .publicJoined)
            var imageUrl = ""
            
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid").child(uid)
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    imageUrl = dictionary["imageUrl"] as! String
                    let value = ["status": 1, "imageUrl": imageUrl] as [String: Any]
                    ref.updateChildValues(value)
                    if(self.inFeedView)!
                    {
                        FeedController.controller?.posts[self.index!].usersUid[uid] = value as AnyObject
                    }
                    else
                    {
                        ProfileController.controller?.posts[self.index!].usersUid.removeValue(forKey: uid)
                    }
                }
            }
            let users_uid_group = Database.database().reference().child("users").child(uid).child("groups")
            let groupValue = [postKey!: 1]
            users_uid_group.updateChildValues(groupValue)
            
            let groups_uid_users = Database.database().reference().child("groups").child(uid).child("users")
            let usersValue = [postKey!: 1]
            groups_uid_users.updateChildValues(usersValue)
            
            let userRef = Database.database().reference().child("users").child(uid).child("posts")
            let userValue = [postKey!: 1] as [String: Any]
            userRef.updateChildValues(userValue)
        case .publicJoined:
            setUserStatus(stat: .publicJoin)
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid").child(uid)
            let userRef = Database.database().reference().child("users").child(uid).child("posts").child(postKey!)
            
            let groupRef = Database.database().reference().child("users").child(uid).child("groups").child(postKey!)
            
            ref.removeValue()
            userRef.removeValue()
            groupRef.removeValue { (err, ref) in
                if(self.inFeedView)!
                {
                    FeedController.controller?.posts[self.index!].usersUid.removeValue(forKey: uid)
                }
                else
                {
                    ProfileController.controller?.posts[self.index!].usersUid.removeValue(forKey: uid)
                }
            }
            
            break
        case .full:
            break
        case .unknown:
            break
        }
    }
    
//    @objc func buttonPressed() {
//        print("hello")
//        activatedButton(bool: !isOn)
//    }
    
    func activatedButton(bool: Bool) {
        isOn = bool
        let background = bool ? UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1) : UIColor(white: 0.95, alpha: 1)
        let text = bool ? UIColor.white : UIColor.gray
//        if(bool){
//            postController?.childUpdates.updateValue(true, forKey: (titleLabel?.text)!)
//        }
//        else{
//            postController?.childUpdates.removeValue(forKey: (titleLabel?.text)!)
//        }
        backgroundColor = background
        setTitleColor(text, for: .normal)
    }
    
    func setUserStatus(stat: status) {
        switch stat {
        case .host:
            setTitleColor(UIColor.lightGray, for: .normal)
//            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Owner", for: .normal)
            isUserInteractionEnabled = false
            currentStatus = .host
            break
        case .full:
            setTitleColor(UIColor.lightGray, for: .normal)
            //            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Full", for: .normal)
            isUserInteractionEnabled = false
            currentStatus = .full
            break
        case .privateJoin:
            setTitleColor(UIColor.darkGray, for: .normal)
//            backgroundColor = UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
            setTitle("Join", for: .normal)
            currentStatus = .privateJoin
            isUserInteractionEnabled = true
            break
        case .privateJoined:
            setTitleColor(UIColor.darkGray, for: .normal)
//            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Joined", for: .normal)
            currentStatus = .privateJoined
            isUserInteractionEnabled = true
            break
        case .requested:
            setTitleColor(UIColor.darkGray, for: .normal)
//            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Requested", for: .normal)
            currentStatus = .requested
            isUserInteractionEnabled = true
            break
        case .publicJoin:
            setTitleColor(UIColor.darkGray, for: .normal)
            //            backgroundColor = UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
            setTitle("Join", for: .normal)
            currentStatus = .publicJoin
            isUserInteractionEnabled = true
            break
        case .publicJoined:
            setTitleColor(UIColor.darkGray, for: .normal)
            //            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Joined", for: .normal)
            currentStatus = .publicJoined
            isUserInteractionEnabled = true
            break
        case .unknown:
            currentStatus = .unknown
            break
        }
    }

    
    
}
