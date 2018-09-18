//
//  DeleteButton.swift
//  Hour
//
//  Created by Moses Oh on 9/7/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import Firebase

class DeleteButton: UIButton {
    
    var postUid: String?
    var usersUid: [String: AnyObject]?
    var index: Int?
    var inFeedView: Bool?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //                            self.deleteButton.addTarget(self, action: #selector(FeedController.controller?.handleDelete), for: .touchUpInside)
        FeedController.controller?.handleDelete(sender: self)
    }
    
    func handleDelete() {
        var count = 0
        for uid in usersUid! {
            if(count == (usersUid?.count)!-1)
            {
                Database.database().reference().child("posts").child(postUid!).removeValue()
                Database.database().reference().child("groups").child(postUid!).removeValue()
                Database.database().reference().child("posts_location").child(postUid!).removeValue()
                Storage.storage().reference().child("posts").child(postUid!).delete { (err) in
                }
                if(self.inFeedView)!
                {
                    FeedController.controller?.posts.remove(at: index!)
                    FeedController.controller?.collectionView?.reloadData()
                }
                else
                {
                    ProfileController.controller?.posts.remove(at: index!)
                    ProfileController.controller?.collectionView?.reloadData()
                }
                
                
            }
            Database.database().reference().child("users").child(uid.key).child("posts").child(postUid!).removeValue()
            Database.database().reference().child("users").child(uid.key).child("groups").child(postUid!).removeValue()
            count += 1
        }
    }
}

