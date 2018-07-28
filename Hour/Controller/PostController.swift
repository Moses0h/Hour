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

class PostController: UIViewController {

    var geoFire: GeoFire!
    var ref: DatabaseReference!
    
    var feedController: FeedController?
    var loginController: LoginController?
    var childUpdates: [String: Any] = [:]
    var numberOfPeople: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(handlePost))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        ref = Database.database().reference()
        geoFire = GeoFire(firebaseRef: ref.child("posts_location"))
    
        setupViews()
    }
    
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
    
    let tripsButton: CategoryButton = {
        let tb = CategoryButton()
        tb.setTitle("Trips", for: .normal)
        return tb
    }()

    let natureButton: CategoryButton = {
        let nb = CategoryButton()
        nb.setTitle("Nature", for: .normal)
        return nb
    }()
    
    let foodDrinkButton: CategoryButton = {
        let fdb = CategoryButton()
        fdb.setTitle("Food & Drink", for: .normal)
        return fdb
    }()
    
    let concertsButton: CategoryButton = {
        let cb = CategoryButton()
        cb.setTitle(" Concerts", for: .normal)
        return cb
    }()
    
    let nightlifeButton: CategoryButton = {
        let nlb = CategoryButton()
        nlb.setTitle(" Nightlife", for: .normal)
        return nlb
    }()
    
    let carpoolButton: CategoryButton = {
        let cb = CategoryButton()
        cb.setTitle(" Carpool", for: .normal)
        return cb
    }()
    
    let sportsButton: CategoryButton = {
        let sb = CategoryButton()
        sb.setTitle(" Sports", for: .normal)
        return sb
    }()
    
    let workButton: CategoryButton = {
        let wb = CategoryButton()
        wb.setTitle(" Work", for: .normal)
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
        no.text = "0"
        no.textColor = UIColor.gray
        no.font = UIFont.init(name: "Helvetica Neue", size: 20)
        no.translatesAutoresizingMaskIntoConstraints = false
        return no
    }()
    
    let addButton: BounceButton = {
        let ab = BounceButton()
        ab.setTitle("+", for: .normal)
        ab.addTarget(self, action: #selector(addOnePerson), for: .touchUpInside)
        return ab
    }()
    
    let deleteButton: BounceButton = {
        let db = BounceButton()
        db.setTitle("-", for: .normal)
        db.addTarget(self, action: #selector(deleteOnePerson), for: .touchUpInside)
        return db
    }()
    
    let priceLabel: UILabel = {
        let pl = UILabel()
        return pl
    }()
    
    let postButton: BounceButton = {
        let pb = BounceButton(type: .system)
        pb.setTitle("Post", for: .normal)
        pb.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        return pb
    }()
    
    func setupViews() {
        //activity
        
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: self.view.frame.size.height + 200)
        scrollView.isScrollEnabled = true
        
        view.addSubview(scrollView)

        scrollView.addSubview(activityContainer)
        
        activityContainer.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        activityContainer.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true
        activityContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        activityContainer.addSubview(activityTextField)
        
        activityTextField.centerYAnchor.constraint(equalTo: activityContainer.centerYAnchor).isActive = true
        activityTextField.leftAnchor.constraint(equalTo: activityContainer.leftAnchor, constant: 10).isActive = true
        activityTextField.widthAnchor.constraint(equalTo: activityContainer.widthAnchor, constant: -10).isActive = true
        //description
        scrollView.addSubview(descriptionContainer)
        
        descriptionContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionContainer.topAnchor.constraint(equalTo: activityContainer.bottomAnchor, constant: 5).isActive = true
        descriptionContainer.heightAnchor.constraint(equalToConstant: 150).isActive = true
        descriptionContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        descriptionContainer.addSubview(descriptionTextField)
        
        descriptionTextField.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 10).isActive = true
        descriptionTextField.heightAnchor.constraint(equalTo: descriptionContainer.heightAnchor, constant: 10).isActive = true
        descriptionTextField.leftAnchor.constraint(equalTo: descriptionContainer.leftAnchor, constant: 5).isActive = true
        descriptionTextField.widthAnchor.constraint(equalTo: descriptionContainer.widthAnchor, constant: -10).isActive = true
        //date and time
        scrollView.addSubview(dateAndTimeContainer)
        
        dateAndTimeContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateAndTimeContainer.topAnchor.constraint(equalTo: descriptionContainer.bottomAnchor, constant: 5).isActive = true
        dateAndTimeContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        dateAndTimeContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        dateAndTimeContainer.addSubview(dateAndTimeLabel)
        
        dateAndTimeLabel.centerYAnchor.constraint(equalTo: dateAndTimeContainer.centerYAnchor).isActive = true
        dateAndTimeLabel.leftAnchor.constraint(equalTo: dateAndTimeContainer.leftAnchor, constant: 10).isActive = true
        //location
        scrollView.addSubview(locationContainer)
        
        locationContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationContainer.topAnchor.constraint(equalTo: dateAndTimeContainer.bottomAnchor, constant: 5).isActive = true
        locationContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        locationContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        locationContainer.addSubview(locationLabel)
        
        locationLabel.centerYAnchor.constraint(equalTo: locationContainer.centerYAnchor).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: locationContainer.leftAnchor, constant: 10).isActive = true
        //category
        scrollView.addSubview(categoryContainer)
        
        categoryContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        categoryContainer.topAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: 5).isActive = true
        categoryContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        categoryContainer.addSubview(categoryLabel)
        
        categoryLabel.topAnchor.constraint(equalTo: categoryContainer.topAnchor, constant: 10).isActive = true
        categoryLabel.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 10).isActive = true
        
        categoryContainer.addSubview(tripsButton)
        tripsButton.postController = self
        tripsButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20).isActive = true
        tripsButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        tripsButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        tripsButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(natureButton)
        natureButton.postController = self
        natureButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20).isActive = true
        natureButton.leftAnchor.constraint(equalTo: tripsButton.rightAnchor, constant: 40).isActive = true
        natureButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        natureButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(foodDrinkButton)
        foodDrinkButton.postController = self
        foodDrinkButton.topAnchor.constraint(equalTo: tripsButton.bottomAnchor, constant: 20).isActive = true
        foodDrinkButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        foodDrinkButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        foodDrinkButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(concertsButton)
        concertsButton.postController = self
        concertsButton.topAnchor.constraint(equalTo: natureButton.bottomAnchor, constant: 20).isActive = true
        concertsButton.leftAnchor.constraint(equalTo: foodDrinkButton.rightAnchor, constant: 40).isActive = true
        concertsButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        concertsButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(nightlifeButton)
        nightlifeButton.postController = self
        nightlifeButton.topAnchor.constraint(equalTo: foodDrinkButton.bottomAnchor, constant:20).isActive = true
        nightlifeButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        nightlifeButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        nightlifeButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(carpoolButton)
        carpoolButton.postController = self
        carpoolButton.topAnchor.constraint(equalTo: concertsButton.bottomAnchor, constant: 20).isActive = true
        carpoolButton.leftAnchor.constraint(equalTo: nightlifeButton.rightAnchor, constant: 40).isActive = true
        carpoolButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        carpoolButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(sportsButton)
        sportsButton.postController = self
        sportsButton.topAnchor.constraint(equalTo: nightlifeButton.bottomAnchor, constant:20).isActive = true
        sportsButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        sportsButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        sportsButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(workButton)
        workButton.postController = self
        workButton.topAnchor.constraint(equalTo: carpoolButton.bottomAnchor, constant:20).isActive = true
        workButton.leftAnchor.constraint(equalTo: sportsButton.rightAnchor, constant: 40).isActive = true
        workButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        workButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true
        
        categoryContainer.bottomAnchor.constraint(equalTo: workButton.bottomAnchor, constant: 20).isActive = true

        scrollView.addSubview(numberOfPeopleContainer)
        numberOfPeopleContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        numberOfPeopleContainer.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: 5).isActive = true
        numberOfPeopleContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        numberOfPeopleContainer.heightAnchor.constraint(equalToConstant: 120).isActive = true

        numberOfPeopleContainer.addSubview(numberOfPeopleLabel)
        numberOfPeopleLabel.topAnchor.constraint(equalTo: numberOfPeopleContainer.topAnchor, constant: 10).isActive = true
        numberOfPeopleLabel.leftAnchor.constraint(equalTo: numberOfPeopleContainer.leftAnchor, constant: 10).isActive = true

        numberOfPeopleContainer.addSubview(number)
        number.topAnchor.constraint(equalTo: numberOfPeopleLabel.topAnchor, constant: 20).isActive = true
        number.centerXAnchor.constraint(equalTo: numberOfPeopleContainer.centerXAnchor).isActive = true
        number.centerYAnchor.constraint(equalTo: numberOfPeopleContainer.centerYAnchor).isActive = true
        
        numberOfPeopleContainer.addSubview(addButton)
        addButton.centerXAnchor.constraint(equalTo: numberOfPeopleContainer.centerXAnchor, constant: 70).isActive = true
        addButton.centerYAnchor.constraint(equalTo: numberOfPeopleContainer.centerYAnchor).isActive = true
        
        numberOfPeopleContainer.addSubview(deleteButton)
        deleteButton.centerXAnchor.constraint(equalTo: numberOfPeopleContainer.centerXAnchor, constant: -70).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: numberOfPeopleContainer.centerYAnchor).isActive = true
        
