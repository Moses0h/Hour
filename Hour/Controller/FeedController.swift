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
    static var controller: FeedController?

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
        scrollView.backgroundColor = UIColor(white: 0.95, alpha: 0.5)
        return scrollView
    }()
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Test")
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
        
        for _ in 0...5{
            let butt = FilterButton()
            categoryButtons.append(butt)
            butt.backgroundColor = UIColor.white
            butt.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 7);
            butt.addTarget(self, action: #selector(categoryButtonPressed), for: .touchUpInside)
            
            butt.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            butt.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            butt.layer.shadowOpacity = 0.5
            butt.layer.shadowRadius = 0.0
            butt.layer.masksToBounds = false
            butt.layer.cornerRadius = 4.0
            
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
        
        setupOtherObservers()
        determineMyCurrentLocation()
    }
    
    func setupOtherObservers(){
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
        let users = Database.database().reference().child("users")
        if(Auth.auth().currentUser != nil)
        {
            users.observeSingleEvent(of: .value) { (users) in
                if(users.hasChild(Auth.auth().currentUser!.uid))
                {
                    print("passed")
                    self.determineMyCurrentLocation()
                }
                else
                {
                    self.perform(#selector(self.handleLogout), with: nil, afterDelay: 0)
                }
            }
        }
        else
        {
            self.perform(#selector(self.handleLogout), with: nil, afterDelay: 0)
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
        imageCache.removeAllObjects()
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
            else
            {
                self.dispatchGroup.leave()
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
        let navController = UINavigationController(rootViewController: newPostController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func handleFullView() {
        let fullPostController = FullPostController(nibName: nil, bundle: nil)
        fullPostController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(fullPostController, animated: true)
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
        feedCell.post = post
        feedCell.index = indexPath.row
        feedCell.key = post.key
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 0, 5);
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 10, height: 230)
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
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let detailedPostController = DetailedPostController()
//        detailedPostController.feed = collectionView.cellForItem(at: indexPath) as! FeedCell
//        detailedPostController.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(detailedPostController, animated: true)
//        
//    }
    
//    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! FeedCell
//        cell.backgroundColor = UIColor.lightGray
//        cell.lineView.backgroundColor = UIColor.gray
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! FeedCell
//        cell.backgroundColor = UIColor.white
//        cell.lineView.backgroundColor = UIColor(white: 0.95, alpha: 1)
//    }
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


