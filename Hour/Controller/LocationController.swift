//
//  LocationController.swift
//  Hour
//
//  Created by Moses Oh on 3/9/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

//
//  ViewController.swift
//  MapKitTutorial
//
//  Created by Robert Chen on 12/23/15.
//  Copyright © 2015 Thorn Technologies. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class LocationController: UIViewController, MKMapViewDelegate, HandleMapSearch, CLLocationManagerDelegate, UISearchBarDelegate, UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    
    var postController: PostController?
    var feedController: FeedController?
    
    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    
    let locationManager = CLLocationManager()
    
    var locationSearchTable: LocationSearchTable?
    var mapView: MKMapView!
    var mapHasCenteredOnce: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postController = PostController.controller
        feedController = FeedController.controller
        
        mapView = MKMapView(frame: view.bounds)
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.center = view.center
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        view.addSubview(mapView)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        locationSearchTable = LocationSearchTable()
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.searchBar.tintColor = UIColor.gray
        let attributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        resultSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = " Search for places"
        
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable?.mapView = mapView
        locationSearchTable?.handleMapSearchDelegate = self as HandleMapSearch
        
        view.addSubview(saveButton)
        saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    let saveButton : BounceButton = {
        let butt = BounceButton()
        butt.backgroundColor = UIColor(r: 93, g: 125, b: 255)
        butt.setTitle("Save", for: .normal)
        butt.setTitleColor(UIColor.white, for: .normal)
        butt.addTarget(self, action: #selector(setLocation), for: .touchUpInside)
        butt.isHidden = true
        return butt
    }()
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func getDirections(){
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    @objc func setLocation(){
        let location: String = (locationSearchTable?.selectedLocation)!
        postController?.locationLabel.setTitle(location, for: .normal)
        postController?.locationLabel.setTitleColor(UIColor.gray, for: .normal)
        handleCancel()
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        pinView?.pinTintColor = UIColor.blue
        pinView?.canShowCallout = true
        
        return pinView
    }
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        saveButton.isHidden = false
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        if !mapHasCenteredOnce {
            centerMapOnLocation(location: location)
            mapHasCenteredOnce = true
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}