//        scrollView.addSubview(postButton)
//        postButton.topAnchor.constraint(equalTo: numberOfPeopleContainer.bottomAnchor, constant: 20).isActive = true
//        postButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
       
    }
    
    //UI Functions
    
    @objc func addOnePerson(sender: UIButton!) {
        numberOfPeople += 1
        number.text = "\(numberOfPeople)"
    }
    
    @objc func deleteOnePerson() {
        if(numberOfPeople > 0)
        {
            numberOfPeople -= 1
        }
        number.text = "\(numberOfPeople)"
    }
    
    @objc func handleDateAndTimeView() {
        print(childUpdates)
        let dateAndTimeController = DateAndTimeController()
        let navController = UINavigationController(rootViewController: dateAndTimeController)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc func handleLocationView() {
        let locationController = LocationController()
        locationController.postController = self
        locationController.feedController = self.feedController
        let navController = UINavigationController(rootViewController: locationController)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    //Database Functions
    
    @objc func handlePost(){
        if activityTextField.text != ""
        {
            let key = ref.child("posts").childByAutoId().key
            let userID = Auth.auth().currentUser?.uid
            ref.child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let todaysDate:Date = Date()
                    let dateFormatter:DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
                    let DateInFormat:String = dateFormatter.string(from: todaysDate)
                    let post = ["name": dictionary["name"] ?? "noname",
                                "uid": dictionary["uid"] ?? "nouid",
                                "activity": self.activityTextField.text!,
                                "description": self.descriptionTextField.text,
//                                "time": DateInFormat,
                                "time": ServerValue.timestamp(),
                                "location": self.locationLabel.title(for: .normal)!,
                                "groupCount": self.numberOfPeople] as [String : Any]
                    let child = ["/posts/\(key)": post]
                    
                    //update FireBase posts
                    self.ref.updateChildValues(child) { (err, ref) in
                        if err != nil{
                            print(err ?? "error")
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.dismiss(animated: true, completion: nil)
                            self.feedController?.checkIfUserIsLoggedIn()
                        }
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
                }
            }
            print("posted")
        }
        
//        func convertToCLLocation(address: String) -> CLLocationCoordinate2D{
//            let geocoder = CLGeocoder()
//            geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
//                if((error) != nil){
//                    print("Error", error ?? "")
//                }
//                if let placemark = placemarks?.first {
//                    return placemark.location!.coordinate
////                    print("Lat: \(coordinates.latitude) -- Long: \(coordinates.longitude)")
//                }
//            })
//        }
        
    }
    
    
    
    
//    func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
//        
//        let calendar = NSCalendar.current
//        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
//        let now = Date()
//        let earliest = now < date ? now : date
//        let latest = (earliest == now) ? date : now
//        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
//        
//        if (components.year! >= 2) {
//            return "\(components.year!) years ago"
//        } else if (components.year! >= 1){
//            if (numericDates){
//                return "1 year ago"
//            } else {
//                return "Last year"
//            }
//        } else if (components.month! >= 2) {
//            return "\(components.month!) months ago"
//        } else if (components.month! >= 1){
//            if (numericDates){
//                return "1 month ago"
//            } else {
//                return "Last month"
//            }
//        } else if (components.weekOfYear! >= 2) {
//            return "\(components.weekOfYear!) weeks ago"
//        } else if (components.weekOfYear! >= 1){
//            if (numericDates){
//                return "1 week ago"
//            } else {
//                return "Last week"
//            }
//        } else if (components.day! >= 2) {
//            return "\(components.day!) days ago"
//        } else if (components.day! >= 1){
//            if (numericDates){
//                return "1 day ago"
//            } else {
//                return "Yesterday"
//            }
//        } else if (components.hour! >= 2) {
//            return "\(components.hour!) hours ago"
//        } else if (components.hour! >= 1){
//            if (numericDates){
//                return "1 hour ago"
//            } else {
//                return "An hour ago"
//            }
//        } else if (components.minute! >= 2) {
//            return "\(components.minute!) minutes ago"
//        } else if (components.minute! >= 1){
//            if (numericDates){
//                return "1 minute ago"
//            } else {
//                return "A minute ago"
//            }
//        } else if (components.second! >= 3) {
//            return "\(components.second!) seconds ago"
//        } else {
//            return "Just now"
//        }
//        
//    }

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

