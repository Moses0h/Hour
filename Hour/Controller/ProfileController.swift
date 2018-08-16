//
//  ProfileController.swift
//  Hour
//
//  Created by Moses Oh on 8/14/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import CoreLocation

class ProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    static var controller: ProfileController?
    
    var headerId = "header"
    var ref: DatabaseReference!
    var geoFire: GeoFire!
    var circleQuery: GFCircleQuery!
    var posts = [Post]()

    var keyArray: [String] = []
    var doFetch: Bool = false
    var refresher: UIRefreshControl!
    
    
    let cellId = "cellId"
    
    let refreshView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var filterContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor(white: 0.95, alpha: 0.5)
        return scrollView
    }()
    
    @objc func updateFeed() {
        self.refreshView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshPostArray()
            self.refresher.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileController.controller = self
        
        ref = Database.database().reference()
        geoFire = GeoFire(firebaseRef: ref.child("posts_location"))
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(updateFeed), for: UIControlEvents.valueChanged)
        
        collectionView?.addSubview(refreshView)
        refreshView.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        refreshView.addSubview(refresher)
        
        let attributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(UICollectionViewCell.self, forSupplementaryViewOfKind:
            UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        collectionView?.dataSource = self
        
        refreshPostArray()
    }

    func refreshPostArray() {
        self.posts.removeAll()
        
        let uid = Auth.auth().currentUser!.uid
        let reff = Database.database().reference().child("users").child(uid).child("posts")
        var postKeys = [String]()
        reff.observeSingleEvent(of: .value, with: { (snap) in
            let total = Int(snap.childrenCount)
            if let dictionary = snap.value as? [String: AnyObject]
            {
                postKeys = Array(dictionary.keys)
                for key in postKeys {
                    Database.database().reference().child("posts").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                        let post = Post(snapshot: snapshot)
                        self.posts.append(post)
                        if(total == self.posts.count)
                        {
                            self.collectionView?.reloadData()
                        }
                    })
                }
            }
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        let post : Post
        post = posts[indexPath.row]
        feedCell.key = post.key
        feedCell.usersUid = post.usersUid as? [String : Int]
        feedCell.name = post.name
        feedCell.activity = post.activity
        feedCell.descriptionString = post.description
        feedCell.location = post.location
        feedCell.date = post.date
        feedCell.startTime = post.startTime
        feedCell.endTime = post.endTime
        feedCell.category = post.category
        feedCell.groupCount = post.groupCount
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 0, 5);
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 10, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath)
        header.backgroundColor = UIColor.lightGray
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
}
