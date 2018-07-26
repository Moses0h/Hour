//
//  DateAndTimeController.swift
//  Hour
//
//  Created by Moses Oh on 3/4/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//
import UIKit

enum MyTheme {
    case light
    case dark
}

class DateAndTimeController: UIViewController {
    
    var theme = MyTheme.light
    
    
    let calendarContainer: UIView = {
        let cc = UIView()
        cc.backgroundColor = UIColor.white
        cc.translatesAutoresizingMaskIntoConstraints = false
        cc.layer.cornerRadius = 5
        cc.layer.masksToBounds = true
        return cc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Date and Time"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)

        setupViews()
        
        
        let leftBarBtn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        leftBarBtn.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = leftBarBtn
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calenderView.myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setupViews(){
        view.addSubview(calendarContainer)
        calendarContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        calendarContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 75).isActive=true
        calendarContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        calendarContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/2).isActive = true
        
        calendarContainer.addSubview(calenderView)
        calenderView.topAnchor.constraint(equalTo: calendarContainer.topAnchor, constant: 10).isActive = true
        calenderView.centerXAnchor.constraint(equalTo: calendarContainer.centerXAnchor).isActive = true
        calenderView.widthAnchor.constraint(equalTo: calendarContainer.widthAnchor, constant: -10).isActive = true
        calenderView.heightAnchor.constraint(equalTo: calendarContainer.heightAnchor).isActive = true
    }
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
//    @objc func rightBarBtnAction(sender: UIBarButtonItem) {
//        if theme == .dark {
//            sender.title = "Dark"
//            theme = .light
//            Style.themeLight()
//        } else {
//            sender.title = "Light"
//            theme = .dark
//            Style.themeDark()
//        }
//        self.view.backgroundColor=Style.bgColor
//        calenderView.changeTheme()
//    }
    
    let calenderView: CalenderView = {
        let v=CalenderView(theme: MyTheme.light)
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
}


