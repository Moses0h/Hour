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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var time: Double?
    {
        didSet{
            timeSince.text = timeAgoSinceDate(Date(timeIntervalSince1970: time!/1000))
        }
    }
    
    var index: Int?
    {
        didSet{
            joinButton.index = index
        }
    }
    
    var key: String?
    {
        didSet{
            joinButton.postKey = key
        }
    }
    
    var name: String?
    {
        didSet{
            profileName.text = name
        }
    }
    
    var activity: String? {
        didSet {
            activityLabel.text = activity
        }
    }
    
    var descriptionString: String? {
        didSet {
            descriptionText.text = descriptionString
        }
    }
    
    var usersUid: [String: Int]? {
        didSet{
            let uid : String! = Auth.auth().currentUser?.uid

            if(usersUid![uid] == -1)
            {
                joinButton.setUserStatus(stat: JoinButton.status.host)
            }
            else if(usersUid![uid] == 1)
            {
                joinButton.setUserStatus(stat: JoinButton.status.joined)
            }
            else if(usersUid![uid] == 0)
            {
                joinButton.setUserStatus(stat: JoinButton.status.requested)
            }
            else
            {
                joinButton.setUserStatus(stat: JoinButton.status.join)
            }
        }
    }
    
    var location: String? {
        didSet{
            locationLabel.text = location
        }
    }
    
    var date: String? {
        didSet{
            dateLabel.text = date
        }
    }
    
    var startTime: String? {
        didSet{
            timeLabel.text = startTime
        }
    }
    
    var endTime: String? {
        didSet{
            if(endTime != nil)
            {
                timeLabel.text = timeLabel.text! + " - \(endTime!)"
            }
        }
    }
    
    var groupCount: Int? {
        didSet{
            if(groupCount != nil)
            {
                filtersLabel.text = filtersLabel.text! + "\(String(groupCount!)) people • $"
            }
        }
    }
    
    var category: String? {
        didSet{
            if(category != nil)
            {
                filtersLabel.text = "\(category!) • "
            }
        }
    }

    let filtersLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 12)
        a.textColor = UIColor.gray
        a.font = UIFont.boldSystemFont(ofSize: 12)
        a.numberOfLines = 1
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let activityLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 18)
        a.textColor = UIColor.black
        a.font = UIFont.boldSystemFont(ofSize: 18)
        a.numberOfLines = 2
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let dateLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 16)
        a.textColor = UIColor.darkGray
        a.numberOfLines = 1
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let timeLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 16)
        a.textColor = UIColor.darkGray
        a.numberOfLines = 1
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let locationImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "locationIcon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let locationLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 12)
        a.textColor = UIColor.gray
        a.numberOfLines = 2
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let clickableView: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(FeedController.controller?.handleFullView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.borderWidth = 1
//        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
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
        return d
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.borderWidth = 1
//        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
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
        return label
    }()
    
    let timeSince: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "Helvetica Neue", size: 12)
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.text = "1h"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.backgroundColor = UIColor.blue
//        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let userImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.backgroundColor = UIColor.green
//        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let userImageView3: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.backgroundColor = UIColor.cyan
//        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let userImageView4: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.backgroundColor = UIColor.yellow
//        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let joinButton: JoinButton = {
        let jb = JoinButton()
        return jb
    }()
    
    let commentButton: CommentButton = {
        let cb = CommentButton()
        cb.setImage(#imageLiteral(resourceName: "comments"), for: .normal)
        cb.adjustsImageWhenHighlighted = true
        cb.translatesAutoresizingMaskIntoConstraints = false
        return cb
    }()
    
    let heartButton: HeartButton = {
        let cb = HeartButton()
        cb.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        cb.adjustsImageWhenHighlighted = true
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
        
        addSubview(profileImageView)
        profileImageView.bottomAnchor.constraint(equalTo: lineView.bottomAnchor, constant: -15).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        addSubview(userImageView1)
        userImageView1.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        userImageView1.widthAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView1.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView1.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(userImageView2)
        userImageView2.rightAnchor.constraint(equalTo: userImageView1.leftAnchor, constant: 10).isActive = true
        userImageView2.widthAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView2.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView2.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(userImageView3)
        userImageView3.rightAnchor.constraint(equalTo: userImageView2.leftAnchor, constant: 10).isActive = true
        userImageView3.widthAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView3.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView3.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(userImageView4)
        userImageView4.rightAnchor.constraint(equalTo: userImageView3.leftAnchor, constant: 10).isActive = true
        userImageView4.widthAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView4.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView4.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(profileName)
        profileName.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 6).isActive = true
        profileName.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 5).isActive = true
        
        addSubview(timeSince)
        timeSince.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 3).isActive = true
        timeSince.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 5).isActive = true
        
        addSubview(joinButton)
        joinButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
        joinButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        joinButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3).isActive = true
        
        addSubview(heartButton)
        heartButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        heartButton.centerYAnchor.constraint(equalTo: joinButton.centerYAnchor).isActive = true
        
        addSubview(commentButton)
        commentButton.leftAnchor.constraint(equalTo: heartButton.rightAnchor, constant: 15).isActive = true
        commentButton.centerYAnchor.constraint(equalTo: joinButton.centerYAnchor).isActive = true
        
        addSubview(clickableView)
        clickableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        clickableView.bottomAnchor.constraint(equalTo: lineView.topAnchor).isActive = true
        clickableView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        joinButton.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 10).isActive = true
//        joinButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        //        addSubview(descriptionText)
//        addSubview(joinButton)
        
//        addConstraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, activityLabel)
//        addConstraintsWithFormat(format: "H:|-4-[v0]-4-|", views: descriptionText)
//        addConstraintsWithFormat(format: "V:|-12-[v0]", views: activityLabel)
//        addConstraintsWithFormat(format: "V:|-12-[v0(44)]-4-[v1]", views: profileImageView, descriptionText)
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
