//
//  PostController.swift
//  Hour
//
//  Created by Moses Oh on 2/19/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import GeoFire

class PostController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static var controller: PostController?
    
    var geoFire: GeoFire!
    var ref: DatabaseReference!
    
    var feedController: FeedController?
    var loginController: LoginController?
    
    var numberOfPeople: Int = 2
    var category: String = ""
    var date: Date?
    var startTime: String = ""
    var endTime: String = ""
    var imgSelected: Bool = false
    
    var categoryButtons : [CategoryButton] = [CategoryButton]()
    var dispatchGroup = DispatchGroup()
    
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.navigationBar.tintColor = UIColor.white
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)


        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        let scaledImage = selectedImageFromPicker?.resize(targetSize: CGSize(width: 100, height: 100))
        let decompressedImage = UIImage(data: (scaledImage?.jpeg(.low))!)
        let descaledImage = UIImage(data: (decompressedImage?.jpeg(.low))!)
        postImageView.setImage(descaledImage, for: .normal)
        postImageView.imageView?.contentMode = .scaleAspectFit
        postImageView.layer.borderColor = UIColor.clear.cgColor
        postImageContainer.image = decompressedImage
        
        imgSelected = true
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PostController.controller = self
        feedController = FeedController.controller
        
        self.hideKeyboard()
        scrollView = UIScrollView(frame: view.bounds)
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(handlePost))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        

        ref = Database.database().reference()
        geoFire = GeoFire(firebaseRef: ref.child("posts_location"))
    
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: (privateContainer.frame.origin.y + privateContainer.frame.size.height))
    }
    
    let postImageContainer: UIImageView = {
        let ac = UIImageView()
        ac.contentMode = .scaleAspectFill
        ac.layer.masksToBounds = true
        ac.translatesAutoresizingMaskIntoConstraints = false
        return ac
    }()
    
    let postImageEffect: UIVisualEffectView = {
        let blurr = UIBlurEffect(style: UIBlurEffect.Style.light)
        let ev = UIVisualEffectView(effect: blurr)
        ev.layer.masksToBounds = true
        ev.translatesAutoresizingMaskIntoConstraints = false
        return ev
    }()
    
    let postImageView: UIButton = {
        let imageView = UIButton()
        imageView.imageView?.contentMode = .scaleAspectFit
        imageView.setImage(#imageLiteral(resourceName: "addPhoto"), for: .normal)
        imageView.backgroundColor = UIColor.white
        imageView.imageView?.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.addTarget(self, action: #selector(handleSelectProfileImageView), for: .touchUpInside)
        return imageView
    }()
    
    let activityContainer: UIView = {
        let ac = UIView()
        ac.backgroundColor = UIColor.white
        ac.translatesAutoresizingMaskIntoConstraints = false
//        ac.layer.cornerRadius = 5
//        ac.layer.masksToBounds = true
        return ac
    }()
    
    let activityTextField: UITextField = {
        let atv = UITextField()
        atv.placeholder = " Activity"
        atv.text = ""
        atv.font = UIFont.init(name: "Helvetica Neue", size: 18)
        atv.textColor = UIColor.gray
        atv.translatesAutoresizingMaskIntoConstraints = false
        return atv
    }()
    
    let descriptionContainer: UIView = {
        let dc = UIView()
        dc.backgroundColor = UIColor.white
        dc.translatesAutoresizingMaskIntoConstraints = false
        dc.layer.cornerRadius = 5
        dc.layer.masksToBounds = true
        return dc
    }()
    
    let descriptionTextField: UITextView = {
        let dtf = UITextView()
        dtf.font = UIFont.init(name: "Helvetica Neue", size: 18)
        dtf.text = ""
        dtf.textColor = UIColor.gray
        dtf.placeholder = " Description"
        dtf.isScrollEnabled = true
        dtf.translatesAutoresizingMaskIntoConstraints = false
        return dtf
    }()
    
    let dateAndTimeContainer: UIView = {
        let dc = UIView()
        dc.backgroundColor = UIColor.white
        dc.translatesAutoresizingMaskIntoConstraints = false
//        dc.layer.cornerRadius = 5
//        dc.layer.masksToBounds = true
        return dc
    }()
    
    let dateAndTimeLabel: UIButton = {
        let datl = UIButton(type: .system)
        datl.setTitle(" Date and Time", for: .normal)
        datl.setTitleColor(UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1), for: .normal)
        datl.titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 18)!
        datl.addTarget(self, action: #selector(handleDateAndTimeView), for: .touchUpInside)
        datl.translatesAutoresizingMaskIntoConstraints = false
        return datl
    }()
    
    let locationContainer: UIView = {
        let lc = UIView()
        lc.backgroundColor = UIColor.white
        lc.translatesAutoresizingMaskIntoConstraints = false
//        lc.layer.cornerRadius = 5
//        lc.layer.masksToBounds = true
        return lc
    }()
    
    let locationLabel: UIButton = {
        let ll = UIButton(type: .system)
        ll.setTitle(" Location", for: .normal)
        ll.setTitleColor(UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1), for: .normal)
        ll.titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 18)!
        ll.addTarget(self, action: #selector(handleLocationView), for: .touchUpInside)
        ll.translatesAutoresizingMaskIntoConstraints = false
        return ll
    }()
    
    //Category
    let categoryContainer: UIView = {
        let cc = UIView()
        cc.backgroundColor = UIColor.white
        cc.translatesAutoresizingMaskIntoConstraints = false
//        cc.layer.cornerRadius = 5
//        cc.layer.masksToBounds = true
        return cc
    }()
    
    let categoryLabel: UILabel = {
        let cl = UILabel()
        cl.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        cl.text = " Category"
        cl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        cl.translatesAutoresizingMaskIntoConstraints = false
        return cl
    }()
    
    @objc func categoryPressed(sender: CategoryButton!) {
        category = (sender.titleLabel?.text)!
        if(category == "Nature")
        {
//            postImageView.image = #imageLiteral(resourceName: "nature")
            postImageView.backgroundColor = UIColor.green
            postImageView.contentMode = .scaleAspectFit
        }
        if(category == "Trips")
        {
//            postImageView.image = #imageLiteral(resourceName: "trips")
            postImageView.backgroundColor = UIColor.yellow
            postImageView.contentMode = .scaleAspectFit
        }
        if(category == "Nightlife")
        {
//            postImageView.image = #imageLiteral(resourceName: "nightlife")
            postImageView.backgroundColor = UIColor.purple
            postImageView.contentMode = .scaleAspectFit
        }
        if(category == "Sports")
        {
//            postImageView.image = #imageLiteral(resourceName: "sports")
            postImageView.backgroundColor = UIColor.brown
            postImageView.contentMode = .scaleAspectFit
        }
        if(category == "Food & Drink")
        {
//            postImageView.image = #imageLiteral(resourceName: "food&drink")
            postImageView.backgroundColor = UIColor.red
            postImageView.contentMode = .scaleAspectFit
        }
        if(category == "Concerts")
        {
//            postImageView.image = #imageLiteral(resourceName: "concerts")
            postImageView.backgroundColor = UIColor.blue
            postImageView.contentMode = .scaleAspectFit
        }
        for button in categoryButtons {
            if(button.titleLabel?.text != category)
            {
                button.activatedButton(bool: false)
            }
        }
    }
    
    let tripsButton: CategoryButton = {
        let tb = CategoryButton()
        tb.setTitle("Trips", for: .normal)
        tb.addTarget(self, action: #selector(categoryPressed), for: UIControl.Event.touchUpInside)
        return tb
    }()

    let natureButton: CategoryButton = {
        let nb = CategoryButton()
        nb.setTitle("Nature", for: .normal)
        nb.addTarget(self, action: #selector(categoryPressed), for: UIControl.Event.touchUpInside)
        return nb
    }()
    
    let foodDrinkButton: CategoryButton = {
        let fdb = CategoryButton()
        fdb.setTitle("Food & Drink", for: .normal)
        fdb.addTarget(self, action: #selector(categoryPressed), for: UIControl.Event.touchUpInside)
        return fdb
    }()
    
    let concertsButton: CategoryButton = {
        let cb = CategoryButton()
        cb.setTitle("Concerts", for: .normal)
        cb.addTarget(self, action: #selector(categoryPressed), for: UIControl.Event.touchUpInside)
        return cb
    }()
    
    let nightlifeButton: CategoryButton = {
        let nlb = CategoryButton()
        nlb.setTitle("Nightlife", for: .normal)
        nlb.addTarget(self, action: #selector(categoryPressed), for: UIControl.Event.touchUpInside)
        return nlb
    }()
    
    let carpoolButton: CategoryButton = {
        let cb = CategoryButton()
        cb.setTitle("Carpool", for: .normal)
        cb.addTarget(self, action: #selector(categoryPressed), for: UIControl.Event.touchUpInside)
        return cb
    }()
    
    let sportsButton: CategoryButton = {
        let sb = CategoryButton()
        sb.setTitle("Sports", for: .normal)
        sb.addTarget(self, action: #selector(categoryPressed), for: UIControl.Event.touchUpInside)
        return sb
    }()
    
    let workButton: CategoryButton = {
        let wb = CategoryButton()
        wb.setTitle("Work", for: .normal)
        wb.addTarget(self, action: #selector(categoryPressed), for: UIControl.Event.touchUpInside)
        return wb
    }()
    
    
    // number of people
    let numberOfPeopleContainer: UIView = {
        let nopc = UIView()
        nopc.backgroundColor = UIColor.white
        nopc.translatesAutoresizingMaskIntoConstraints = false
        nopc.layer.cornerRadius = 5
        nopc.layer.masksToBounds = true
        return nopc
    }()
    
    let numberOfPeopleLabel: UILabel = {
        let nopl = UILabel()
        nopl.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        nopl.text = " Number of People"
        nopl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        nopl.translatesAutoresizingMaskIntoConstraints = false
        return nopl
    }()
    
    var number: UILabel = {
        let no = UILabel()
        no.text = "1"
        no.textColor = UIColor.gray
        no.font = UIFont.init(name: "Helvetica Neue", size: 25)
        no.translatesAutoresizingMaskIntoConstraints = false
        return no
    }()
    
    let addButton: UIButton = {
        let ab = UIButton()
        ab.setTitle("+", for: .normal)
        ab.titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 30)
        ab.setTitleColor(UIColor.gray, for: .normal)
        ab.addTarget(self, action: #selector(addOnePerson), for: .touchUpInside)
        ab.translatesAutoresizingMaskIntoConstraints = false
        return ab
    }()
    
    let deleteButton: UIButton = {
        let db = UIButton()
        db.setTitle("-", for: .normal)
        db.titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 30)
        db.setTitleColor(UIColor.gray, for: .normal)
        db.addTarget(self, action: #selector(deleteOnePerson), for: .touchUpInside)
        db.translatesAutoresizingMaskIntoConstraints = false
        return db
    }()
    
    let enableChatContainer: UIView = {
        let nopc = UIView()
        nopc.backgroundColor = UIColor.white
        nopc.translatesAutoresizingMaskIntoConstraints = false
        nopc.layer.cornerRadius = 5
        nopc.layer.masksToBounds = true
        return nopc
    }()
    
    let enableChatLabel: UILabel = {
        let ecl = UILabel()
        ecl.text = " Group Chat"
        ecl.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        ecl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        ecl.translatesAutoresizingMaskIntoConstraints = false
        return ecl
    }()
    
    let enableChatSwitch : UISwitch = {
        let ecs = UISwitch()
        ecs.translatesAutoresizingMaskIntoConstraints = false
        ecs.onTintColor = AppDelegate.THEME
        return ecs
    }()
    
    let privateContainer: UIView = {
        let nopc = UIView()
        nopc.backgroundColor = UIColor.white
        nopc.translatesAutoresizingMaskIntoConstraints = false
        nopc.layer.cornerRadius = 5
        nopc.layer.masksToBounds = true
        return nopc
    }()
    
    let privateLabel: UILabel = {
        let ecl = UILabel()
        ecl.text = " Private"
        ecl.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        ecl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        ecl.translatesAutoresizingMaskIntoConstraints = false
        return ecl
    }()
    
    let privateSwitch : UISwitch = {
        let ecs = UISwitch()
        ecs.translatesAutoresizingMaskIntoConstraints = false
        ecs.onTintColor = AppDelegate.THEME
        return ecs
    }()
    
    let enableChatTitleView: UIView = {
        let ac = UIView()
        ac.backgroundColor = UIColor.white
        ac.translatesAutoresizingMaskIntoConstraints = false
        return ac
    }()
    
    let enableChatTitleText: UITextField = {
        let atv = UITextField()
        atv.placeholder = " Group Chat Title"
        atv.font = UIFont.init(name: "Helvetica Neue", size: 18)
        atv.textColor = UIColor.gray
        atv.translatesAutoresizingMaskIntoConstraints = false
        return atv
    }()
    
    func setupViews() {
        
        /** ScrollView Setup **/
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        
        /** Activity Image Setup **/
        scrollView.addSubview(postImageContainer)
        postImageContainer.SetContainer(otherContainer: scrollView, top: 0, height: 150)

        postImageContainer.addSubview(postImageEffect)
        postImageEffect.widthAnchor.constraint(equalTo: postImageContainer.widthAnchor).isActive = true
        postImageEffect.heightAnchor.constraint(equalTo: postImageContainer.heightAnchor).isActive = true
        postImageEffect.topAnchor.constraint(equalTo: postImageContainer.topAnchor).isActive = true

        scrollView.addSubview(postImageView)
        postImageView.centerXAnchor.constraint(equalTo: postImageContainer.centerXAnchor).isActive  = true
        postImageView.centerYAnchor.constraint(equalTo: postImageContainer.centerYAnchor).isActive  = true
        postImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        postImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        /** Activity Setup **/
        scrollView.addSubview(activityContainer)
        activityContainer.SetContainer(otherContainer: postImageContainer, top: 5, height: 50)
        activityContainer.addSubview(activityTextField)
        activityTextField.centerYAnchor.constraint(equalTo: activityContainer.centerYAnchor).isActive = true
        activityTextField.leftAnchor.constraint(equalTo: activityContainer.leftAnchor, constant: 10).isActive = true
        activityTextField.widthAnchor.constraint(equalTo: activityContainer.widthAnchor, constant: -10).isActive = true
        
        /** Description Setup**/
        scrollView.addSubview(descriptionContainer)
        descriptionContainer.SetContainer(otherContainer: activityContainer, top: 5, height: 150)
        descriptionContainer.addSubview(descriptionTextField)
        descriptionTextField.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 10).isActive = true
        descriptionTextField.heightAnchor.constraint(equalTo: descriptionContainer.heightAnchor, constant: 10).isActive = true
        descriptionTextField.leftAnchor.constraint(equalTo: descriptionContainer.leftAnchor, constant: 5).isActive = true
        descriptionTextField.widthAnchor.constraint(equalTo: descriptionContainer.widthAnchor, constant: -10).isActive = true

        /** Date and Time Setup **/
        scrollView.addSubview(dateAndTimeContainer)
        dateAndTimeContainer.SetContainer(otherContainer: descriptionContainer, top: 5, height: 50)
        dateAndTimeContainer.addSubview(dateAndTimeLabel)
        dateAndTimeLabel.centerYAnchor.constraint(equalTo: dateAndTimeContainer.centerYAnchor).isActive = true
        dateAndTimeLabel.leftAnchor.constraint(equalTo: dateAndTimeContainer.leftAnchor, constant: 10).isActive = true

        /** Location Setup **/
        scrollView.addSubview(locationContainer)
        locationContainer.SetContainer(otherContainer: dateAndTimeContainer, top: 5, height: 50)
        locationContainer.addSubview(locationLabel)
        locationLabel.centerYAnchor.constraint(equalTo: locationContainer.centerYAnchor).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: locationContainer.leftAnchor, constant: 10).isActive = true

        /** Category Setup **/
        scrollView.addSubview(categoryContainer)
        categoryContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        categoryContainer.topAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: 5).isActive = true
        categoryContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        categoryContainer.addSubview(categoryLabel)
        categoryLabel.topAnchor.constraint(equalTo: categoryContainer.topAnchor, constant: 10).isActive = true
        categoryLabel.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 10).isActive = true

        categoryContainer.addSubview(tripsButton)
        tripsButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20).isActive = true
        tripsButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        tripsButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        tripsButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/6).isActive = true

        categoryContainer.addSubview(natureButton)
        natureButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20).isActive = true
        natureButton.leftAnchor.constraint(equalTo: tripsButton.rightAnchor, constant: 40).isActive = true
        natureButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        natureButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/6).isActive = true

        categoryContainer.addSubview(foodDrinkButton)
        foodDrinkButton.topAnchor.constraint(equalTo: tripsButton.bottomAnchor, constant: 20).isActive = true
        foodDrinkButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        foodDrinkButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        foodDrinkButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/6).isActive = true

        categoryContainer.addSubview(concertsButton)
        concertsButton.topAnchor.constraint(equalTo: natureButton.bottomAnchor, constant: 20).isActive = true
        concertsButton.leftAnchor.constraint(equalTo: foodDrinkButton.rightAnchor, constant: 40).isActive = true
        concertsButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        concertsButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/6).isActive = true

        categoryContainer.addSubview(nightlifeButton)
        nightlifeButton.topAnchor.constraint(equalTo: foodDrinkButton.bottomAnchor, constant:20).isActive = true
        nightlifeButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        nightlifeButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        nightlifeButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/6).isActive = true

        categoryContainer.addSubview(sportsButton)
        sportsButton.topAnchor.constraint(equalTo: concertsButton.bottomAnchor, constant: 20).isActive = true
        sportsButton.leftAnchor.constraint(equalTo: nightlifeButton.rightAnchor, constant: 40).isActive = true
        sportsButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        sportsButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/6).isActive = true
        
        categoryContainer.bottomAnchor.constraint(equalTo: sportsButton.bottomAnchor, constant: 20).isActive = true

        categoryButtons.append(tripsButton)
        categoryButtons.append(natureButton)
        categoryButtons.append(foodDrinkButton)
        categoryButtons.append(concertsButton)
        categoryButtons.append(nightlifeButton)
        categoryButtons.append(sportsButton)

        /** Number of People Setup **/
        scrollView.addSubview(numberOfPeopleContainer)
        numberOfPeopleContainer.SetContainer(otherContainer: categoryContainer, top: 5, height: 60)
        numberOfPeopleContainer.addSubview(numberOfPeopleLabel)
        
        numberOfPeopleLabel.centerYAnchor.constraint(equalTo: numberOfPeopleContainer.centerYAnchor).isActive = true
        numberOfPeopleLabel.leftAnchor.constraint(equalTo: numberOfPeopleContainer.leftAnchor, constant: 10).isActive = true

        numberOfPeopleContainer.addSubview(addButton)
        addButton.centerYAnchor.constraint(equalTo: numberOfPeopleLabel.centerYAnchor).isActive = true
        addButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        numberOfPeopleContainer.addSubview(number)
        number.centerYAnchor.constraint(equalTo: numberOfPeopleLabel.centerYAnchor).isActive = true
        number.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -65).isActive = true
        
        numberOfPeopleContainer.addSubview(deleteButton)
        deleteButton.centerYAnchor.constraint(equalTo: numberOfPeopleLabel.centerYAnchor).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: number.leftAnchor, constant: -20).isActive = true
        
       

        

        /** Enable Chat Setup **/
        scrollView.addSubview(enableChatContainer)
        enableChatContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        enableChatContainer.topAnchor.constraint(equalTo: numberOfPeopleContainer.bottomAnchor, constant: 5).isActive = true
        enableChatContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        enableChatContainerHeightAnchor = enableChatContainer.heightAnchor.constraint(equalToConstant: 50)
        enableChatContainerHeightAnchor?.isActive = true
        
        enableChatContainer.addSubview(enableChatLabel)
        enableChatLabel.topAnchor.constraint(equalTo: enableChatContainer.topAnchor, constant: 10).isActive = true
        enableChatLabel.leftAnchor.constraint(equalTo: enableChatContainer.leftAnchor, constant: 10).isActive = true
        
        enableChatContainer.addSubview(enableChatSwitch)
        enableChatSwitch.topAnchor.constraint(equalTo: enableChatContainer.topAnchor, constant: 10).isActive = true
        enableChatSwitch.rightAnchor.constraint(equalTo: enableChatContainer.rightAnchor, constant: -50).isActive = true
        
        /** Private Switch Setup **/
        scrollView.addSubview(privateContainer)
        privateContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        privateContainer.topAnchor.constraint(equalTo: enableChatContainer.bottomAnchor, constant: 5).isActive = true
        privateContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        privateContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        privateContainer.addSubview(privateLabel)
        privateLabel.topAnchor.constraint(equalTo: privateContainer.topAnchor, constant: 10).isActive = true
        privateLabel.leftAnchor.constraint(equalTo: privateContainer.leftAnchor, constant: 10).isActive = true
        
        privateContainer.addSubview(privateSwitch)
        privateSwitch.topAnchor.constraint(equalTo: privateContainer.topAnchor, constant: 10).isActive = true
        privateSwitch.rightAnchor.constraint(equalTo: privateContainer.rightAnchor, constant: -50).isActive = true
        
        scrollView.addSubview(enableChatTitleView)
        enableChatTitleView.topAnchor.constraint(equalTo: enableChatContainer.bottomAnchor, constant: 5).isActive = true
        enableChatTitleView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        enableChatTitleViewHeightAnchor = enableChatTitleView.heightAnchor.constraint(equalToConstant: 0)
        enableChatTitleViewHeightAnchor?.isActive = true
        
        
        
