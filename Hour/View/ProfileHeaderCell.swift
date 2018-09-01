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
    
    let label: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 18)
        a.text = " Post an activity"
        a.textColor = UIColor.darkGray
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    var eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.borderWidth = 1
        //        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        
    
        return imageView
    }()
    
    
    func setupViews() {
        backgroundColor = UIColor.cyan
        addSubview(eventImageView)
        eventImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        eventImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
       
    }
    
}
