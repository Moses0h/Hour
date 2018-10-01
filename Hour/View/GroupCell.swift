//
//  UserCell.swift
//  Hour
//
//  Created by Moses Oh on 3/19/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GroupCell: UITableViewCell {
    
    var group: Group? {
        didSet {
            setupNameAndProfileImage()
        }
    }
    
    private func setupNameAndProfileImage() {
        
//        if let id = message?.chatPartnerId() {
//            let ref = Database.database().reference().child("users").child(id)
//            ref.observeSingleEvent(of: .value, with: { (snapshot) in
//                if let dictionary = snapshot.value as? [String: AnyObject]
//                {
//                    self.textLabel?.text = dictionary["name"] as? String
//
//                    if (dictionary["profileImageUrl"] as? String) != nil
//                    {
//                        //                        cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//                    }
//                }
//            })
//        }
        
        
        self.textLabel?.text = self.group?.groupName
        self.detailTextLabel?.text = ""
        if group?.lastMessage != nil {
            
        var message = ""
        let messageRef = Database.database().reference().child("group-messages").child((group?.uid)!).child((group?.lastMessage!)!)
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary1 = snapshot.value as? [String: AnyObject] {
                message = dictionary1["message"] as! String
                
                let userRef = Database.database().reference().child("users").child(dictionary1["fromId"] as! String)
                userRef.observeSingleEvent(of: .value, with: { (snap) in
                    if let dictionary2 = snap.value as? [String: AnyObject]
                    {
                        self.detailTextLabel?.text = dictionary2["name"] as! String + ": " + message
                    }
                })
            }
        })
        }
        
        let postRef = Database.database().reference().child("posts").child((group?.uid)!)
        postRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.eventImageView.loadImageUsingCache(urlString: dictionary["imageUrl"] as! String)
            }
        }
        
        if let seconds = group?.timestamp {
            let timestampDate = NSDate(timeIntervalSince1970: TimeInterval(seconds))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            timeLabel.text = dateFormatter.string(from: timestampDate as Date)
        }
        
    }
    let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(eventImageView)
        addSubview(timeLabel)
        
        eventImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        eventImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: (self.textLabel?.topAnchor)!).isActive = true
//        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
//        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 80,y: textLabel!.frame.origin.y - 2,width: textLabel!.frame.width,height: textLabel!.frame.height)

        detailTextLabel?.frame = CGRect(x: 80,y: detailTextLabel!.frame.origin.y + 2,width: detailTextLabel!.frame.width,height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = UIColor.gray
    }
    
   
    
    
}
