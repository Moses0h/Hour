//
//  DeclineButton.swift
//  Hour
//
//  Created by Moses Oh on 8/24/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import Firebase

class DeclineButton: UIButton {
    
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
        
        addTarget(self, action: #selector(handleDecline), for: .touchUpInside)
    }
    
    @objc func handleDecline() {
        let users_uid_posts = Database.database().reference().child("users").child(userUid!).child("posts").child(self.postUid!)
        users_uid_posts.removeValue()
        
        let posts_uid_usersUid = Database.database().reference().child("posts").child(self.postUid!).child("usersUid").child(self.userUid!)
        posts_uid_usersUid.removeValue { (err, ref) in
            NotificationController.controller?.notifications.remove(at: self.index!)
            NotificationController.controller?.tableView.reloadData()
        }
    }
}
