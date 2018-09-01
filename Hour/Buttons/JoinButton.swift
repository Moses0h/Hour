//
//  JoinButton.swift
//  Hour
//
//  Created by Moses Oh on 7/27/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class JoinButton: UIButton {
    var isOn = false
    enum status {
        case join
        case joined
        case host
        case requested
        case unknown
    }
    
    var postKey: String?
    var index: Int?
    
    var currentStatus: status = status.unknown
    var ref = Database.database().reference()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 1.1, y:1.1)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
        super.touchesBegan(touches, with: event)
        self.adjustsImageWhenHighlighted = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
//        setTitleColor(UIColor.gray, for: .normal)
//        backgroundColor = UIColor(white: 0.95, alpha: 1)
        titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 18)!
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
//        layer.cornerRadius = 5
//        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func buttonPressed() {
        print("pressed")
        switch currentStatus {
        case .host:
            break
        case .join:
            setUserStatus(stat: .requested)
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid")
            let userRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("posts")
            let value = [(Auth.auth().currentUser?.uid)!: 0] as [String: Any]
            let userValue = [postKey!: 0] as [String: Any]
            FeedController.controller?.posts[index!].usersUid[(Auth.auth().currentUser?.uid)!] = 0
            ref.updateChildValues(value)
            userRef.updateChildValues(userValue)
            break
        case .joined:
            setUserStatus(stat: .join)
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid").child((Auth.auth().currentUser?.uid)!)
            let userRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("posts").child(postKey!)
            
            let groupRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("groups").child(postKey!)
            
            ref.removeValue()
            userRef.removeValue()
            groupRef.removeValue { (err, ref) in
                FeedController.controller?.posts[self.index!].usersUid.removeValue(forKey: (Auth.auth().currentUser?.uid)!)
            }
            
            break
        case .requested:
            setUserStatus(stat: .join)
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid").child((Auth.auth().currentUser?.uid)!)
            let userRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("posts").child(postKey!)
            
            let groupRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("groups").child(postKey!)

            ref.removeValue()
            userRef.removeValue()
            groupRef.removeValue { (err, ref) in
                FeedController.controller?.posts[self.index!].usersUid.removeValue(forKey: (Auth.auth().currentUser?.uid)!)
            }
            break
        case .unknown:
            break
        }
    }
    
//    @objc func buttonPressed() {
//        print("hello")
//        activatedButton(bool: !isOn)
//    }
    
    func activatedButton(bool: Bool) {
        isOn = bool
        let background = bool ? UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1) : UIColor(white: 0.95, alpha: 1)
        let text = bool ? UIColor.white : UIColor.gray
//        if(bool){
//            postController?.childUpdates.updateValue(true, forKey: (titleLabel?.text)!)
//        }
//        else{
//            postController?.childUpdates.removeValue(forKey: (titleLabel?.text)!)
//        }
        backgroundColor = background
        setTitleColor(text, for: .normal)
    }
    
    func setUserStatus(stat: status) {
        switch stat {
        case .host:
            setTitleColor(UIColor.lightGray, for: .normal)
//            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Owner", for: .normal)
            isUserInteractionEnabled = false
            currentStatus = .host
            break
        case .join:
            setTitleColor(UIColor.darkGray, for: .normal)
//            backgroundColor = UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
            setTitle("Join", for: .normal)
            currentStatus = .join
            isUserInteractionEnabled = true
            break
        case .joined:
            setTitleColor(UIColor.darkGray, for: .normal)
//            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Joined", for: .normal)
            currentStatus = .joined
            isUserInteractionEnabled = true
            break
        case .requested:
            setTitleColor(UIColor.darkGray, for: .normal)
//            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Requested", for: .normal)
            currentStatus = .requested
            isUserInteractionEnabled = true
            break
        case .unknown:
            currentStatus = .unknown
            break
        }
    }

    
    
}
