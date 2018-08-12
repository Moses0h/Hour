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

class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UITabBarControllerDelegate{
    
    var headerId = "header"
    var ref: DatabaseReference!
    var geoFire: GeoFire!
    var circleQuery: GFCircleQuery!
    var posts = [Post]()
    var filteredPosts = [Post]()
    var keyArray: [String] = []
    var doFetch: Bool = false
    var refresher: UIRefreshControl!
    
    var locationManager:CLLocationManager!
    var currLocation: CLLocation!
    
    let dispatchGroup = DispatchGroup()
    let cellId = "cellId"
    let searchController = UISearchController(searchResultsController: nil)
    
    static var feed: FeedController?
    
    var categoryButtons = [FilterButton]()
    var categorySelected = [String]()
    
    let refreshView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var filterContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        
        if tabBarIndex == 0 {
            let cv_attribute = collectionView?.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: IndexPath.init(item: 0, section: 0))
            collectionView?.scrollRectToVisible((cv_attribute?.frame)!, animated: true)
            
        }
    }
    
    @objc func categoryButtonPressed(sender: FilterButton!) {
        let category = (sender.titleLabel?.text)!
        if(sender.isOn == true)
        {
            categorySelected.append(category)
        }
        else
        {
            let index = categorySelected.index(of: category)!
            categorySelected.remove(at: index)
        }
        filterPosts()
    }
    
    override func viewDidLayoutSubviews() {
        var width:CGFloat = 0
        for view in filterContainer.subviews {
            width += view.bounds.size.width
        }
        width += (self.navigationController?.navigationBar.frame.size.height)!
        filterContainer.contentSize = CGSize(width: width, height: filterContainer.frame.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FeedController.feed = self
        
        for _ in 0...5{
            let butt = FilterButton()
            categoryButtons.append(butt)
            butt.backgroundColor = UIColor.white
            butt.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 7);
            butt.addTarget(self, action: #selector(categoryButtonPressed), for: .touchUpInside)
            butt.layer.cornerRadius = 8
            butt.layer.masksToBounds = true
            
        }
        
        categoryButtons[0].setTitle("Nature", for: .normal)
        categoryButtons[1].setTitle("Food & Drink", for: .normal)
        categoryButtons[2].setTitle("Nightlife", for: .normal)
        categoryButtons[3].setTitle("Trips", for: .normal)
        categoryButtons[4].setTitle("Concerts", for: .normal)
        categoryButtons[5].setTitle("Sports", for: .normal)
        
        ref = Database.database().reference()
        geoFire = GeoFire(firebaseRef: ref.child("posts_location"))
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(updateFeed), for: UIControlEvents.valueChanged)
        
        collectionView?.addSubview(refreshView)
        refreshView.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        refreshView.addSubview(refresher)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = false
        
        let attributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
//        navigationController?.hidesBarsOnSwipe = true
        
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()

        searchBar.placeholder = " Search"
        
        navigationItem.titleView = searchController.searchBar
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(FeedHeaderCell.self, forSupplementaryViewOfKind:
            UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    
        collectionView?.dataSource = self
        tabBarController?.delegate = self

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        checkIfUserIsLoggedIn()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterPosts(searchText: searchController.searchBar.text!)
        collectionView?.scrollsToTop = true
    }
    
    func filterPosts(searchText: String)
    {
        filteredPosts = self.posts.filter{ post in
            let activityTitle = post.activity!
            let description = post.description!
            let category = post.category!
            return(activityTitle.lowercased().contains(searchText.lowercased()) || description.lowercased().contains(searchText.lowercased()) || categorySelected.contains(category))
        }
        collectionView?.reloadData()
    }
    
    func filterPosts()
    {
        filteredPosts = self.posts.filter{ post in
            let category = post.category!
            return(categorySelected.contains(category))
        }
        collectionView?.reloadData()
    }
    
    func checkIfUserIsLoggedIn() {
        let postController = PostController(nibName: nil, bundle: nil)
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
        else{
            print("trying to update")
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
    
    @objc func handleNewPost(sender: BounceButton!){
        let newPostController = PostController(nibName: nil, bundle: nil)
        newPostController.feedController = self
        let navController = UINavigationController(rootViewController: newPostController)
        present(navController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ((searchController.isActive && searchController.searchBar.text != "") || categorySelected.count != 0){
            return filteredPosts.count
        }
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        let post : Post
        if ((searchController.isActive && searchController.searchBar.text != "") || categorySelected.count != 0){
            post = filteredPosts[indexPath.row]
        }
        else
        {
            post = posts[indexPath.row]
        }
        
        feedCell.key = post.key
        feedCell.usersUid = post.usersUid as? [String : Int]
        feedCell.name = post.name
        feedCell.activity = post.activity
        feedCell.descriptionString = post.description
        feedCell.location = post.location
        feedCell.time = post.time
        feedCell.category = post.category
        feedCell.groupCount = post.groupCount
        
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 0, 5);
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 10, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
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