//        enableChatTitleView.addSubview(enableChatTitleText)
//        enableChatTitleTextHeightAnchor = enableChatTitleText.centerYAnchor.constraint(equalTo: enableChatTitleView.centerYAnchor)
//        enableChatTitleTextHeightAnchor?.isActive = true
//        enableChatTitleText.leftAnchor.constraint(equalTo: enableChatTitleView.leftAnchor, constant: 10).isActive = true
//        enableChatTitleText.widthAnchor.constraint(equalTo: enableChatTitleView.widthAnchor, constant: -10).isActive = true
        
    }
    
    var enableChatTitleViewHeightAnchor: NSLayoutConstraint?
    var enableChatTitleTextHeightAnchor: NSLayoutConstraint?
    var enableChatContainerHeightAnchor: NSLayoutConstraint?
    
    @objc func addOnePerson() {
        if(numberOfPeople < 10)
        {
            numberOfPeople += 1
            number.text = "\(numberOfPeople)"
        }
    }
    
    @objc func deleteOnePerson() {
        if(numberOfPeople > 2)
        {
            numberOfPeople -= 1
        }
        number.text = "\(numberOfPeople)"
    }
    
    @objc func handleDateAndTimeView() {
        let dateAndTimeController = DateAndTimeController()
        let navController = UINavigationController(rootViewController: dateAndTimeController)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc func handleLocationView() {
        let locationController = LocationController()
        let navController = UINavigationController(rootViewController: locationController)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    func checkIfNil() -> Bool {
        if(activityTextField.text == "")
        {
            activityTextField.attributedPlaceholder = NSAttributedString(string: " Activity", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        else
        {
            activityTextField.attributedPlaceholder = NSAttributedString(string: " Activity", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        }
        
        if(date == nil)
        {
            dateAndTimeLabel.setTitleColor(UIColor.red, for: .normal)
            return false
        }
        else
        {
            dateAndTimeLabel.setTitleColor(UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1), for: .normal)
        }
        
        if(locationLabel.titleLabel?.text == " Location")
        {
            locationLabel.setTitleColor(UIColor.red, for: .normal)
            return false
        }
        else
        {
            locationLabel.setTitleColor(UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1), for: .normal)
        }
        
        if(dateAndTimeLabel.title(for: .normal) == " Date and Time")
        {
            dateAndTimeLabel.setTitleColor(UIColor.red, for: .normal)
            return false
        }
        else
        {
            dateAndTimeLabel.setTitleColor(UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1), for: .normal)
        }
        
        if(category == "")
        {
            categoryLabel.textColor = UIColor.red
            return false
        }
        else
        {
            categoryLabel.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        }
        
        return true
    }
    
    @objc func handlePost(){
        
        
        if(checkIfNil())
        {
            //initiate loading sign
            let barButton = UIBarButtonItem(customView: activityIndicator)
            self.navigationItem.setRightBarButton(barButton, animated: true)
            activityIndicator.startAnimating()
            
            let key = ref.child("posts").childByAutoId().key
            let userID = Auth.auth().currentUser?.uid
            var enabledChat = 0
            ref.child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
                if(self.enableChatSwitch.isOn)
                {
                    enabledChat = 1
                    MessagesController.controller?.createChat(uid: userID!, name: self.activityTextField.text!, key: key)
                }
                
                //convert string address to CLLocation and set GeoFire location
                let address = self.locationLabel.title(for: .normal)
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(address!) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                        else {
                            // handle no location found
                            return
                    }
                    self.geoFire.setLocation(location, forKey: "\(key)")
                }
                
                //update Firebase storage
                var imageUrl = ""
                
                if (self.imgSelected)
                {
                    let storageRef = Storage.storage().reference().child("posts").child(key)
                    if let uploadImg = (self.postImageView.imageView?.image)!.pngData()
                    {
                        storageRef.putData(uploadImg, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                return
                            }
                            storageRef.downloadURL(completion: { (url, error) in
                                if error != nil {
                                    return
                                }
                                imageUrl = (url?.absoluteString)!
                                self.uploadPostData(snapshot: snapshot, userID: userID!, enabledChat: enabledChat, imageUrl: imageUrl, key: key)
                            })

                            
                        })
                    }
                }
                else
                {
                    self.uploadPostData(snapshot: snapshot, userID: userID!, enabledChat: enabledChat, imageUrl: "", key: key)
                }
               
            }
            print("posted")
        }
    }
    
    func uploadPostData(snapshot: DataSnapshot, userID: String, enabledChat: Int, imageUrl: String, key: String) {
        var profileImageUrl = ""
        var privateEnabled = 0
        if(privateSwitch.isOn)
        {
            privateEnabled = 1
        }
        self.dispatchGroup.enter()
        Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                if let imageUrl = dictionary["imageUrl"] as? String
                {
                    profileImageUrl = imageUrl
                }
                else
                {
                    profileImageUrl = ""
                }
                self.dispatchGroup.leave()
            }
        }
        if let activity = self.activityTextField.text, let description = self.descriptionTextField.text, let location = self.locationLabel.title(for: .normal), let date = self.date!.dayOfWeek()
        {
            dispatchGroup.notify(queue: .main) {
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let dateFormatter:DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
                    let usersUid = [userID: ["status": -1, "imageUrl": profileImageUrl]]
                    let post = ["name": dictionary["name"] ?? "noname",
                                "uid": dictionary["uid"] ?? "nouid",
                                "imageUrl": imageUrl,
                                "activity": activity,
                                "description": description,
                                "time": ServerValue.timestamp(),
                                "location": location,
                                "groupCount": self.numberOfPeople,
                                "usersUid": usersUid,
                                "category": self.category,
                                "date": date,
                                "startTime": self.startTime,
                                "endTime": self.endTime,
                                "enabledChat": enabledChat,
                                "private": privateEnabled] as [String : Any]
                    let child = ["/posts/\(key)": post]
                    let userPosts = [key: -1]
                    
                    //update FireBase posts
                    let ref = Database.database().reference().child("users").child(userID).child("posts")
                    ref.updateChildValues(userPosts) {(err,ref) in
                        if err != nil{
                            print(err ?? "error")
                            return
                        }
                    }
                    
                    self.ref.updateChildValues(child) { (err, ref) in
                        if err != nil{
                            print(err ?? "error")
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.feedController?.determineMyCurrentLocation()
                            self.activityIndicator.stopAnimating()
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                    }
                }
            }
        }
        else
        {
            print("NOPPPE")
        }
        
        
    }
    
    


}

extension UIView {
    func SetContainer(otherContainer: UIView, top: CGFloat, height: CGFloat) {
        self.centerXAnchor.constraint(equalTo: otherContainer.centerXAnchor).isActive = true
        self.topAnchor.constraint(equalTo: otherContainer.bottomAnchor, constant: top).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.widthAnchor.constraint(equalTo: otherContainer.widthAnchor).isActive = true
    }
    
    func SetContainer(topContainer: UIView, otherContainer: UIView, top: CGFloat, left: CGFloat, widthMult: CGFloat, heightMult: CGFloat)
    {
        self.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: top).isActive = true
        self.leftAnchor.constraint(equalTo: otherContainer.leftAnchor, constant: left).isActive = true
        self.widthAnchor.constraint(equalTo: otherContainer.widthAnchor, multiplier: widthMult).isActive = true
        self.heightAnchor.constraint(equalTo: otherContainer.heightAnchor, multiplier: heightMult).isActive = true
    }
    
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0.1
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
    
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}


extension PostController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
    
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
