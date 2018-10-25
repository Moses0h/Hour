//
//  ProfileController.swift
//  Hour
//
//  Created by Moses Oh on 10/14/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import CoreLocation

class OtherProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var headerId = "header"
    var uid = ""
    var posts = [Post]()
    var postKeys = [String]()
    
    var keyArray: [String] = []
    var doFetch: Bool = false
    
    
    let profileFeedCell = "feedCell"
    let storyCell = "storyCell"
    
//    @objc func updateFeed() {
//        self.refreshView.heightAnchor.constraint(equalToConstant: 200).isActive = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.refreshPostArray()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white

        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ProfileFeedCell.self, forCellWithReuseIdentifier: profileFeedCell)
        collectionView?.register(StoryCell.self, forCellWithReuseIdentifier: storyCell)
        
        collectionView?.register(ProfileHeaderCell.self, forSupplementaryViewOfKind:
            UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        collectionView?.dataSource = self
        refreshPostArray()
        
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.navigationBar.tintColor = UIColor.white
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func refreshPostArray() {
        self.posts.removeAll()
        self.postKeys.removeAll()
        
        let users_uid_posts = Database.database().reference().child("users").child(uid).child("posts")
        
        users_uid_posts.observeSingleEvent(of: .value, with: { (snap) in
            if let dictionary = snap.value as? [String: AnyObject]
            {
                self.postKeys = Array(dictionary.keys)
                self.postKeys = self.postKeys.filter({ (key) -> Bool in
                    return dictionary[key] as! Int != 0
                })
                if(self.postKeys.count != 0)
                {
                    for key in self.postKeys {
                        Database.database().reference().child("posts").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                            let post = Post(snapshot: snapshot)
                            self.posts.append(post)
                            if(self.postKeys.count == self.posts.count)
                            {
                                self.header?.titleLabel.text = "Activities (\(self.posts.count))"
                                self.collectionView?.reloadData()
                            }
                        })
                    }
                }
                else
                {
                    self.collectionView?.reloadData()
                }
            }
            else
            {
                self.collectionView?.reloadData()
            }
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(section == 0)
        {
            return posts.count
        }
        return 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.section == 0)
        {
            let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.profileFeedCell, for: indexPath) as! ProfileFeedCell
            if(indexPath.row < posts.count)
            {
                let post : Post
                post = posts[indexPath.row]
                feedCell.post = post
                feedCell.key = post.key
                feedCell.index = indexPath.row
                feedCell.inFeedView = false
                feedCell.deleteButton.isHidden = true
                return feedCell
            }
            return feedCell
        }
        else
        {
            let storyCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.storyCell, for: indexPath) as! StoryCell
            
            return storyCell
        }
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        if(section == 0)
    //        {
    //            return UIEdgeInsets.init(top: 5, left: 5, bottom: 0, right: 5);
    //        }
    //        else
    //        {
    //            return UIEdgeInsets.init(top: 50, left: 5, bottom: 0, right: 5);
    //        }
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 10, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    var header: ProfileHeaderCell?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if(indexPath.section == 0)
            {
                header = (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ProfileHeaderCell)
                header?.profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfileImageView)))
                header?.uid = uid
                return header!
            }
            else
            {
                let invisibleHeader = UICollectionViewCell()
                return invisibleHeader
            }
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if(section == 0)
        {
            return CGSize(width: view.frame.width, height: 470)
        }
        else
        {
            return CGSize.zero
            
        }
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
