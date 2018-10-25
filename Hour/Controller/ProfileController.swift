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

class ProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    static var controller: ProfileController?
    
    var headerId = "header"
    var uid = ""
    var posts = [Post]()
    var postKeys = [String]()

    var keyArray: [String] = []
    var doFetch: Bool = false
    var refresher: UIRefreshControl!
    
    
    let profileFeedCell = "feedCell"
    let storyCell = "storyCell"
    
    let refreshView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    @objc func updateFeed() {
        uid = (Auth.auth().currentUser?.uid)!
        self.refreshView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshPostArray()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = (Auth.auth().currentUser?.uid)!
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(updateFeed), for: UIControl.Event.valueChanged)
        
        collectionView?.addSubview(refreshView)
        refreshView.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        refreshView.addSubview(refresher)
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ProfileFeedCell.self, forCellWithReuseIdentifier: profileFeedCell)
        collectionView?.register(StoryCell.self, forCellWithReuseIdentifier: storyCell)

        collectionView?.register(ProfileHeaderCell.self, forSupplementaryViewOfKind:
            UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
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
    
    @objc func handleProfileView(sender: UserButton) {
        let profileController = OtherProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        //        profileController.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        profileController.navigationController?.navigationBar.barTintColor = UIColor.white
        profileController.uid = sender.uid!
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        let decompressedImage = selectedImageFromPicker?.jpeg(.lowest)
        
        let storageRef = Storage.storage().reference().child("users").child(uid)
        if let uploadImg = decompressedImage
        {
            storageRef.putData(uploadImg, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        return
                    }
                    let value = ["imageUrl" : url?.absoluteString] as! [String : String]
                    
                    let ref = Database.database().reference().child("users").child(self.uid)
                    ref.updateChildValues(value as Any as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                        self.header?.profileImage.setImage(selectedImageFromPicker, for: .normal)
                        self.dismiss(animated: true, completion: nil)
                    })

                })
            })
        }
        
    }
    

    func refreshPostArray() {
        self.posts.removeAll()
        self.postKeys.removeAll()
        
        uid = Auth.auth().currentUser!.uid
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
                                self.refresher.endRefreshing()
                                self.collectionView?.reloadData()
                            }
                        })
                    }
                }
                else
                {
                    self.refresher.endRefreshing()
                    self.collectionView?.reloadData()
                }
            }
            else
            {
                self.refresher.endRefreshing()
                self.collectionView?.reloadData()
            }
        })
    }
    
    @objc func saveProfile() {
        switch header?.editButton.titleLabel?.text {
        case "Edit Profile":
            header?.bioTextField.isEditable = true
            header?.editButton.setTitle("Save Profile", for: .normal)
            break
        case "Save Profile":
            header?.bioTextField.isEditable = false
            let userPosts = ["bio":header?.bioTextField.text ?? ""] as [String : Any]
            Database.database().reference().child("users").child(uid).updateChildValues(userPosts) {(err,ref) in
                if err != nil{
                    print(err ?? "error")
                    return
                }
            }
            header?.editButton.setTitle("Edit Profile", for: .normal)
            break
        default:
            break
        }
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
                header?.editButton.isHidden = false
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
