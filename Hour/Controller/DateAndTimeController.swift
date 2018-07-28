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
    
    let startTimeContainer: UIView = {
        let tc = UIView()
        tc.backgroundColor = UIColor.white
        tc.translatesAutoresizingMaskIntoConstraints = false
        tc.layer.cornerRadius = 5
        tc.layer.masksToBounds = true
        return tc
    }()
    
    let startTimeLabel: UILabel = {
        let tl = UILabel()
        tl.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        tl.text = "Start Time"
        tl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let startTimePicker: UIDatePicker = {
        let tp = UIDatePicker()
        tp.datePickerMode = UIDatePickerMode.time
        tp.translatesAutoresizingMaskIntoConstraints = false
        return tp
    }()
    
    let endTimeContainer: UIView = {
        let tc = UIView()
        tc.backgroundColor = UIColor.white
        tc.translatesAutoresizingMaskIntoConstraints = false
        tc.layer.cornerRadius = 5
        tc.layer.masksToBounds = true
        return tc
    }()
    
    let endTimeLabel: UILabel = {
        let tl = UILabel()
        tl.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        tl.text = "End Time"
        tl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let endTimePicker: UIDatePicker = {
        let tp = UIDatePicker()
        tp.datePickerMode = UIDatePickerMode.time
        tp.translatesAutoresizingMaskIntoConstraints = false
        return tp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Date and Time"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)

        setupViews()
        
        
        let leftBarBtn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        leftBarBtn.tintColor = UIColor.white
        
        let rightBarBtn = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleCancel))
        rightBarBtn.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = leftBarBtn
        self.navigationItem.rightBarButtonItem = rightBarBtn
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
        
        view.addSubview(startTimeContainer)
        startTimeContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startTimeContainer.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: 10).isActive = true
        startTimeContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        startTimeContainer.heightAnchor.constraint(equalTo: calendarContainer.heightAnchor, multiplier: 1/4).isActive = true

        startTimeContainer.addSubview(startTimeLabel)
        startTimeLabel.centerYAnchor.constraint(equalTo: startTimeContainer.centerYAnchor).isActive = true
        startTimeLabel.leftAnchor.constraint(equalTo: startTimeContainer.leftAnchor, constant: 10).isActive = true
        
        startTimeContainer.addSubview(startTimePicker)
        startTimePicker.leftAnchor.constraint(equalTo: startTimeLabel.rightAnchor, constant: 30).isActive = true
        startTimePicker.centerYAnchor.constraint(equalTo: startTimeContainer.centerYAnchor).isActive = true
        startTimePicker.widthAnchor.constraint(equalTo: startTimeContainer.widthAnchor, multiplier: 1/2).isActive = true
        
        view.addSubview(endTimeContainer)
        endTimeContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        endTimeContainer.topAnchor.constraint(equalTo: startTimeContainer.bottomAnchor, constant: 10).isActive = true
        endTimeContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        endTimeContainer.heightAnchor.constraint(equalTo: calendarContainer.heightAnchor, multiplier: 1/4).isActive = true
        
        endTimeContainer.addSubview(endTimeLabel)
        endTimeLabel.centerYAnchor.constraint(equalTo: endTimeContainer.centerYAnchor).isActive = true
        endTimeLabel.leftAnchor.constraint(equalTo: endTimeContainer.leftAnchor, constant: 10).isActive = true
        
        endTimeContainer.addSubview(endTimePicker)
        endTimePicker.leftAnchor.constraint(equalTo: endTimeLabel.rightAnchor, constant: 30).isActive = true
        endTimePicker.centerYAnchor.constraint(equalTo: endTimeContainer.centerYAnchor).isActive = true
        endTimePicker.widthAnchor.constraint(equalTo: endTimeContainer.widthAnchor, multiplier: 1/2).isActive = true

    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSave(){
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
        let v = CalenderView(theme: MyTheme.light)
        v.changeTheme()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
}


