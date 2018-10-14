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
                    
                    self.nameLabel.text = dictionary["name"] as? String
                    self.bioTextField.text = dictionary["bio"] as? String
                }
                
            }
        }
    }
    
    let nameLabel: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 24)
        a.text = ""
        a.font = UIFont.boldSystemFont(ofSize: 24)
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
        imageView.layer.cornerRadius = 75
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let profileContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 0.2)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor = UIColor.lightGray.cgColor

        view.layer.masksToBounds = false
        
        return view
    }()
    
    let bioLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "About Me:"
        l.font = UIFont.init(name: "Helvetica Neue", size: 15)
        l.font = UIFont.boldSystemFont(ofSize: 15)
        return l
    }()
    
    let bioTextField: UITextView = {
        let dtf = UITextView()
        dtf.font = UIFont.init(name: "Helvetica Neue", size: 15)
        dtf.text = ""
        dtf.textColor = UIColor.black
        dtf.isScrollEnabled = false
        dtf.isEditable = false
        dtf.translatesAutoresizingMaskIntoConstraints = false
        return dtf
    }()
    
    let editButton: UIButton = {
        let butt = UIButton()
        butt.setTitle("Edit Profile", for: .normal)
        butt.titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 15)
        butt.addTarget(self, action: #selector(ProfileController.controller?.saveProfile), for: .touchUpInside)
        butt.setTitleColor(UIColor.lightGray, for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.isUserInteractionEnabled = true
        return butt
    }()
    
    
    func setupViews() {
        backgroundColor = UIColor.clear
    
        addSubview(profileContainer)
        profileContainer.widthAnchor.constraint(equalTo: widthAnchor, constant: -10).isActive = true
        profileContainer.heightAnchor.constraint(equalToConstant: 300).isActive = true
        profileContainer.topAnchor.constraint(equalTo: topAnchor, constant: 100).isActive = true
        profileContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        
        addSubview(profileImage)
        profileImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImage.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: -60).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        profileContainer.addSubview(editButton)
        editButton.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: 10).isActive = true
        editButton.rightAnchor.constraint(equalTo: profileContainer.rightAnchor,constant: -20).isActive = true
        
        addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10).isActive = true

        profileContainer.addSubview(bioLabel)
        bioLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15).isActive = true
        bioLabel.leftAnchor.constraint(equalTo: profileContainer.leftAnchor, constant: 20).isActive = true
        
        profileContainer.addSubview(bioTextField)
        bioTextField.topAnchor.constraint(equalTo: bioLabel.bottomAnchor).isActive = true
        bioTextField.leftAnchor.constraint(equalTo: profileContainer.leftAnchor, constant: 15).isActive = true
        bioTextField.bottomAnchor.constraint(equalTo: profileContainer.bottomAnchor, constant: -20).isActive = true
        bioTextField.rightAnchor.constraint(equalTo: profileContainer.rightAnchor,constant: -20).isActive = true
    }
    
}
