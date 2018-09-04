//
//  ProfileCell.swift
//  Hour
//
//  Created by Moses Oh on 8/15/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProfileHeaderCell: UICollectionViewCell{
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var uid: String? {
        didSet{
            let profileRef = Database.database().reference().child("users").child(uid!)
            profileRef.observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    
                    /* setup profile image */
                    if((dictionary["imageUrl"]) != nil)
                    {
                        self.profileImage.loadImageUsingCache(urlString: dictionary["imageUrl"] as! String, userUid: (ProfileController.controller?.uid)!)
                    }
                    
                    self.nameLabel.text = dictionary["name"] as! String
                }
                
            }
        }
    }
    
    let nameLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 24)
        a.text = ""
        a.textColor = UIColor.darkGray
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let profileImage: UIButton = {
        let imageView = UIButton()
        imageView.backgroundColor = UIColor.white
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        
    
        return imageView
    }()
    
    
    func setupViews() {
        backgroundColor = UIColor.white
        addSubview(profileImage)
        profileImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        profileImage.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(nameLabel)
        nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
       
    }
    
}
