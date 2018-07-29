//
//  FeedController.swift
//  Hour
//
//  Created by Moses Oh on 2/22/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import CoreLocation

class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate{
    
    var ref: DatabaseReference!
    var geoFire: GeoFire!
    var circleQuery: GFCircleQuery!
    var posts = [Post]()
    var keyArray: [String] = []
    var doFetch: Bool = false
    var refresher: UIRefreshControl!
    
    var locationManager:CLLocationManager!
    var currLocation: CLLocation!
    
    let dispatchGroup = DispatchGroup()
    let cellId = "cellId"
    
    let refreshView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        geoFire = GeoFire(firebaseRef: ref.child("posts_location"))
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(updateFeed), for: UIControlEvents.valueChanged)
        
        collectionView?.addSubview(refreshView)
        refreshView.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        refreshView.addSubview(refresher)
        
        navigationItem.title = "Feed"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "write"), style: .plain, target: self, action: #selector(handleNewPost))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "logout"), style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationController?.hidesBarsOnSwipe = true
        
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.dataSource = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        checkIfUserIsLoggedIn()
        print("hello")
        
    }
    
    func checkIfUserIsLoggedIn() {
        let postController = PostController()
        postController.feedController = self
        if (Auth.auth().currentUser == nil) {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else{
            print("checking")
            self.determineMyCurrentLocation()
        }
    }
    
    @objc func updateFeed() {
        self.refreshView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.determineMyCurrentLocation()
        }
    }
    
    func determineMyCurrentLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(currLocation == nil)
        {
            currLocation = locations.last
            refreshPostArray()
            print("updated location")
        }
        self.refresher.endRefreshing()

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed")
    }
    
    func refreshPostArray() {
        self.posts.removeAll()
        self.keyArray.removeAll()
        circleQuery = geoFire.query(at: currLocation, withRadius: 100)
        var distanceArray = [Double]()
        circleQuery.observe(.keyEntered) { (key: String!, location: CLLocation!) in
            print(key)
            self.keyArray.append(key)
        }
        self.dispatchGroup.enter()
        circleQuery.observeReady {
            if(self.keyArray.count > 0)
            {
                for index in 0...self.keyArray.count-1{
                    self.geoFire.getLocationForKey(self.keyArray[index], withCallback: { (keyLocation, error) in
                        let distance = keyLocation?.distance(from: self.currLocation)
                        distanceArray.append(distance!)
                    })
                    self.ref.child("posts").child(self.keyArray[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                        var post = Post(snapshot: snapshot)
                        post.distance = distanceArray[index]
                        self.posts.append(post)
                        if(self.keyArray.count == self.posts.count)
                        {
                            self.dispatchGroup.leave()
                        }
                    })
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.posts = self.posts.sorted(by: { $0.distance < $1.distance })
            self.collectionView?.reloadData()
            self.currLocation = nil
        }
        
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        loginController.feedController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleNewPost(){
        let newPostController = PostController()
        newPostController.feedController = self
        let navController = UINavigationController(rootViewController: newPostController)
        present(navController, animated: true, completion: nil)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        if indexPath.row < posts.count {
            let post = posts[indexPath.row]
            feedCell.post = post
            feedCell.key = post.key
            feedCell.activity = post.activity
            feedCell.descriptionString = post.description
            feedCell.name = post.name
            feedCell.usersUid = post.usersUid
            return feedCell
        }
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}




extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}









////
////  FeedController.swift
////  Hour
////
////  Created by Moses Oh on 2/22/18.
////  Copyright © 2018 Moses Oh. All rights reserved.
////
//
//import UIKit
//import Firebase
//import GeoFire
//import CoreLocation
//
//class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate{
//
//    var ref: DatabaseReference!
//    var geoFire: GeoFire!
//    var circleQuery: GFCircleQuery!
//    var posts = [Post]()
//    var keyArray: [String] = []
//    var doFetch: Bool = false
//    var refresher: UIRefreshControl!
//
//    var locationManager = CLLocationManager()
//    var currLocation: CLLocation!
//
//    let dispatchGroup = DispatchGroup()
//    let locationDispatchGroup = DispatchGroup()
//    let cellId = "cellId"
//
//    let refreshView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.clear
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        ref = Database.database().reference()
//        geoFire = GeoFire(firebaseRef: ref.child("posts_location"))
//
//        refresher = UIRefreshControl()
//        refresher.addTarget(self, action: #selector(updateFeed), for: UIControlEvents.valueChanged)
//
//        collectionView?.addSubview(refreshView)
//        refreshView.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
//        refreshView.addSubview(refresher)
//
//        navigationItem.title = "Feed"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(handleNewPost))
//        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
//        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
//        navigationController?.hidesBarsOnSwipe = true
//
//
//        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
//
//        collectionView?.alwaysBounceVertical = true
//
//        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
//
//        collectionView?.dataSource = self
//
//
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
//
//
//        checkIfUserIsLoggedIn()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        currLocation = locations.last!
//        self.locationManager.stopUpdatingLocation()
//
//        locationDispatchGroup.leave()
//    }
//
//    func checkIfUserIsLoggedIn() {
//        let postController = PostController()
//        postController.feedController = self
//        if (Auth.auth().currentUser == nil) {
//            perform(#selector(handleLogout), with: nil, afterDelay: 0)
//        }
//        else{
//            determineMyCurrentLocation()
//        }
//    }
//
//    @objc func updateFeed() {
//        self.refreshView.heightAnchor.constraint(equalToConstant: 200).isActive = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.determineMyCurrentLocation()
//            self.refresher.endRefreshing()
//
//        }
//    }
//
//    func determineMyCurrentLocation() {
//        self.locationDispatchGroup.enter()
//        locationManager.startUpdatingLocation()
//
//        self.posts.removeAll()
//        self.keyArray.removeAll()
//
//        if CLLocationManager.locationServicesEnabled() {
//            locationDispatchGroup.notify(queue: .main) {
//                if(self.currLocation != nil)
//                {
//                    self.refreshPostArray()
//                }
//            }
//        }
//    }
//
//    func refreshPostArray() {
//        circleQuery = geoFire.query(at: currLocation, withRadius: 100)
//        var distanceArray = [Double]()
//        circleQuery.observe(.keyEntered) { (key: String!, location: CLLocation!) in
//            print(key)
//            self.keyArray.append(key)
//        }
//        self.dispatchGroup.enter()
//        circleQuery.observeReady {
//            if(self.keyArray.count > 0)
//            {
//                for index in 0...self.keyArray.count-1{
//                    self.geoFire.getLocationForKey(self.keyArray[index], withCallback: { (keyLocation, error) in
//                        let distance = keyLocation?.distance(from: self.currLocation)
//                        distanceArray.append(distance!)
//                    })
//                    self.ref.child("posts").child(self.keyArray[index]).observeSingleEvent(of: .value, with: { (snapshot) in
//                        var post = Post(snapshot: snapshot)
//                        post.distance = distanceArray[index]
//                        self.posts.append(post)
//                        if(self.keyArray.count == self.posts.count)
//                        {
//                            self.dispatchGroup.leave()
//                        }
//                    })
//                }
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            self.posts = self.posts.sorted(by: { $0.distance < $1.distance })
//            self.collectionView?.reloadData()
//        }
//
//    }
//
//    @objc func handleLogout() {
//        do {
//            try Auth.auth().signOut()
//        } catch let logoutError {
//            print(logoutError)
//        }
//        let loginController = LoginController()
//        loginController.feedController = self
//        present(loginController, animated: true, completion: nil)
//    }
//
//    @objc func handleNewPost(){
//        let newPostController = PostController()
//        newPostController.feedController = self
//        let navController = UINavigationController(rootViewController: newPostController)
//        present(navController, animated: true, completion: nil)
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return posts.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
//        if indexPath.row < posts.count {
//            let post = posts[indexPath.row]
//            feedCell.post = post
//            feedCell.activity = post.activity
//            feedCell.name = post.name
//            return feedCell
//        }
//        return feedCell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: 200)
//    }
//}
//
//
//
//
//extension UIView {
//    func addConstraintsWithFormat(format: String, views: UIView...) {
//        var viewsDictionary = [String: UIView]()
//        for (index, view) in views.enumerated() {
//            let key = "v\(index)"
//            viewsDictionary[key] = view
//            view.translatesAutoresizingMaskIntoConstraints = false
//        }
//
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
//    }
//}
//




