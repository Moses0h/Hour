//
//  FeedHeaderCell.swift
//  Hour
//
//  Created by Moses Oh on 8/7/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FeedHeaderCell: UICollectionViewCell{
    
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
        a.textColor = UIColor.black
        a.numberOfLines = 2
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let postActivityImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "write"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    let postActivityContainer: BounceButton = {
        let pac = BounceButton()
        pac.backgroundColor = UIColor(r: 93, g: 125, b: 255)
        pac.translatesAutoresizingMaskIntoConstraints = false
        pac.layer.cornerRadius = 5
        pac.layer.shadowOffset = CGSize(width: 1, height: 1)
        pac.layer.shadowOpacity = 0.5
        pac.layer.masksToBounds = false
        pac.isUserInteractionEnabled = true
    
        pac.addTarget(self, action: #selector(FeedController.handleNewPost), for: .touchUpInside)
        pac.isUserInteractionEnabled = true
        
        
        return pac
    }()
    
    let label: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 18)
        a.text = " Post an activity"
        a.textColor = UIColor.white
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
   
    
    
    func setupViews() {
        
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        let feedController: FeedController = FeedController.controller!
        addSubview(feedController.filterContainer)
        feedController.filterContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        feedController.filterContainer.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        feedController.filterContainer.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        feedController.filterContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/3).isActive = true
        print(feedController.filterContainer.frame.height)
        
        
        var buttons: [FilterButton] = (feedController.categoryButtons)
        for button in buttons{
            let index: Int = buttons.index(of: button)!
            
            feedController.filterContainer.addSubview(button)
            button.centerYAnchor.constraint(equalTo: feedController.filterContainer.centerYAnchor).isActive = true
            button.heightAnchor.constraint(equalTo: feedController.filterContainer.heightAnchor, constant: -3).isActive = true
            
            if(index == 0)
            {
                button.leftAnchor.constraint(equalTo: feedController.filterContainer.leftAnchor, constant: 5).isActive = true
            }
            else
            {
                button.leftAnchor.constraint(equalTo: buttons[index - 1].rightAnchor, constant: 6).isActive = true
            }
            
        }
        
        addSubview(postActivityContainer)
        postActivityContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        postActivityContainer.topAnchor.constraint(equalTo: feedController.filterContainer.bottomAnchor, constant: 5).isActive = true
        postActivityContainer.widthAnchor.constraint(equalTo: widthAnchor, constant: -10).isActive = true
        postActivityContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        postActivityContainer.addSubview(postActivityImage)
        postActivityImage.leftAnchor.constraint(equalTo: postActivityContainer.leftAnchor, constant: 10).isActive = true
        postActivityImage.centerYAnchor.constraint(equalTo: postActivityContainer.centerYAnchor).isActive = true
        postActivityImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        postActivityContainer.addSubview(label)
        label.leftAnchor.constraint(equalTo: postActivityImage.rightAnchor, constant: 5).isActive = true
        label.centerYAnchor.constraint(equalTo: postActivityContainer.centerYAnchor).isActive = true
    }
    
}
