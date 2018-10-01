//
//  Notification.swift
//  Hour
//
//  Created by Moses Oh on 8/16/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NotificationCell: UITableViewCell
{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var index: Int?
    
    var notification: Notification?
    {
        didSet{
            switch notification?.state {
            case -1:
                currentUserJoined()
                break
            case 0:
                userRequested()
                break
            case 1:
                break
            default:
                break
            }
        }
    }
    
    func currentUserJoined() {
        let posts_uid = Database.database().reference().child("posts").child((notification?.postUid)!)
        posts_uid.observeSingleEvent(of: .value) { (post) in
            if let dictionary = post.value as? [String: AnyObject]
            {
                let activity = dictionary["activity"] as! String
                self.textView.text = "You have joined \(activity)"
            }
        }
    }
    
    func userRequested() {
        acceptButton.userUid = notification?.userUid
        acceptButton.postUid = notification?.postUid
        declineButton.userUid = notification?.userUid
        declineButton.postUid = notification?.postUid
        acceptButton.index = index
        declineButton.index = index
        let users_uid = Database.database().reference().child("users").child(acceptButton.userUid!)
        users_uid.observeSingleEvent(of: .value) { (user) in
            if let dictionary = user.value as? [String: AnyObject]
            {
                let name = dictionary["name"] as! String
                self.textView.text = "\(name) requested to join"
            }
        }
        
        let posts_uid = Database.database().reference().child("posts").child(acceptButton.postUid!)
        posts_uid.observeSingleEvent(of: .value) { (post) in
            if let dictionary = post.value as? [String: AnyObject]
            {
                if(dictionary["enabledChat"] as? Int == 1)
                {
                    self.acceptButton.enabledChat = true
                }
            }
        }
        
        addSubview(declineButton)
        declineButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        declineButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        
        addSubview(acceptButton)
        acceptButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        acceptButton.rightAnchor.constraint(equalTo: declineButton.leftAnchor, constant: -5).isActive = true
    }
    
    let textView: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 18)
        a.textColor = UIColor.darkGray
        a.numberOfLines = 1
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let acceptButton: AcceptButton = {
        let ab = AcceptButton()
        ab.setImage(#imageLiteral(resourceName: "accept"), for: .normal)
        return ab
    }()
    
    let declineButton: DeclineButton = {
        let db = DeclineButton()
        db.setImage(#imageLiteral(resourceName: "decline"), for: .normal)
        return db
    }()
    
    func setupViews() {
        backgroundColor = UIColor.white
        addSubview(textView)
        textView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        textView.rightAnchor.constraint(equalTo: rightAnchor, constant: -50).isActive = true
        
    }
    
}
