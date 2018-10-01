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
        tl.text = "Start"
        tl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let startTimePicker: UIDatePicker = {
        let tp = UIDatePicker()
        tp.datePickerMode = UIDatePicker.Mode.time
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
        tl.text = "End"
        tl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let endTimePicker: UIDatePicker = {
        let tp = UIDatePicker()
        tp.datePickerMode = UIDatePicker.Mode.time
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
        
        let rightBarBtn = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        rightBarBtn.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = leftBarBtn
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calenderView.myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    let mainView: UIView = {
        let mv = UIView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        return mv
    }()
    
    func setupViews(){
        view.addSubview(mainView)
        mainView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        mainView.addSubview(calendarContainer)
        calendarContainer.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        calendarContainer.topAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive=true
        calendarContainer.widthAnchor.constraint(equalTo: mainView.widthAnchor, constant: -20).isActive = true
        calendarContainer.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 1/1.88).isActive = true
        
        calendarContainer.addSubview(calenderView)
        calenderView.topAnchor.constraint(equalTo: calendarContainer.topAnchor, constant: 5).isActive = true
        calenderView.centerXAnchor.constraint(equalTo: calendarContainer.centerXAnchor).isActive = true
        calenderView.widthAnchor.constraint(equalTo: calendarContainer.widthAnchor, constant: -10).isActive = true
        calenderView.heightAnchor.constraint(equalTo: calendarContainer.heightAnchor).isActive = true
        
        mainView.addSubview(startTimeContainer)
        startTimeContainer.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        startTimeContainer.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: 10).isActive = true
        startTimeContainer.widthAnchor.constraint(equalTo: mainView.widthAnchor, constant: -20).isActive = true
        startTimeContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true

        startTimeContainer.addSubview(startTimeLabel)
        startTimeLabel.centerYAnchor.constraint(equalTo: startTimeContainer.centerYAnchor).isActive = true
        startTimeLabel.leftAnchor.constraint(equalTo: startTimeContainer.leftAnchor, constant: 10).isActive = true
        
        startTimeContainer.addSubview(startTimePicker)
        startTimePicker.rightAnchor.constraint(equalTo: startTimeContainer.rightAnchor, constant: -60).isActive = true
        startTimePicker.centerYAnchor.constraint(equalTo: startTimeContainer.centerYAnchor).isActive = true
        startTimePicker.widthAnchor.constraint(equalTo: startTimeContainer.widthAnchor, multiplier: 1/2).isActive = true
        
        mainView.addSubview(endTimeContainer)
        endTimeContainer.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        endTimeContainer.topAnchor.constraint(equalTo: startTimeContainer.bottomAnchor, constant: 10).isActive = true
        endTimeContainer.widthAnchor.constraint(equalTo: mainView.widthAnchor, constant: -20).isActive = true
        endTimeContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        endTimeContainer.addSubview(endTimeLabel)
        endTimeLabel.centerYAnchor.constraint(equalTo: endTimeContainer.centerYAnchor).isActive = true
        endTimeLabel.leftAnchor.constraint(equalTo: endTimeContainer.leftAnchor, constant: 10).isActive = true
        
        endTimeContainer.addSubview(endTimePicker)
        endTimePicker.rightAnchor.constraint(equalTo: endTimeContainer.rightAnchor, constant: -60).isActive = true
        endTimePicker.centerYAnchor.constraint(equalTo: endTimeContainer.centerYAnchor).isActive = true
        endTimePicker.widthAnchor.constraint(equalTo: endTimeContainer.widthAnchor, multiplier: 1/2).isActive = true

    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSave(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = TimeZone.current
        
        let postController = PostController.controller!
        
        let startTime = dateFormatter.string(from: startTimePicker.date)
        let endTime = dateFormatter.string(from: endTimePicker.date)
        postController.date = makeDate(year: calenderView.currentYear, month: calenderView.currentMonthIndex, day: calenderView.currentDay, hr: 0, min: 0, sec: 0)
        postController.startTime = startTime
        postController.endTime = endTime
        
        postController.dateAndTimeLabel.setTitle("\(postController.date!.dayOfWeek()!)   \(startTime)-\(endTime)", for: .normal)
        postController.dateAndTimeLabel.setTitleColor(UIColor.gray, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    let calenderView: CalenderView = {
        let v = CalenderView(theme: MyTheme.light)
        v.changeTheme()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    func makeDate(year: Int, month: Int, day: Int, hr: Int, min: Int, sec: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        // calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
        return calendar.date(from: components)!
    }
    
}


