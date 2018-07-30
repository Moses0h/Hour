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
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        layer.cornerRadius = 5
        layer.masksToBounds = true
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
            let value = [(Auth.auth().currentUser?.uid)!: 0] as [String: Any]
            ref.updateChildValues(value)
            break
        case .joined:
            setUserStatus(stat: .join)
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid").child((Auth.auth().currentUser?.uid)!)
            ref.removeValue()
            break
        case .requested:
            setUserStatus(stat: .join)
            let ref = Database.database().reference().child("posts").child(postKey!).child("usersUid").child((Auth.auth().currentUser?.uid)!)
            ref.removeValue()
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
            setTitleColor(UIColor.gray, for: .normal)
            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Owner", for: .normal)
            isUserInteractionEnabled = false
            currentStatus = .host
            break
        case .join:
            setTitleColor(UIColor.white, for: .normal)
            backgroundColor = UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
            setTitle("Join", for: .normal)
            currentStatus = .join
            isUserInteractionEnabled = true
            break
        case .joined:
            setTitleColor(UIColor.gray, for: .normal)
            backgroundColor = UIColor(white: 0.95, alpha: 1)
            setTitle("Joined", for: .normal)
            currentStatus = .joined
            isUserInteractionEnabled = true
            break
        case .requested:
            setTitleColor(UIColor.gray, for: .normal)
            backgroundColor = UIColor(white: 0.95, alpha: 1)
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
