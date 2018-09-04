//
//  Extensions.swift
//  Hour
//
//  Created by Moses Oh on 9/3/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

let imageCache = NSCache<AnyObject, UIImage>()

extension UIImageView {
    
    func loadImageUsingCache(urlString: String) {
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                let downloadedImage = UIImage(data: data!)
                if(downloadedImage != nil)
                {
                    imageCache.setObject(downloadedImage!, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
            
        }.resume()
    }
    
}

extension UIButton {
    
    func loadImageUsingCache(urlString: String, userUid: String) {
        self.setImage(nil, for: .normal)
        if(urlString.count == 0)
        {
            return
        }
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.setImage(cachedImage, for: .normal)
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                let downloadedImage = UIImage(data: data!)
                if(downloadedImage != nil)
                {
                    imageCache.setObject(downloadedImage!, forKey: urlString as AnyObject)
                    self.setImage(downloadedImage, for: .normal)
                }
                else
                {
                    var imageUrl = ""
                    Database.database().reference().child("users").child(userUid).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject]
                        {
                            imageUrl = dictionary["imageUrl"] as! String
                            imageCache.removeObject(forKey: urlString as AnyObject)
                            self.loadImageUsingCache(urlString: imageUrl, userUid: userUid)
                        }
                    })
                    
                }
            }
            
            }.resume()
    }
    
    func loadImageUsingCache(urlString: String, userUid: String, postUid: String) {
        self.setImage(nil, for: .normal)
        if(urlString.count == 0)
        {
            return
        }
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.setImage(cachedImage, for: .normal)
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                let downloadedImage = UIImage(data: data!)
                if(downloadedImage != nil)
                {
                    imageCache.setObject(downloadedImage!, forKey: urlString as AnyObject)
                    self.setImage(downloadedImage, for: .normal)
                }
                else
                {
                    var imageUrl = ""
                    Database.database().reference().child("users").child(userUid).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject]
                        {
                            imageUrl = dictionary["imageUrl"] as! String
                            Database.database().reference().child("posts").child(postUid).child("usersUid").child(userUid).updateChildValues(["imageUrl": imageUrl])
                            imageCache.removeObject(forKey: urlString as AnyObject)
                            self.loadImageUsingCache(urlString: imageUrl, userUid: userUid, postUid: postUid)
                        }
                    })
                    
                }
            }
            
            }.resume()
    }
}
