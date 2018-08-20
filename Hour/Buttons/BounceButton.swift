//
//  Bounce.swift
//  Hour
//
//  Created by Moses Oh on 3/9/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//


import UIKit

class BounceButton: UIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 1.01, y:1.01)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
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
        setTitleColor(UIColor.gray, for: .normal)
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 18)!
        layer.cornerRadius = 5
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}

