//
//  AcceptButton.swift
//  Hour
//
//  Created by Moses Oh on 8/18/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import Firebase

class AcceptButton: UIButton {
    
    var enabledChat: Bool?
    var userUid: String?
    var postUid: String?
    var index: Int?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 1.01, y:1.01)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
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
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
    }
    
    @objc func handleAccept() {
        let users_uid_posts = Database.database().reference().child("users").child(userUid!).child("posts")
        
        //make sure the other user is still in request state
        users_uid_posts.observeSingleEvent(of: .value) { (snapshot) in
            if(snapshot.hasChild(self.postUid!))
            {
                let postValue = [self.postUid!: 1]
                users_uid_posts.updateChildValues(postValue) { (err, ref) in
                    NotificationController.controller?.notifications.remove(at: self.index!)
                    NotificationController.controller?.tableView.reloadData()
                }
                let posts_uid_usersUid = Database.database().reference().child("posts").child(self.postUid!).child("usersUid")
                let userValue = [self.userUid! : 1]
                posts_uid_usersUid.updateChildValues(userValue)
                
                if(self.enabledChat)!
                {
                    let users_uid_group = Database.database().reference().child("users").child(self.userUid!).child("groups")
                    let groupValue = [self.postUid!: 1]
                    users_uid_group.updateChildValues(groupValue)
                    
                    let groups_uid_users = Database.database().reference().child("groups").child(self.postUid!).child("users")
                    let usersValue = [self.userUid!: 1]
                    groups_uid_users.updateChildValues(usersValue)
                }
            }
            else
            {
                NotificationController.controller?.notifications.remove(at: self.index!)
                NotificationController.controller?.tableView.reloadData()
            }
        }
    }
}
