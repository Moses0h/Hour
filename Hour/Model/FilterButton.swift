//
//  FilterButton.swift
//  Hour
//
//  Created by Moses Oh on 8/11/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit

class FilterButton: UIButton {
    
    var isOn = false
    var childUpdates : [String: Any] = [:]
    
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
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func buttonPressed() {
        activatedButton(bool: !isOn)
    }
    
    func activatedButton(bool: Bool) {
        isOn = bool
        let background = bool ? AppDelegate.THEME : UIColor.white
        let text = bool ? UIColor.white : UIColor.gray
        backgroundColor = background
        setTitleColor(text, for: .normal)
    }
}
