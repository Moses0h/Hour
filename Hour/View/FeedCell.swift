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
    
    var post: Post? {
        didSet{
//            if let name = post?.activity, let time = post?.time{
//
//                let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
//
//                attributedText.append(NSAttributedString(string: "\n" + time, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor(red: 155/255, green: 161/255, blue: 171/255, alpha: 1)]))
//
//                let paragraphStyle = NSMutableParagraphStyle()
//                paragraphStyle.lineSpacing = 4
//
//                attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.string.count))
//
//                nameLabel.attributedText = attributedText
//            }
        }
    }
    var key: String?
    
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
    
//    var desc: String? {
//        didSet{
//            let a = statusTextView.text
//            statusTextView.text = a! + ", description: " + desc!
//        }
//    }
    
    var usersUid: [String]? {
        didSet{
            let uid : String! = Auth.auth().currentUser?.uid
            if(uid == usersUid![0])
            {
                joinButton.setUserStatus(stat: JoinButton.status.host)
            }
            else if(usersUid?.contains(uid))!
            {
                joinButton.setUserStatus(stat: JoinButton.status.joined)
            }
            else
            {
                joinButton.setUserStatus(stat: JoinButton.status.join)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let activityLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 18)
        a.textColor = UIColor.darkText
        a.numberOfLines = 2
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "food"))
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
        backgroundColor = UIColor.white
        addSubview(activityLabel)
        addSubview(profileImageView)
        addSubview(descriptionText)
        addSubview(joinButton)
        
        addConstraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, activityLabel)
        addConstraintsWithFormat(format: "H:|-4-[v0]-4-|", views: descriptionText)
        addConstraintsWithFormat(format: "V:|-12-[v0]", views: activityLabel)
        addConstraintsWithFormat(format: "V:|-12-[v0(44)]-4-[v1]", views: profileImageView, descriptionText)

        joinButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        joinButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        joinButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3).isActive = true
        print("feed setup")
        
    }
}
