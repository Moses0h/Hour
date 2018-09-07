//
//  CellFunctions.swift
//  Hour
//
//  Created by Moses Oh on 9/5/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import CoreLocation

class CellFunctions {
    
    @objc static func handleFullView() {
        let fullPostController = FullPostController(nibName: nil, bundle: nil)
        fullPostController.hidesBottomBarWhenPushed = true
        FeedController.controller?.navigationController?.pushViewController(fullPostController, animated: true)
    }
    
}
