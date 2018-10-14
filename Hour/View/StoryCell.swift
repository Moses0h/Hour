//
//  StoryCell.swift
//  Hour
//
//  Created by Moses Oh on 10/5/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class StoryCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = UIColor.purple
    }
}
