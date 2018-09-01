//
//  CommentButton.swift
//  Hour
//
//  Created by Moses Oh on 8/23/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation

import UIKit

class CommentButton: UIButton {
    
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
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted == true
            { setImage(#imageLiteral(resourceName: "comments2"), for: .normal)
            }
            else
            { setImage(#imageLiteral(resourceName: "comments"), for: .normal) }
            tintColorDidChange()
        }
    }
}


