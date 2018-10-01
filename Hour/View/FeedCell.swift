//
//  FeedCell.swift
//  Hour
//
//  Created by Moses Oh on 3/19/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FeedCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let dispatchGroup = DispatchGroup()

    var otherUsersViews = [UIButton]()
    
    var inFeedView: Bool? {
        didSet{
            self.deleteButton.inFeedView = inFeedView
            self.joinButton.inFeedView = inFeedView
        }
    }
    var post: Post?
    {
        didSet{
            for user in otherUsersViews {
                user.removeFromSuperview()
            }
            otherUsersViews.removeAll()
            joinButton.privateEnabled = post?.privateEnabled
            joinButton.chatEnabled = post?.chatEnabled
            joinButton.isHidden = false
            if let activity = post?.activity
            {
                activityLabel.text = activity
                activityLabel.isHidden = false
            }
            if let name = post?.name
            {
                profileName.text = name
                profileName.isHidden = false
            }
            if let time = post?.time
            {
                timeSince.text = timeAgoSinceDate(Date(timeIntervalSince1970: (time)/1000))
                timeSince.isHidden = false
            }
            if let location = post?.location
            {
                locationLabel.text = location
                locationLabel.isHidden = false
                locationImage.isHidden = false
            }
            if let date = post?.date
            {
                dateLabel.text = date
                dateLabel.isHidden = false
            }
            if let startTime = post?.startTime, let endTime = post?.endTime
            {
                timeLabel.text = startTime
                timeLabel.text = timeLabel.text! + " - \(endTime)"
                timeLabel.isHidden = false
            }
            if let category = post?.category
            {
                filtersLabel.text = "\(category) • "
            }
            if let groupCount = post?.groupCount
            {
                filtersLabel.text = filtersLabel.text! + "\(groupCount) people • $"
                filtersLabel.isHidden = false
            }
            if let imageUrl = post?.imageUrl
            {
                if(imageUrl != "")
                {
                    self.eventImageView.loadImageUsingCache(urlString: (post?.imageUrl!)!)
                    self.eventImageView.isHidden = false
                }
            }
            if let usersUid = post?.usersUid, let key = post?.key
            {
                let uid : String! = Auth.auth().currentUser?.uid
                var currentGroupCount = 0
                dispatchGroup.enter()
                Database.database().reference().child("posts").child(key).child("usersUid").observeSingleEvent(of: .value) { (snapshot) in
                    currentGroupCount = Int(snapshot.childrenCount)
                    self.dispatchGroup.leave()
                }
                
                dispatchGroup.notify(queue: .main) {
                    if(usersUid[uid] != nil)
                    {
                        if(usersUid[uid]!["status"] as! Int == -1)
                        {
                            self.joinButton.setUserStatus(stat: JoinButton.status.host)
                            self.addSubview(self.deleteButton)
                            self.deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
                            self.deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
                            self.deleteButton.postUid = self.key
                            self.deleteButton.usersUid = usersUid
                            self.deleteButton.setImage(#imageLiteral(resourceName: "decline"), for: .normal)
                            self.deleteButton.isHidden = false
//                            self.deleteButton.addTarget(self, action: #selector(FeedController.controller?.handleDelete), for: .touchUpInside)
                        }
                        else if(usersUid[uid]!["status"] as! Int == 1 && self.post?.privateEnabled == 1)
                        {
                            self.joinButton.setUserStatus(stat: JoinButton.status.privateJoined)
                        }
                        else if(usersUid[uid]!["status"] as! Int == 1 && self.post?.privateEnabled == 0)
                        {
                            self.joinButton.setUserStatus(stat: JoinButton.status.publicJoined)
                        }
                        else if(usersUid[uid]!["status"] as! Int == 0)
                        {
                            self.joinButton.setUserStatus(stat: JoinButton.status.requested)
                        }
                    }
                    else
                    {
                        if(currentGroupCount != self.post?.groupCount)
                        {
                            if(self.post?.privateEnabled == 1)
                            {
                                self.joinButton.setUserStatus(stat: JoinButton.status.privateJoin)
                            }
                            else if(self.post?.privateEnabled == 0)
                            {
                                self.joinButton.setUserStatus(stat: JoinButton.status.publicJoin)
                            }
                        }
                        else
                        {
                            self.joinButton.setUserStatus(stat: JoinButton.status.full)
                        }
                    }
                    
                    self.joinButton.isHidden = false
                    
                    
                    for(_, element) in (usersUid.enumerated()) {
                        if let dictionary = element.value as? [String: AnyObject]
                        {
                            if(dictionary["status"] as! Int == -1)
                            {
                                self.profileImageView.loadImageUsingCache(urlString: dictionary["imageUrl"] as! String, userUid: element.key, postUid: (self.post?.key)!)
                                self.profileImageView.isHidden = false
                            }
                            else if(dictionary["status"] as! Int == 1)
                            {
                                let view = self.getOtherUserView()
                                view.loadImageUsingCache(urlString: dictionary["imageUrl"] as! String, userUid: element.key, postUid: (self.post?.key)!)
                                self.otherUsersViews.append(view)
                            }
                        }
                    }
                    for(index, element) in (self.otherUsersViews.enumerated()) {
                        if(index == 0)
                        {
                            self.self.addSubview(element)
                            element.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
                            element.widthAnchor.constraint(equalToConstant: 30).isActive = true
                            element.heightAnchor.constraint(equalToConstant: 30).isActive = true
                            element.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor).isActive = true
                        }
                        else
                        {
                            self.self.insertSubview(element, belowSubview: self.otherUsersViews[index-1])
                            element.rightAnchor.constraint(equalTo: self.otherUsersViews[index-1].leftAnchor, constant: 10).isActive = true
                            element.widthAnchor.constraint(equalToConstant: 30).isActive = true
                            element.heightAnchor.constraint(equalToConstant: 30).isActive = true
                            element.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor).isActive = true
                        }
                    }
                }
            }
        }
    }
    
    var index: Int?
    {
        didSet{
            joinButton.index = index
            deleteButton.index = index
        }
    }
    
    var key: String?
    {
        didSet{
            joinButton.postKey = key
        }
    }
    
    func getOtherUserView() -> UIButton{
        let imageView = UIButton()
        imageView.layer.borderWidth = 0.5
        imageView.backgroundColor = UIColor.white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }
    
    let deleteButton: DeleteButton = {
        let db = DeleteButton()
        db.translatesAutoresizingMaskIntoConstraints = false
        db.isHidden = true
        return db
    }()
    
    let filtersLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 12)
        a.textColor = UIColor.gray
        a.font = UIFont.boldSystemFont(ofSize: 12)
        a.numberOfLines = 1
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        a.isHidden = true
        return a
    }()
    
    let activityLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 18)
        a.textColor = UIColor.black
        a.font = UIFont.boldSystemFont(ofSize: 18)
        a.numberOfLines = 2
        a.translatesAutoresizingMaskIntoConstraints = false
        a.isHidden = true
        return a
    }()
    
    let dateLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 16)
        a.textColor = UIColor.darkGray
        a.numberOfLines = 1
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        a.isHidden = true
        return a
    }()
    
    let timeLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 16)
        a.textColor = UIColor.darkGray
        a.numberOfLines = 1
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        a.isHidden = true
        return a
    }()
    
    let locationImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    let locationLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 12)
        a.textColor = UIColor.gray
        a.numberOfLines = 2
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        a.isHidden = true
        return a
    }()
    
    let clickableView: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(FeedController.controller?.handleFullView), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let descriptionText: UITextView = {
        let d = UITextView()
        d.font = UIFont.init(name: "Helvetica Neue", size: 16)
        d.textColor = UIColor.darkGray
        d.isScrollEnabled = false
        d.isEditable = false
        d.translatesAutoresizingMaskIntoConstraints = false
        d.isHidden = true
        return d
    }()
    
    let profileImageView: UIButton = {
        let imageView = UIButton()
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    let profileName: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "Helvetica Neue", size: 15)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    let timeSince: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "Helvetica Neue", size: 12)
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.text = "1h"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    let joinButton: JoinButton = {
        let jb = JoinButton()
        jb.isHidden = true
        return jb
    }()
    
    let commentButton: CommentButton = {
        let cb = CommentButton()
        cb.setImage(#imageLiteral(resourceName: "comments"), for: .normal)
        cb.adjustsImageWhenHighlighted = true
        cb.isHidden = true
        cb.translatesAutoresizingMaskIntoConstraints = false
        return cb
    }()
    
    let heartButton: HeartButton = {
        let cb = HeartButton()
        cb.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        cb.adjustsImageWhenHighlighted = true
        cb.isHidden = true
        cb.translatesAutoresizingMaskIntoConstraints = false
        return cb
    }()
    
    func setupViews() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        backgroundColor = UIColor.white
        
        addSubview(eventImageView)
        eventImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        eventImageView.topAnchor.constraint(equalTo: topAnchor, constant:10).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true

        addSubview(filtersLabel)
        filtersLabel.topAnchor.constraint(equalTo: topAnchor, constant:10).isActive = true
        filtersLabel.leftAnchor.constraint(equalTo: eventImageView.rightAnchor, constant: 10).isActive = true
        filtersLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
        
        addSubview(activityLabel)
        activityLabel.topAnchor.constraint(equalTo: filtersLabel.bottomAnchor).isActive = true
        activityLabel.leftAnchor.constraint(equalTo: eventImageView.rightAnchor, constant: 10).isActive = true
        activityLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
        
        addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: activityLabel.bottomAnchor, constant: 5).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: eventImageView.rightAnchor, constant: 10).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
        
        addSubview(timeLabel)
        timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: eventImageView.rightAnchor, constant: 10).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
        
        addSubview(locationImage)
        locationImage.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5).isActive = true
        locationImage.leftAnchor.constraint(equalTo: eventImageView.rightAnchor, constant: 6).isActive = true
        locationImage.heightAnchor.constraint(equalToConstant: 15).isActive = true
        locationImage.widthAnchor.constraint(equalToConstant: 15).isActive = true

        addSubview(locationLabel)
        locationLabel.topAnchor.constraint(equalTo: locationImage.topAnchor).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: locationImage.rightAnchor, constant: 3).isActive = true
        locationLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
        
        addSubview(lineView)
        lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50).isActive = true
        lineView.widthAnchor.constraint(equalTo: widthAnchor, constant: -8).isActive = true
        lineView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        addSubview(clickableView)
        clickableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        clickableView.bottomAnchor.constraint(equalTo: lineView.topAnchor).isActive = true
        clickableView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        addSubview(profileImageView)
        profileImageView.bottomAnchor.constraint(equalTo: lineView.bottomAnchor, constant: -15).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        addSubview(profileName)
        profileName.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 6).isActive = true
        profileName.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 5).isActive = true
        
        addSubview(timeSince)
        timeSince.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 3).isActive = true
        timeSince.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 5).isActive = true
        
        addSubview(joinButton)
        joinButton.rightAnchor.constraint(equalTo: lineView.rightAnchor, constant: -10).isActive = true
        joinButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        addSubview(heartButton)
        heartButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        heartButton.centerYAnchor.constraint(equalTo: joinButton.centerYAnchor).isActive = true
        
        addSubview(commentButton)
        commentButton.leftAnchor.constraint(equalTo: heartButton.rightAnchor, constant: 15).isActive = true
        commentButton.centerYAnchor.constraint(equalTo: joinButton.centerYAnchor).isActive = true
        
        
    
    }
    
        func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
    
            let calendar = NSCalendar.current
            let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
            let now = Date()
            let earliest = now < date ? now : date
            let latest = (earliest == now) ? date : now
            let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
    
            if (components.year! >= 2) {
                return "\(components.year!) years"
            } else if (components.year! >= 1){
                if (numericDates){
                    return "1 year"
                } else {
                    return "Last year"
                }
            } else if (components.month! >= 2) {
                return "\(components.month!) months"
            } else if (components.month! >= 1){
                if (numericDates){
                    return "1 month"
                } else {
                    return "Last month"
                }
            } else if (components.weekOfYear! >= 2) {
                return "\(components.weekOfYear!) weeks"
            } else if (components.weekOfYear! >= 1){
                if (numericDates){
                    return "1 week"
                } else {
                    return "Last week"
                }
            } else if (components.day! >= 2) {
                return "\(components.day!) days"
            } else if (components.day! >= 1){
                if (numericDates){
                    return "1 day"
                } else {
                    return "Yesterday"
                }
            } else if (components.hour! >= 2) {
                return "\(components.hour!) hours"
            } else if (components.hour! >= 1){
                if (numericDates){
                    return "1 hour"
                } else {
                    return "An hour ago"
                }
            } else if (components.minute! >= 2) {
                return "\(components.minute!) minutes"
            } else if (components.minute! >= 1){
                if (numericDates){
                    return "1 minute"
                } else {
                    return "A minute ago"
                }
            } else if (components.second! >= 3) {
                return "\(components.second!) seconds"
            } else {
                return "Just now"
            }
    
        }
}
