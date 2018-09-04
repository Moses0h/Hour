//
//  DetailedPostController.swift
//  Hour
//
//  Created by Moses Oh on 8/16/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit

class DetailedPostController: UIViewController {
    
    var feed: FeedCell? {
        didSet{
        }
    }
    
    var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white

        view.backgroundColor = UIColor.purple
        scrollView = UIScrollView(frame: view.bounds)

        setupViews()
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
        a.textColor = UIColor.darkGray
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
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
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
    
    let joinButton: JoinButton = {
        let jb = JoinButton()
        return jb
    }()
    func setupViews() {
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 10).isActive = true
        profileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant:10).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        scrollView.addSubview(filtersLabel)
        filtersLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant:10).isActive = true
        filtersLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        filtersLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 10).isActive = true
        
        scrollView.addSubview(activityLabel)
        activityLabel.topAnchor.constraint(equalTo: filtersLabel.bottomAnchor).isActive = true
        activityLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        activityLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 10).isActive = true
        
        scrollView.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: activityLabel.bottomAnchor, constant: 5).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 10).isActive = true
        
        scrollView.addSubview(timeLabel)
        timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 10).isActive = true
        
        scrollView.addSubview(locationImage)
        locationImage.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5).isActive = true
        locationImage.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 6).isActive = true
        locationImage.heightAnchor.constraint(equalToConstant: 15).isActive = true
        locationImage.widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        scrollView.addSubview(locationLabel)
        locationLabel.topAnchor.constraint(equalTo: locationImage.topAnchor).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: locationImage.rightAnchor, constant: 3).isActive = true
        locationLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 10).isActive = true
        
        scrollView.addSubview(lineView)
        lineView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 50).isActive = true
        lineView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -8).isActive = true
        lineView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 4).isActive = true
    }
}
