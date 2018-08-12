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
    
    var key: String?
    {
        didSet{
            joinButton.postKey = key
        }
    }
    
    var name: String?
    
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
            
        }
    }
    
    var time: String? {
        didSet{
            
        }
    }
    
    var groupCount: Int? {
        didSet{
            filtersLabel.text = filtersLabel.text! + "\(String(groupCount!)) people * "
        }
    }
    
    var category: String? {
        didSet{
            filtersLabel.text = filtersLabel.text! + "\(category!) * "
        }
    }

    let filtersLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 15)
        a.textColor = UIColor.gray
        a.font = UIFont.boldSystemFont(ofSize: 15)
        a.numberOfLines = 1
        a.text = ""
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let activityLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 20)
        a.textColor = UIColor.darkGray
        a.font = UIFont.boldSystemFont(ofSize: 20)
        a.numberOfLines = 2
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
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
    
    let joinButton: JoinButton = {
        let jb = JoinButton()
        return jb
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
        
        addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant:10).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true

        addSubview(filtersLabel)
        filtersLabel.topAnchor.constraint(equalTo: topAnchor, constant:10).isActive = true
        filtersLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        filtersLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
        
        addSubview(activityLabel)
        activityLabel.topAnchor.constraint(equalTo: filtersLabel.bottomAnchor, constant:10).isActive = true
        activityLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        activityLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
        
        //        addSubview(descriptionText)
//        addSubview(joinButton)
        
//        addConstraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, activityLabel)
//        addConstraintsWithFormat(format: "H:|-4-[v0]-4-|", views: descriptionText)
//        addConstraintsWithFormat(format: "V:|-12-[v0]", views: activityLabel)
//        addConstraintsWithFormat(format: "V:|-12-[v0(44)]-4-[v1]", views: profileImageView, descriptionText)

//        joinButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        joinButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
//        joinButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3).isActive = true
        
    }
}
