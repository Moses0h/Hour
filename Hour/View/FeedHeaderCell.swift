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
        a.textColor = UIColor.darkText
        a.numberOfLines = 2
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    let postActivityImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "write"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    let postActivityContainer: BounceButton = {
        let pac = BounceButton()
        pac.backgroundColor = UIColor.white
        pac.translatesAutoresizingMaskIntoConstraints = false
        pac.layer.cornerRadius = 5
        pac.layer.masksToBounds = true
        pac.isUserInteractionEnabled = true
    
        pac.addTarget(self, action: #selector(FeedController.handleNewPost), for: .touchUpInside)
        pac.isUserInteractionEnabled = true
        
        
        return pac
    }()
    
    let label: UILabel = {
        let a = UILabel()
        a.font = UIFont.init(name: "Helvetica Neue", size: 18)
        a.text = " Post an activity"
        a.textColor = UIColor.darkGray
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
   
    
    
    func setupViews() {
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        addSubview(FeedController.feed!.filterContainer)
        FeedController.feed!.filterContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        FeedController.feed!.filterContainer.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        FeedController.feed!.filterContainer.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        FeedController.feed!.filterContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/3).isActive = true
        print(FeedController.feed!.filterContainer.frame.height)
        
        
        var buttons: [FilterButton] = (FeedController.feed?.categoryButtons)!
        for button in buttons{
            let index: Int = buttons.index(of: button)!
            
            FeedController.feed!.filterContainer.addSubview(button)
            button.centerYAnchor.constraint(equalTo: FeedController.feed!.filterContainer.centerYAnchor).isActive = true
            button.heightAnchor.constraint(equalTo: FeedController.feed!.filterContainer.heightAnchor, constant: -3).isActive = true
            
            if(index == 0)
            {
                button.leftAnchor.constraint(equalTo: FeedController.feed!.filterContainer.leftAnchor, constant: 5).isActive = true
            }
            else
            {
                button.leftAnchor.constraint(equalTo: buttons[index - 1].rightAnchor, constant: 6).isActive = true
            }
            
        }
        
        addSubview(postActivityContainer)
        postActivityContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        postActivityContainer.topAnchor.constraint(equalTo: FeedController.feed!.filterContainer.bottomAnchor, constant: 5).isActive = true
        postActivityContainer.widthAnchor.constraint(equalTo: widthAnchor, constant: -10).isActive = true
        postActivityContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        postActivityContainer.addSubview(postActivityImage)
        postActivityImage.leftAnchor.constraint(equalTo: postActivityContainer.leftAnchor, constant: 15).isActive = true
        postActivityImage.centerYAnchor.constraint(equalTo: postActivityContainer.centerYAnchor).isActive = true
        
        postActivityContainer.addSubview(label)
        label.leftAnchor.constraint(equalTo: postActivityImage.rightAnchor, constant: 10).isActive = true
        label.centerYAnchor.constraint(equalTo: postActivityContainer.centerYAnchor).isActive = true
    }
    
}
